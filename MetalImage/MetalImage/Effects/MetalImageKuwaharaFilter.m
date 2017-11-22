//
//  MetalImageKuwaharaFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageKuwaharaFilter.h"
#import "MetalImageFilterExtension.h"
#import "MetalDevice.h"

@interface MetalImageKuwaharaFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageKuwaharaFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_KuwaharaFilter"]))
    {
        return nil;
    }
    
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*1 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.radius = 3;
    
    return self;
}

- (void)setRadius:(NSUInteger)radius {
    _radius = radius;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = (MTLFloat)_radius;
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
