//
//  MITwoPassTextureSamplingFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/9/2.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MITwoPassTextureSamplingFilter.h"
#import "MetalDevice.h"

@implementation MITwoPassTextureSamplingFilter

- (instancetype)initWithFirstStageVertexFunctionName:(NSString *)firstStageVertexFunctionName
                      firstStageFragmentFunctionName:(NSString *)firstStageFragmentFunctionName
                       secondStageVertexFunctionName:(NSString *)secondStageVertexFunctionName
                     secondStageFragmentFunctionName:(NSString *)secondStageFragmentFunctionName {
    if (self = [super initWithFirstStageVertexFunctionName:firstStageVertexFunctionName
                            firstStageFragmentFunctionName:firstStageFragmentFunctionName
                             secondStageVertexFunctionName:secondStageVertexFunctionName
                           secondStageFragmentFunctionName:secondStageFragmentFunctionName]) {
        
        [self initialize];
    }
    
    return self;
}

- (nonnull instancetype)initWithFirstStageVertexFunction:(nonnull id<MTLFunction>)firstStageVertexFunction
                              firstStageFragmentFunction:(nonnull id<MTLFunction>)firstStageFragmentFunction
                               secondStageVertexFunction:(nonnull id<MTLFunction>)secondStageVertexFunction
                             secondStageFragmentFunction:(nonnull id<MTLFunction>)secondStageFragmentFunction
{
    if (self = [super initWithFirstStageVertexFunction:firstStageVertexFunction
                            firstStageFragmentFunction:firstStageFragmentFunction
                             secondStageVertexFunction:secondStageVertexFunction
                           secondStageFragmentFunction:secondStageFragmentFunction]) {
        
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    verticalBuffer = [device newBufferWithLength:sizeof(MTLFloat2)
                                         options:MTLResourceOptionCPUCacheModeDefault];
    horizontalBuffer = [device newBufferWithLength:sizeof(MTLFloat2)
                                           options:MTLResourceOptionCPUCacheModeDefault];
    
    self.verticalTexelSpacing = 1.0;
    self.horizontalTexelSpacing = 1.0;
}

- (MTLUInt2)textureSizeForTexel {
    return firstInputTexture.size;
}

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    [super setInputTexture:newInputTexture atIndex:textureIndex];
    
    MTLUInt2 textureSize = [self textureSizeForTexel];
    
    if (!MTLUInt2Equal(textureSize, lastImageSize)) {
        lastImageSize = textureSize;
        
        [self setupFilterForSize:textureSize];
    }
}

- (void)setupFilterForSize:(MTLUInt2)filterFrameSize
{
    runMetalSynchronouslyOnVideoProcessingQueue(^{
        // The first pass through the framebuffer may rotate the inbound image,
        // so need to account for that by changing up the kernel ordering for that pass
        MTLFloat *verticalContentBuffer = (MTLFloat *)[verticalBuffer contents];
        if (MetalImageRotationSwapsWidthAndHeight(firstInputParameter.rotationMode))
        {
            verticalContentBuffer[0] = _verticalTexelSpacing / (MTLFloat)filterFrameSize.y;
            verticalContentBuffer[1] = 0.0;
        }
        else
        {
            verticalContentBuffer[0] = 0.0f;
            verticalContentBuffer[1] = _verticalTexelSpacing / (MTLFloat)filterFrameSize.y;
        }
        
        MTLFloat *horizontalContentBuffer = (MTLFloat *)[horizontalBuffer contents];
        horizontalContentBuffer[0] = _horizontalTexelSpacing / (MTLFloat)filterFrameSize.x;
        horizontalContentBuffer[1] = 0.0f;
    });
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:verticalBuffer offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

- (void)assembleSecondStageRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_secondStageDepthStencilState];
    [renderEncoder setRenderPipelineState:_secondStagePipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_secondCoordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:horizontalBuffer offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[secondOutputTexture texture] atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

#pragma mark -
#pragma mark Accessors

- (void)setVerticalTexelSpacing:(MTLFloat)newValue;
{
    _verticalTexelSpacing = newValue;
    [self setupFilterForSize:[self textureSizeForTexel]];
}

- (void)setHorizontalTexelSpacing:(MTLFloat)newValue;
{
    _horizontalTexelSpacing = newValue;
    [self setupFilterForSize:[self textureSizeForTexel]];
}

@end
