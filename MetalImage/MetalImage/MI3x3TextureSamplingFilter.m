//
//  MI3x3TextureSamplingFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/17.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MI3x3TextureSamplingFilter.h"
#import "MetalDevice.h"
#import <UIKit/UIKit.h>

@implementation MI3x3TextureSamplingFilter

- (instancetype)initWithFragmentFunctionName:(NSString *)fragmentFunctionName {
    if (self = [super initWithVertexFunctionName:@"vertex_nearbyTexelSampling" fragmentFunctionName:fragmentFunctionName]) {
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _texelSizeBuffer = [device newBufferWithLength:sizeof(MTLFloat2) options:MTLResourceOptionCPUCacheModeDefault];
        
        hasOverriddenImageSizeFactor = NO;
    }
    return self;
}

- (instancetype)initWithFragmentFunction:(id<MTLFunction>)fragmentFunction {
    
    //iOS8.0上newDefaultLibrary返回为空的bug
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0f) {
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:@"/"];
    }
    
    id<MTLLibrary> defaultLibrary = [MetalDevice MetalImageLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertex_nearbyTexelSampling"];
    
    if (self = [super initWithVertexFunction:vertexFunction fragmentFunction:fragmentFunction]) {
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _texelSizeBuffer = [device newBufferWithLength:sizeof(MTLFloat2) options:MTLResourceOptionCPUCacheModeDefault];
        
        self.texelSize = MTLFloat2Make(1.0, 1.0);
        hasOverriddenImageSizeFactor = NO;
    }
    return self;
}

- (void)setTexelSize:(MTLFloat2)texelSize {
    hasOverriddenImageSizeFactor = YES;
    _texelSize = texelSize;
    
    MTLFloat2 *contentBuffer = (MTLFloat2 *)[_texelSizeBuffer contents];
    contentBuffer[0] = texelSize;
}

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    [super setInputTexture:newInputTexture atIndex:textureIndex];
    
    if (!hasOverriddenImageSizeFactor) {
        MTLUInt2 textureSize = newInputTexture.size;
        if (MetalImageRotationSwapsWidthAndHeight(firstInputParameter.rotationMode)) {
            textureSize = MTLUInt2Make(textureSize.y, textureSize.x);
        }
        
        if (!MTLUInt2Equal(textureSize, lastImageSize)) {
            lastImageSize = textureSize;
            
            runMetalSynchronouslyOnVideoProcessingQueue(^{
                MTLFloat *contentBuffer = (MTLFloat *)[_texelSizeBuffer contents];
                contentBuffer[0] = 1.0 / (MTLFloat)textureSize.x;
                contentBuffer[1] = 1.0 / (MTLFloat)textureSize.y;
            });
        }
    }
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_texelSizeBuffer offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}


@end
