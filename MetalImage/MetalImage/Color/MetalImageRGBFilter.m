//
//  MetalImageRGBFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/8/15.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageRGBFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@interface MetalImageRGBFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageRGBFilter

- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_rgbAdjustment"]) {
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _buffer = [device newBufferWithLength:sizeof(MTLFloat3) options:MTLResourceOptionCPUCacheModeDefault];
        _red = 1.0f;
        _green = 1.0f;
        _blue = 1.0f;
        
        [self updateBufferContents];
    }
    return self;
}

- (void)setRed:(MTLFloat)red {
    _red = red;
    [self updateBufferContents];
}

- (void)setGreen:(MTLFloat)green {
    _green = green;
    [self updateBufferContents];
}

- (void)setBlue:(MTLFloat)blue {
    _blue = blue;
    [self updateBufferContents];
}

- (void)updateBufferContents {
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _red;
    bufferContents[1] = _green;
    bufferContents[2] = _blue;
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
