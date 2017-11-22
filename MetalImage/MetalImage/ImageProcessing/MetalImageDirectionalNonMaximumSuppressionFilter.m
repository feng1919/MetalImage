//
//  MetalImageDirectionalNonMaximumSuppressionFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageDirectionalNonMaximumSuppressionFilter.h"
#import "MetalDevice.h"

@interface MetalImageDirectionalNonMaximumSuppressionFilter() {
    
@protected
    BOOL hasOverriddenImageSizeFactor;
    MTLUInt2 lastImageSize;
}

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageDirectionalNonMaximumSuppressionFilter

- (instancetype)init {
    
    if (self = [super initWithFragmentFunctionName:@"fragment_DirectionalNonMaximumSuppressionFilter"]) {
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _buffer = [device newBufferWithLength:sizeof(MTLFloat)*4 options:MTLResourceOptionCPUCacheModeDefault];
        
        self.upperThreshold = 0.5;
        self.lowerThreshold = 0.1;
        
        hasOverriddenImageSizeFactor = NO;
    }
    return self;
}

- (void)setTexelSize:(MTLFloat2)texelSize {
    hasOverriddenImageSizeFactor = YES;
    _texelSize = texelSize;
    
    MTLFloat2 *contentBuffer = (MTLFloat2 *)[_buffer contents];
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
                MTLFloat *contentBuffer = (MTLFloat *)[_buffer contents];
                contentBuffer[0] = 1.0 / (MTLFloat)textureSize.x;
                contentBuffer[1] = 1.0 / (MTLFloat)textureSize.y;
            });
        }
    }
}

- (void)setLowerThreshold:(MTLFloat)newValue;
{
    _lowerThreshold = newValue;
    
    MTLFloat *contentBuffer = (MTLFloat *)[_buffer contents];
    contentBuffer[3] = _lowerThreshold;
}

- (void)setUpperThreshold:(MTLFloat)newValue;
{
    _upperThreshold = newValue;
    
    MTLFloat *contentBuffer = (MTLFloat *)[_buffer contents];
    contentBuffer[2] = _upperThreshold;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
