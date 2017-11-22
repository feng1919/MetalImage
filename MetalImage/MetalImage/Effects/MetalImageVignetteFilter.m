//
//  MetalImageVignetteFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageVignetteFilter.h"
#import "MetalImageFilterExtension.h"
#import "MetalDevice.h"

@interface MetalImageVignetteFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageVignetteFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_VignetteFilter"]))
    {
        return nil;
    }
    
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*7 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.vignetteCenter = MTLFloat2Make( 0.5f, 0.5f);
    self.vignetteColor = MTLFloat3Make( 0.0f, 0.0f, 0.0f);
    self.vignetteStart = 0.3;
    self.vignetteEnd = 0.75;
    
    return self;
}

- (void)setVignetteCenter:(MTLFloat2)vignetteCenter {
    _vignetteCenter = vignetteCenter;
    [self updateContentBuffer];
}

- (void)setVignetteColor:(MTLFloat3)vignetteColor {
    _vignetteColor = vignetteColor;
    [self updateContentBuffer];
}

- (void)setVignetteStart:(MTLFloat)vignetteStart {
    _vignetteStart = vignetteStart;
    [self updateContentBuffer];
}

- (void)setVignetteEnd:(MTLFloat)vignetteEnd {
    _vignetteEnd = vignetteEnd;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _vignetteCenter.x;
    bufferContents[1] = _vignetteCenter.y;
    bufferContents[2] = _vignetteColor.x;
    bufferContents[3] = _vignetteColor.y;
    bufferContents[4] = _vignetteColor.z;
    bufferContents[5] = _vignetteStart;
    bufferContents[6] = _vignetteEnd;
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
