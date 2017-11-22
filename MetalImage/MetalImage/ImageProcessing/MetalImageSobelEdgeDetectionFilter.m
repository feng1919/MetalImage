//
//  MetalImageSobelEdgeDetectionFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageSobelEdgeDetectionFilter.h"
#import "MetalDevice.h"

@implementation MetalImageSobelEdgeDetectionFilter

- (instancetype)initWithFragmentFunctionName:(NSString *)fragmentFunctionName {
    
    // Do a luminance pass first to reduce the calculations performed at each fragment in the edge detection phase
    
    if (self = [super initWithFirstStageVertexFunctionName:@"vertex_common"
                            firstStageFragmentFunctionName:@"fragment_luminance"
                             secondStageVertexFunctionName:@"vertex_nearbyTexelSampling"
                           secondStageFragmentFunctionName:fragmentFunctionName]) {
        
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _vertexSlotBuffer = [device newBufferWithLength:sizeof(MTLFloat2) options:MTLResourceOptionCPUCacheModeDefault];
        _fragmentSlotBuffer = [device newBufferWithLength:sizeof(MTLFloat) options:MTLResourceOptionCPUCacheModeDefault];
        
        self.edgeStrength = 1.0;
        
        hasOverriddenImageSizeFactor = NO;
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithFragmentFunctionName:@"fragment_SobelEdgeDetectionFilter"];
}

- (void)setTexelSize:(MTLFloat2)texelSize {
    hasOverriddenImageSizeFactor = YES;
    _texelSize = texelSize;
    
    MTLFloat2 *contentBuffer = (MTLFloat2 *)[_vertexSlotBuffer contents];
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
                MTLFloat *contentBuffer = (MTLFloat *)[_vertexSlotBuffer contents];
                contentBuffer[0] = 1.0 / (MTLFloat)textureSize.x;
                contentBuffer[1] = 1.0 / (MTLFloat)textureSize.y;
            });
        }
    }
}

- (void)setEdgeStrength:(MTLFloat)edgeStrength {
    _edgeStrength = edgeStrength;
    
    MTLFloat *contentBuffer = (MTLFloat *)[_fragmentSlotBuffer contents];
    contentBuffer[0] = edgeStrength;
}

- (void)assembleSecondStageRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_secondStageDepthStencilState];
    [renderEncoder setRenderPipelineState:_secondStagePipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_secondCoordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_vertexSlotBuffer offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[secondOutputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_fragmentSlotBuffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
