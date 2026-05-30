//
//  MIColorPackingFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIColorPackingFilter.h"
#import "MetalDevice.h"

@interface MIColorPackingFilter() {
    
    MTLUInt2 lastImageSize;
}

@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;

@end

@implementation MIColorPackingFilter

- (instancetype)init {
    if (self = [super initWithVertexFunctionName:@"vertex_ColorPackingFilter" fragmentFunctionName:@"fragment_ColorPackingFilter"]) {
        
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _vertexBuffer = [device newBufferWithLength:sizeof(MTLFloat2) options:MTLResourceOptionCPUCacheModeDefault];
    }
    
    return self;
}

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    [super setInputTexture:newInputTexture atIndex:textureIndex];
    
    MTLUInt2 textureSize = [self textureSizeForOutput];
    if (!MTLUInt2Equal(textureSize, lastImageSize)) {
        lastImageSize = textureSize;
        
        runMetalSynchronouslyOnVideoProcessingQueue(^{
            MTLFloat *contentBuffer = (MTLFloat *)[_vertexBuffer contents];
            contentBuffer[0] = 0.5 / (MTLFloat)textureSize.x;
            contentBuffer[1] = 0.5 / (MTLFloat)textureSize.y;
        });
    }
}

- (MTLUInt2)textureSizeForOutput {
    MTLUInt2 textureSize = [firstInputTexture size];
    if (MetalImageRotationSwapsWidthAndHeight(firstInputParameter.rotationMode)) {
        return MTLUInt2Make(textureSize.y>>1, textureSize.x>>1);
    }
    else {
        return MTLUInt2Make(textureSize.x>>1, textureSize.y>>1);
    }
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
