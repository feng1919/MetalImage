//
//  MISwirlFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MISwirlFilter.h"
#import "MetalDevice.h"

@interface MISwirlFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MISwirlFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_swirlFilter"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*4 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.radius = 0.5;
    self.angle = 1.0;
    self.center = MTLFloat2Make(0.5, 0.5);
    
    return self;
}

- (void)setRadius:(MTLFloat)radius {
    _radius = radius;
    [self updateContentBuffer];
}

- (void)setAngle:(MTLFloat)angle {
    _angle = angle;
    [self updateContentBuffer];
}

- (void)setCenter:(MTLFloat2)center {
    _center = center;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _center.x;
    bufferContents[1] = _center.y;
    bufferContents[2] = _radius;
    bufferContents[3] = _angle;
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
