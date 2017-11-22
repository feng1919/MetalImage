//
//  MetalImageWhiteBalanceFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/7/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageWhiteBalanceFilter.h"
#import "MetalDevice.h"

@interface MetalImageWhiteBalanceFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageWhiteBalanceFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_whiteBalance"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.temperature = 5000.0;
    self.tint = 0.0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setTemperature:(CGFloat)newValue;
{
    _temperature = newValue;
    
    [self updateContentBuffer];
}

- (void)setTint:(CGFloat)newValue;
{
    _tint = newValue;
    
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _temperature < 5000 ? 0.0004 * (_temperature-5000.0) : 0.00006 * (_temperature-5000.0);
    bufferContents[1] = _tint / 100.0;
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
