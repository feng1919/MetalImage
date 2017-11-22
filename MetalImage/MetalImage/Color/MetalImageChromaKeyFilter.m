//
//  MetalImageChromaKeyFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/8/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageChromaKeyFilter.h"
#import "MetalDevice.h"

@interface MetalImageChromaKeyFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageChromaKeyFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_chromaKey"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*5 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.thresholdSensitivity = 0.4;
    self.smoothing = 0.1;
    self.colorToReplace = MTLFloat3Make(0.0, 1.0, 0.0);
    
    return self;
}

- (void)setColorToReplace:(MTLFloat3)colorToReplace {
    _colorToReplace = colorToReplace;
    [self updateContentBuffer];
}

- (void)setSmoothing:(MTLFloat)smoothing {
    _smoothing = smoothing;
    [self updateContentBuffer];
}

- (void)setThresholdSensitivity:(MTLFloat)thresholdSensitivity {
    _thresholdSensitivity = thresholdSensitivity;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _colorToReplace.x;
    bufferContents[1] = _colorToReplace.y;
    bufferContents[2] = _colorToReplace.z;
    bufferContents[3] = _smoothing;
    bufferContents[4] = _thresholdSensitivity;
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
