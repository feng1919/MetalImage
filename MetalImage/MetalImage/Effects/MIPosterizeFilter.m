//
//  MIPosterizeFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIPosterizeFilter.h"
#import "MetalDevice.h"

@interface MIPosterizeFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MIPosterizeFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_posterize"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*1 options:MTLResourceOptionCPUCacheModeDefault];
    self.colorLevels = 10;
    
    return self;
}

- (void)setColorLevels:(MTLUInt)colorLevels {
    _colorLevels = colorLevels;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = (MTLFloat)_colorLevels;
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
