//
//  MIGaussianBlurFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/9/2.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIGaussianBlurFilter.h"
#import "MetalDevice.h"
#import "MetalImageMath.h"

@implementation MIGaussianBlurFilter

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
                            firstStageFragmentFunctionName:@"fragment_GaussianFilter"
                             secondStageVertexFunctionName:@"vertex_texelSampling"
                           secondStageFragmentFunctionName:@"fragment_GaussianFilter"]) {

        _radiusBuffer = [[MetalDevice sharedMTLDevice] newBufferWithLength:sizeof(MTLInt) options:MTLResourceOptionCPUCacheModeDefault];
        self.radius = 3;
    }
    
    return self;
}

#pragma mark - 计算高斯梯度

- (void)setRadius:(unsigned int)radius {
    
    NSAssert(radius > 0, @"Invalid gaussian blur radius in pixels.");
    
    if (_radius != radius) {
        _radius = radius;
        
        float *buffer = calloc(radius + 1, sizeof(float));
        make_gaussian_distribution(radius, (float)radius, true, buffer);
        
        runMetalSynchronouslyOnVideoProcessingQueue(^{
            
            MTLInt *radiusBuffer = (MTLInt *)[_radiusBuffer contents];
            radiusBuffer[0] = (MTLInt)radius+1;
            
            _gaussianKernelBuffer = [[MetalDevice sharedMTLDevice] newBufferWithBytes:buffer
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
