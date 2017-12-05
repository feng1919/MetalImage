//
//  MILuminanceThresholdFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/9/27.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MILuminanceThresholdFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@interface MILuminanceThresholdFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MILuminanceThresholdFilter

- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_luminanceThreshold"]) {
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _buffer = [device newBufferWithLength:sizeof(MTLFloat) options:MTLResourceOptionCPUCacheModeDefault];
        self.threshold = 0.0f;
    }
    return self;
}

- (void)dealloc {
    _buffer = nil;
}

- (void)setThreshold:(MTLFloat)threshold {
    if (_threshold != threshold) {
        _threshold = threshold;
        
        MTLFloat *bufferContent = [_buffer contents];
        bufferContent[0] = threshold;
    }
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
