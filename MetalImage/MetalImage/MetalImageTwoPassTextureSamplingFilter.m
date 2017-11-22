//
//  MetalImageTwoPassTextureSamplingFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/9/2.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoPassTextureSamplingFilter.h"
#import "MetalDevice.h"

@implementation MetalImageTwoPassTextureSamplingFilter

- (nonnull instancetype)initWithFirstStageVertexFunction:(nonnull id<MTLFunction>)firstStageVertexFunction
                              firstStageFragmentFunction:(nonnull id<MTLFunction>)firstStageFragmentFunction
                               secondStageVertexFunction:(nonnull id<MTLFunction>)secondStageVertexFunction
                             secondStageFragmentFunction:(nonnull id<MTLFunction>)secondStageFragmentFunction
{
    if (self = [super initWithFirstStageVertexFunction:firstStageVertexFunction
                            firstStageFragmentFunction:firstStageFragmentFunction
                             secondStageVertexFunction:secondStageVertexFunction
                           secondStageFragmentFunction:secondStageFragmentFunction]) {
        
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        verticalBuffer = [device newBufferWithLength:MetalImageDefaultRenderVetexCount*sizeof(MTLFloat2)
                                             options:MTLResourceOptionCPUCacheModeDefault];
        horizontalBuffer = [device newBufferWithLength:MetalImageDefaultRenderVetexCount*sizeof(MTLFloat2)
                                               options:MTLResourceOptionCPUCacheModeDefault];
        
        self.verticalTexelSpacing = 1.0;
        self.horizontalTexelSpacing = 1.0;
    }
    
    return self;
}

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    [super setInputTexture:newInputTexture atIndex:textureIndex];
    
    MTLUInt2 textureSize = [self textureSizeForOutput];
    
    if (!MTLUInt2Equal(textureSize, lastImageSize)) {
        lastImageSize = textureSize;
        
        [self setupFilterForSize:textureSize];
    }
}

- (void)setupFilterForSize:(MTLUInt2)filterFrameSize;
{
    runMetalSynchronouslyOnVideoProcessingQueue(^{
        MTLFloat *verticalContentBuffer = (MTLFloat *)[verticalBuffer contents];
        verticalContentBuffer[0] = 0.0f;
        verticalContentBuffer[1] = _verticalTexelSpacing / (MTLFloat)filterFrameSize.y;
        
        MTLFloat *horizontalContentBuffer = (MTLFloat *)[verticalBuffer contents];
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
    [self setupFilterForSize:[self textureSizeForOutput]];
}

- (void)setHorizontalTexelSpacing:(MTLFloat)newValue;
{
    _horizontalTexelSpacing = newValue;
    [self setupFilterForSize:[self textureSizeForOutput]];
}

@end
