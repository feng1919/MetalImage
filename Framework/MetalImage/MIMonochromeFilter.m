//
//  MIMonochromeFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/7/22.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIMonochromeFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@interface MIMonochromeFilter()

@end

@implementation MIMonochromeFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_monochrome"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*4 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.intensity = 1.0;
    self.color = MTLFloat4Make(0.6f, 0.45f, 0.3f, 1.f);
    
    return self;
}


#pragma mark - Accessors

- (void)setColor:(MTLFloat4)color
{
    _color = color;
    
    [self updateContentBuffer];
}

- (void)setIntensity:(CGFloat)newValue;
{
    _intensity = newValue;
    
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _color.x;
    bufferContents[1] = _color.y;
    bufferContents[2] = _color.z;
    bufferContents[3] = _intensity;
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
