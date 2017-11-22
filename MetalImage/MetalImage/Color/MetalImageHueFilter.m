//
//  MetalImageHueFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/7/22.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageHueFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@interface MetalImageHueFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageHueFilter

- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_hue"]) {
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _buffer = [device newBufferWithLength:sizeof(MTLFloat) options:MTLResourceOptionCPUCacheModeDefault];
        self.hue = 90;
    }
    return self;
}

- (void)setHue:(CGFloat)newHue
{
    // Convert degrees to radians for hue rotation
    _hue = fmodf(newHue, 360.0f) * M_PI/180.0f;
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _hue;
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
