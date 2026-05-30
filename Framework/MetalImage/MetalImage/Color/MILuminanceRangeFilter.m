//
//  MILuminanceRangeFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/8/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MILuminanceRangeFilter.h"
#import "MetalDevice.h"

@interface MILuminanceRangeFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MILuminanceRangeFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_whiteBalance"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.rangeReductionFactor = 0.6;
    
    return self;
}

- (void)setRangeReductionFactor:(CGFloat)rangeReductionFactor {
    _rangeReductionFactor = rangeReductionFactor;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _rangeReductionFactor;
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
