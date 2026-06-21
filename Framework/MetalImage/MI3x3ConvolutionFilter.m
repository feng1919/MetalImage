//
//  MI3x3ConvolutionFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/18.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MI3x3ConvolutionFilter.h"
#import "MetalDevice.h"

@implementation MI3x3ConvolutionFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_Convolution3x3Filter"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*9 options:MTLResourceOptionCPUCacheModeDefault];
    
    MTLFloat3x3 convolutionKernel;
    convolutionKernel.v1 = MTLFloat3Make(0.0, 0.0, 0.0);
    convolutionKernel.v2 = MTLFloat3Make(0.0, 1.0, 0.0);
    convolutionKernel.v3 = MTLFloat3Make(0.0, 0.0, 0.0);
    self.convolutionKernel = convolutionKernel;
    
    return self;
}

- (void)setConvolutionKernel:(MTLFloat3x3)convolutionKernel {
    _convolutionKernel = convolutionKernel;
    
    MTLFloat3x3 *contentBuffer = (MTLFloat3x3 *)[_buffer contents];
    contentBuffer[0] = _convolutionKernel;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:self.texelSizeBuffer offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
