//
//  MIKuwaharaRadius3Filter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIKuwaharaRadius3Filter.h"
#import "MetalDevice.h"

@interface MIKuwaharaRadius3Filter() {
    
    id<MTLBuffer> _bufferSteps;
    
    MTLUInt2 _imageSize;
}

@end

@implementation MIKuwaharaRadius3Filter

- (id)init
{
    if (!(self = [super initWithVertexFunctionName:@"vertex_texelSampling"
                              fragmentFunctionName:@"fragment_KuwaharaRadius3Filter"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _bufferSteps = [device newBufferWithLength:sizeof(MTLFloat2) options:MTLResourceOptionCPUCacheModeDefault];

    return self;
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
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
