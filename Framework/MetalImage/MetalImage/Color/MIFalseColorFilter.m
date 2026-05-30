//
//  MIFalseColorFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/7/23.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIFalseColorFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@implementation MIFalseColorFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_falseColor"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*6 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.firstColor = MTLFloat4Make(0.0f, 0.0f, 0.5f, 1.0f);
    self.secondColor = MTLFloat4Make(1.0f, 0.0f, 0.0f, 1.0f);
    
    return self;
}


#pragma mark - Accessors

- (void)setFirstColor:(MTLFloat4)firstColor {
    _firstColor = firstColor;
    [self updateContentBuffer];
}

- (void)setSecondColor:(MTLFloat4)secondColor {
    _secondColor = secondColor;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _firstColor.x;
    bufferContents[1] = _firstColor.y;
    bufferContents[2] = _firstColor.z;
    bufferContents[3] = _secondColor.x;
    bufferContents[4] = _secondColor.y;
    bufferContents[5] = _secondColor.z;
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
