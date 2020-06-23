//
//  MISurfaceBlurFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2020/6/23.
//  Copyright © 2020 fengshi. All rights reserved.
//

#import "MISurfaceBlurFilter.h"
#import "MetalDevice.h"

@interface MISurfaceBlurFilter() {
    
    id<MTLBuffer> _bufferSteps;
    id<MTLBuffer> _surfaceBlurRaius;
    id<MTLBuffer> _surfaceGamma;
    
    MTLUInt2 _imageSize;
}

@end

@implementation MISurfaceBlurFilter

- (instancetype)init {
    if (self = [super initWithVertexFunctionName:@"vertex_texelSampling"
                            fragmentFunctionName:@"fragment_Surface_Blur"]) {
        _bufferSteps = [[MetalDevice sharedMTLDevice] newBufferWithLength:sizeof(MTLFloat2)
                                                                  options:MTLResourceCPUCacheModeDefaultCache];
        _surfaceBlurRaius = [[MetalDevice sharedMTLDevice] newBufferWithLength:sizeof(MTLInt)
                                                                       options:MTLResourceCPUCacheModeDefaultCache];
        _surfaceGamma = [[MetalDevice sharedMTLDevice] newBufferWithLength:sizeof(MTLFloat)
                                                                   options:MTLResourceCPUCacheModeDefaultCache];
        
        self.gamma = 15.0f;
        self.radius = 5;
    }
    return self;
}

- (void)setGamma:(float)gamma {
    if (_gamma != gamma) {
        _gamma = gamma;
        
        MTLFloat *content = (MTLFloat *)_surfaceGamma.contents;
        content[0] = gamma * 2.5f / 255.0f;
    }
}

- (void)setRadius:(int)radius {
    if (_radius != radius) {
        _radius = radius;
        
        MTLInt *content = (MTLInt *)_surfaceBlurRaius.contents;
        content[0] = radius;
    }
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_bufferSteps offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_surfaceBlurRaius offset:0 atIndex:0];
    [renderEncoder setFragmentBuffer:_surfaceGamma offset:0 atIndex:1];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
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

@end
