//
//  MIBilateralFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2020/6/23.
//  Copyright © 2020 fengshi. All rights reserved.
//

#import "MIBilateralFilter.h"
#import "MetalImageMath.h"
#import "MetalDevice.h"

@interface MIBilateralFilter() {

    id<MTLBuffer> _weightsBuffer;
    id<MTLBuffer> _radiusBuffer;
}

@end

@implementation MIBilateralFilter

#pragma mark -
#pragma mark Initialization

- (id)initWithFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString
            firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString
             secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString
           secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString
{
    if (!(self = [super initWithFirstStageVertexShaderFromString:firstStageVertexShaderString
                              firstStageFragmentShaderFromString:firstStageFragmentShaderString
                               secondStageVertexShaderFromString:secondStageVertexShaderString
                             secondStageFragmentShaderFromString:secondStageFragmentShaderString]))
    {
        return nil;
    }
    
    _radiusBuffer = [[MetalDevice sharedMTLDevice] newBufferWithLength:sizeof(MTLInt) options:MTLResourceOptionCPUCacheModeDefault];
    self.radius = 6;
    
    return self;
}

- (id)init
{
    if (self = [super initWithFirstStageVertexFunctionName:@"vertex_texelSampling"
                            firstStageFragmentFunctionName:@"fragment_BilateralFilter"
                             secondStageVertexFunctionName:@"vertex_texelSampling"
                           secondStageFragmentFunctionName:@"fragment_BilateralFilter"]) {

        _radiusBuffer = [[MetalDevice sharedMTLDevice] newBufferWithLength:sizeof(MTLInt) options:MTLResourceOptionCPUCacheModeDefault];
        self.radius = 16;
    }
    
    return self;
}

#pragma mark - 计算高斯梯度

- (void)setRadius:(unsigned int)radius {
    
    NSParameterAssert(radius > 0);
    
    if (_radius != radius) {
        
        float *buffer = malloc(sizeof(float) * (radius+1));
        
        float sigma = (float)radius;
        float std = 2.0 * pow(sigma, 2.0);
        for (int i = 0; i < radius + 1; i++) {
            buffer[i] = exp(-pow(i, 2.0) / std);
        }
        
        runMetalSynchronouslyOnVideoProcessingQueue(^{
            
            MTLInt *radiusBuffer = (MTLInt *)[_radiusBuffer contents];
            radiusBuffer[0] = (MTLInt)radius+1;
            
            _weightsBuffer = [[MetalDevice sharedMTLDevice] newBufferWithBytes:buffer
                                                                        length:(radius+1)*sizeof(float)
                                                                       options:MTLResourceOptionCPUCacheModeDefault];
        });
        
        free(buffer);
    }
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:verticalBuffer offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_radiusBuffer offset:0 atIndex:0];
    [renderEncoder setFragmentBuffer:_weightsBuffer offset:0 atIndex:1];
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
    [renderEncoder setFragmentBuffer:_radiusBuffer offset:0 atIndex:0];
    [renderEncoder setFragmentBuffer:_weightsBuffer offset:0 atIndex:1];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}


@end
