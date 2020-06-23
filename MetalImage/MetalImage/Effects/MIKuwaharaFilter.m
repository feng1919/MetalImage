//
//  MIKuwaharaFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIKuwaharaFilter.h"
#import "MetalImageFilterExtension.h"
#import "MetalDevice.h"

@interface MIKuwaharaFilter() {
    
    id<MTLBuffer> _bufferRadius;
    id<MTLBuffer> _bufferSteps;
    
    MTLUInt2 _imageSize;
}

@end

@implementation MIKuwaharaFilter

- (id)init
{
    if (!(self = [super initWithVertexFunctionName:@"vertex_texelSampling"
                              fragmentFunctionName:@"fragment_KuwaharaFilter"]))
    {
        return nil;
    }
    
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _bufferRadius = [device newBufferWithLength:sizeof(MTLFloat)*1 options:MTLResourceOptionCPUCacheModeDefault];
    _bufferSteps = [device newBufferWithLength:sizeof(MTLFloat2) options:MTLResourceOptionCPUCacheModeDefault];
    
    self.radius = 3;
    
    return self;
}

- (void)setRadius:(NSUInteger)radius {
    if (_radius != radius) {
        _radius = radius;

        MTLFloat *bufferContents = (MTLFloat *)[_bufferRadius contents];
        bufferContents[0] = (MTLFloat)_radius;
    }
}

- (void)updateContentBuffer
{
}


- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    [super setInputTexture:newInputTexture atIndex:textureIndex];
    
    MTLUInt2 textureSize = [self textureSizeForTexel];
    
    if (!MTLUInt2Equal(textureSize, _imageSize)) {
        _imageSize = textureSize;
        
        [self setupFilterForSize:textureSize];
    }
}

- (void)setupFilterForSize:(MTLUInt2)filterFrameSize
{
    runMetalSynchronouslyOnVideoProcessingQueue(^{
        
        MTLFloat *content = (MTLFloat *)[_bufferSteps contents];
        if (MetalImageRotationSwapsWidthAndHeight(firstInputParameter.rotationMode))
        {
            content[0] = 1.0f / (MTLFloat)filterFrameSize.y;
            content[1] = 1.0 / (MTLFloat)filterFrameSize.x;
        }
        else
        {
            content[0] = 1.0f / (MTLFloat)filterFrameSize.x;
            content[1] = 1.0f / (MTLFloat)filterFrameSize.y;
        }
    });
}

- (MTLUInt2)textureSizeForTexel {
    return firstInputTexture.size;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_bufferSteps offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_bufferRadius offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}



@end
