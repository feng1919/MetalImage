//
//  MetalImageExposureFilter.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageExposureFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@interface MetalImageExposureFilter()

@property (nonatomic,strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageExposureFilter


- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_exposure"]) {
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _buffer = [device newBufferWithLength:sizeof(MTLFloat) options:MTLResourceOptionCPUCacheModeDefault];
        self.exposure = 0.0f;
    }
    return self;
}

- (void)dealloc {
    _buffer = nil;
}

- (void)setExposure:(MTLFloat)exposure {
    _exposure = exposure;
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _exposure;
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
