//
//  MIAdaptiveLuminanceFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2021/2/19.
//  Copyright © 2021 fengshi. All rights reserved.
//

#import "MIAdaptiveLuminanceFilter.h"
#import "MetalDevice.h"

@interface MIAdaptiveLuminanceFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MIAdaptiveLuminanceFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_adaptiveLuminance"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.scale = 1.0;
    self.offset = 0.0;
    
    return self;
}

- (void)setScale:(MTLFloat)scale {
    _scale = scale;
    [self updateContentBuffer];
}

- (void)setOffset:(MTLFloat)offset {
    _offset = offset;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _scale;
    bufferContents[1] = _offset;
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
