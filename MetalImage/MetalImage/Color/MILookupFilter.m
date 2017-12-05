//
//  MILookupFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/8/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MILookupFilter.h"
#import "MetalDevice.h"

@interface MILookupFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MILookupFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_lookup"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*1 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.intensity = 1.0f;
    
    return self;
}

- (void)setIntensity:(MTLFloat)intensity {
    _intensity = intensity;
    
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _intensity;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_coordBuffer2 offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentTexture:[secondInputTexture texture] atIndex:1];
    [renderEncoder setFragmentBuffer:_buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
