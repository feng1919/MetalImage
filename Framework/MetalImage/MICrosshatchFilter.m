//
//  MICrosshatchFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MICrosshatchFilter.h"
#import "MetalImageFilterExtension.h"
#import "MetalDevice.h"

@interface MICrosshatchFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MICrosshatchFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_crosshatch"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.crossHatchSpacing = 0.03;
    self.lineWidth = 0.003;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setCrossHatchSpacing:(MTLFloat)newValue;
{
    MTLFloat inputTextureWidth = firstInputTexture.size.x;
    CGFloat singlePixelSpacing;
    if (inputTextureWidth != 0.0)
    {
        singlePixelSpacing = 1.0 / inputTextureWidth;
    }
    else
    {
        singlePixelSpacing = 1.0 / 2048.0;
    }
    
    if (newValue < singlePixelSpacing)
    {
        _crossHatchSpacing = singlePixelSpacing;
    }
    else
    {
        _crossHatchSpacing = newValue;
    }
    
    [self updateContentBuffer];
}

- (void)setLineWidth:(MTLFloat)newValue;
{
    _lineWidth = newValue;
    
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _crossHatchSpacing;
    bufferContents[1] = _lineWidth;
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
