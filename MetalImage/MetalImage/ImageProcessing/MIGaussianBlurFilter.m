//
//  MIGaussianBlurFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/9/2.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIGaussianBlurFilter.h"
#import "MetalDevice.h"

@implementation MIGaussianBlurFilter

#pragma mark -
#pragma mark Initialization and teardown

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
    self.blurRadiusInPixels = 6;
    
    return self;
}

- (id)init
{
    if (self = [super initWithFirstStageVertexFunctionName:@"vertex_texelSampling"
                            firstStageFragmentFunctionName:@"fragment_GaussianVertical"
                             secondStageVertexFunctionName:@"vertex_texelSampling"
                           secondStageFragmentFunctionName:@"fragment_GaussianHorizontal"]) {

        _radiusBuffer = [[MetalDevice sharedMTLDevice] newBufferWithLength:sizeof(MTLInt) options:MTLResourceOptionCPUCacheModeDefault];
        self.blurRadiusInPixels = 6;
    }
    
    return self;
}

#pragma mark - 计算高斯梯度
// "Implementation limit of 32 varying components exceeded" - Max number of varyings for these GPUs

void GaussianWeights1(unsigned int blurRadius, float *buffer) {
    GaussianWeights(blurRadius, (float)blurRadius, buffer);
}

void GaussianWeights(unsigned int blurRadius, float sigma, float *buffer)
{
    assert(blurRadius > 0);
    assert(blurRadius < 16);
    assert(buffer != NULL);
    assert(sigma > 0.0f);
    
    // generate the normal gaussian weights for a given sigma
    float totalWeights = 0.0f;
    float power = 1.0f / sqrt(2.0f * M_PI * pow(sigma, 2.0)); // for reducing the cost of pow calculation
    float std = 2.0 * pow(sigma, 2.0);
    for (int i = 0; i < blurRadius + 1; i++) {
        buffer[i] = power * exp(-pow(i, 2.0) / std);
        
        if (i == 0) {
            totalWeights += buffer[i];
        }
        else {
            totalWeights += 2.0f * buffer[i];
        }
    }
    
    // normalize the weights
    for (int i = 0; i < blurRadius + 1; i ++) {
        buffer[i] /= totalWeights;
    }
}

- (void)setBlurRadiusInPixels:(NSInteger)blurRadiusInPixels {
    
    NSAssert(blurRadiusInPixels > 0, @"Invalid gaussian blur radius in pixels.");
    
    if (_blurRadiusInPixels != blurRadiusInPixels) {
        _blurRadiusInPixels = blurRadiusInPixels;
        
        float *buffer = calloc(_blurRadiusInPixels + 1, sizeof(float));
        GaussianWeights1((unsigned int)_blurRadiusInPixels, buffer);
        
        runMetalSynchronouslyOnVideoProcessingQueue(^{
            
            MTLInt *radiusBuffer = (MTLInt *)[_radiusBuffer contents];
            radiusBuffer[0] = (MTLInt)_blurRadiusInPixels+1;
            
            _gaussianKernelBuffer = [[MetalDevice sharedMTLDevice] newBufferWithBytes:buffer
                                                                               length:(_blurRadiusInPixels+1)*sizeof(float)
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
    [renderEncoder setFragmentBuffer:_gaussianKernelBuffer offset:0 atIndex:1];
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
    [renderEncoder setFragmentBuffer:_gaussianKernelBuffer offset:0 atIndex:1];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
