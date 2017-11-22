//
//  MetalImageHistogramGenerator.m
//  MetalImage
//
//  Created by fengshi on 2017/9/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageHistogramGenerator.h"
#import "MetalDevice.h"

@interface MetalImageHistogramGenerator()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageHistogramGenerator

- (id)init
{
    if (!(self = [super initWithVertexFunctionName:@"vertex_histogramGenerator"
                              fragmentFunctionName:@"fragment_histogramGenerator"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*4 options:MTLResourceOptionCPUCacheModeDefault];
    self.backgroundColor = MTLFloat4Make(0.0, 0.0, 0.0, 0.0);
    
    return self;
}

- (void)setBackgroundColor:(MTLFloat4)backgroundColor {
    _backgroundColor = backgroundColor;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _backgroundColor.x;
    bufferContents[1] = _backgroundColor.y;
    bufferContents[2] = _backgroundColor.z;
    bufferContents[3] = _backgroundColor.w;
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
