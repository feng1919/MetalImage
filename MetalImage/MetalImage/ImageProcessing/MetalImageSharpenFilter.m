//
//  MetalImageSharpenFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/16.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageSharpenFilter.h"
#import "MetalDevice.h"

@interface MetalImageSharpenFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageSharpenFilter

#pragma mark - Initialization and teardown

- (id)init
{
    if (!(self = [super initWithVertexFunctionName:@"vertex_SharpenFilter"
                              fragmentFunctionName:@"fragment_SharpenFilter"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*3 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.sharpness = 1.0f;
    
    return self;
}

#pragma mark - Accessors

- (void)setSharpness:(MTLFloat)newValue;
{
    _sharpness = newValue;
    
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[2] = _sharpness;
}

#pragma mark - render

- (void)renderToTextureWithVertices:(const MTLFloat4 *)vertices textureCoordinates:(const MTLFloat2 *)textureCoordinates {
    NSParameterAssert(vertices);
    NSParameterAssert(textureCoordinates);
    
    [self updateTextureVertexBuffer:_verticsBuffer withNewContents:vertices size:MetalImageDefaultRenderVetexCount];
    [self updateTextureCoordinateBuffer:_coordBuffer withNewContents:textureCoordinates size:MetalImageDefaultRenderVetexCount];
    
    id<MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
    
    MTLUInt2 textureSize = [self textureSizeForOutput];
    outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:textureSize];
    NSParameterAssert(outputTexture);
    
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = 1.0f/(MTLFloat)textureSize.x;
    bufferContents[1] = 1.0f/(MTLFloat)textureSize.y;
    
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.texture = [outputTexture texture];
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
    NSAssert(renderEncoder != nil, @"Create render encoder failed...");
    [self assembleRenderEncoder:renderEncoder];
    
    [firstInputTexture unlock];
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_buffer offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}


@end
