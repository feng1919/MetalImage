//
//  MetalImageHighlightShadowFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/7/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageHighlightShadowFilter.h"
#import "MetalDevice.h"

@interface MetalImageHighlightShadowFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageHighlightShadowFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_highlightShadow"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.shadows = 0.0;
    self.highlights = 1.0;
    
    return self;
}


- (void)setShadows:(MTLFloat)newValue;
{
    _shadows = newValue;
    
    [self updateContentBuffer];
}

- (void)setHighlights:(MTLFloat)newValue;
{
    _highlights = newValue;
    
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _shadows;
    bufferContents[1] = _highlights;
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
