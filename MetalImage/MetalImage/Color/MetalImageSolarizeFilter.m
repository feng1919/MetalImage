//
//  MetalImageSolarizeFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/9/2.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageSolarizeFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@interface MetalImageSolarizeFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageSolarizeFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_solarize"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.threshold = 0.5;
    
    return self;
}

- (void)setThreshold:(CGFloat)threshold {
    _threshold = threshold;
    
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _threshold;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}


@end
