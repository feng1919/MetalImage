//
//  MIPerlinNoiseFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIPerlinNoiseFilter.h"
#import "MetalDevice.h"

@interface MIPerlinNoiseFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MIPerlinNoiseFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_perlinNoise"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*9 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.scale = 32.0f;
    self.colorStart = MTLFloat4Make(0.0, 0.0, 0.0, 1.0);
    self.colorFinish = MTLFloat4Make(1.0, 1.0, 1.0, 1.0);
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setScale:(MTLFloat)scale
{
    _scale = scale;
    
    [self updateContentBuffer];
}

- (void)setColorStart:(MTLFloat4)colorStart
{
    _colorStart = colorStart;
    
    [self updateContentBuffer];
}

- (void)setColorFinish:(MTLFloat4)colorFinish
{
    _colorFinish = colorFinish;
    
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _colorStart.x;
    bufferContents[1] = _colorStart.y;
    bufferContents[2] = _colorStart.z;
    bufferContents[3] = _colorStart.w;
    bufferContents[4] = _colorFinish.x;
    bufferContents[5] = _colorFinish.y;
    bufferContents[6] = _colorFinish.z;
    bufferContents[7] = _colorFinish.w;
    bufferContents[8] = _scale;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
//    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
