//
//  MetalImagePixellateFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImagePixellateFilter.h"
#import "MetalDevice.h"

@implementation MetalImagePixellateFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_PixellateFilter"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.fractionalWidthOfAPixel = 0.05;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)adjustAspectRatio;
{
    MTLFloat inputTextureWidth = (MTLFloat)firstInputTexture.size.x;
    MTLFloat inputTextureHeight = (MTLFloat)firstInputTexture.size.y;
    
    if (MetalImageRotationSwapsWidthAndHeight(firstInputParameter.rotationMode))
    {
        [self setAspectRatio:(inputTextureHeight / inputTextureWidth)];
    }
    else
    {
        [self setAspectRatio:(inputTextureWidth / inputTextureHeight)];
    }
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [self adjustAspectRatio];
}

- (void)setAspectRatio:(MTLFloat)newValue {
    _aspectRatio = newValue;
    
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[1] = _aspectRatio;
}

- (void)setFractionalWidthOfAPixel:(MTLFloat)fractionalWidthOfAPixel {
    _fractionalWidthOfAPixel = fractionalWidthOfAPixel;
    
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _fractionalWidthOfAPixel;
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
