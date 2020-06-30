//
//  MIMaskBilateralFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2020/6/30.
//  Copyright © 2020 fengshi. All rights reserved.
//

#import "MIMaskBilateralFilter.h"
#import "MetalDevice.h"

@interface MIMaskBilateralFilter() {

    id<MTLBuffer> _weightsBuffer;
    id<MTLBuffer> _radiusBuffer;
    id<MTLBuffer> _pixelSteps;
    MTLUInt2 _lastImageSize;
}

@end

@implementation MIMaskBilateralFilter


- (id)init
{
    if (self = [super initWithFragmentFunctionName:@"fragment_MaskBilateralFilter"]) {

        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _pixelSteps = [device newBufferWithLength:sizeof(MTLFloat2)
                                          options:MTLResourceOptionCPUCacheModeDefault];
        _radiusBuffer = [device newBufferWithLength:sizeof(MTLInt)
                                            options:MTLResourceOptionCPUCacheModeDefault];
        self.radius = 5;
    }
    
    return self;
}


#pragma mark - 计算高斯梯度

- (void)setRadius:(unsigned int)radius {
    
    NSParameterAssert(radius > 0);
    
    if (_radius != radius) {
        
        int size = radius * 2 + 1;
        
        float *buffer = malloc(sizeof(float) * size * size);
        
        make_gaussian_distribution_2d(_radius, (float)_radius, false, buffer);
        
        runMetalSynchronouslyOnVideoProcessingQueue(^{
            
            MTLInt *radiusBuffer = (MTLInt *)[_radiusBuffer contents];
            radiusBuffer[0] = (MTLInt)radius;
            
            _weightsBuffer = [[MetalDevice sharedMTLDevice] newBufferWithBytes:buffer
                                                                        length:size*size*sizeof(float)
                                                                       options:MTLResourceOptionCPUCacheModeDefault];
        });
        
        free(buffer);
    }
}

- (MTLUInt2)textureSizeForTexel {
    return firstInputTexture.size;
}

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    [super setInputTexture:newInputTexture atIndex:textureIndex];
    
    MTLUInt2 textureSize = [self textureSizeForTexel];
    
    if (!MTLUInt2Equal(textureSize, _lastImageSize)) {
        _lastImageSize = textureSize;
        
        [self setupFilterForSize:textureSize];
    }
}

- (void)setupFilterForSize:(MTLUInt2)filterFrameSize
{
    runMetalSynchronouslyOnVideoProcessingQueue(^{
        MTLFloat *content = (MTLFloat *)[_pixelSteps contents];
        content[0] = 1.0f / (MTLFloat)filterFrameSize.x;
        content[1] = 1.0f / (MTLFloat)filterFrameSize.y;
    });
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_pixelSteps offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentTexture:[secondInputTexture texture] atIndex:1];
    [renderEncoder setFragmentBuffer:_radiusBuffer offset:0 atIndex:0];
    [renderEncoder setFragmentBuffer:_weightsBuffer offset:0 atIndex:1];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
