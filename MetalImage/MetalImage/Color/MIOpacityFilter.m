//
//  MIOpacityFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/8/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIOpacityFilter.h"
#import "MetalDevice.h"

@interface MIOpacityFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MIOpacityFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_opacity"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.opacity = 1.0;
    
    return self;
}

- (void)setOpacity:(MTLFloat)opacity {
    _opacity = opacity;
    
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _opacity;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    NSParameterAssert(renderEncoder);
    
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
