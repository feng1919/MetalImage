//
//  MetalImageHazeFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/8/23.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageHazeFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@implementation MetalImageHazeFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_haze"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.distance = 0.2;
    self.slope = 0.0;
    
    return self;
}


#pragma mark - Accessors

- (void)setDistance:(CGFloat)distance {
    _distance = distance;
    [self updateContentBuffer];
}

- (void)setSlope:(CGFloat)slope {
    _slope = slope;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _distance;
    bufferContents[1] = _slope;
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
