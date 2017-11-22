//
//  MetalImageCommonFilter.m
//  MetalImage
//
//  Created by keyishen on 2017/7/25.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "MetalImageCommonFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"
#import <MetalKit/MetalKit.h>

@implementation MetalImageCommonFilter

- (instancetype)init {
    if (self = [super init]) {
  
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        UIImage *image = [UIImage imageNamed:@"00005.png"];
        MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:device];
        NSError *error = nil;
        
        self.lutTexture = [loader newTextureWithCGImage:image.CGImage options:@{MTKTextureLoaderOptionSRGB:@(NO)} error:&error];
        NSLog(@"lutTexture=%@, error=%@", self.lutTexture, error);
    }
    return self;
}

- (BOOL)prepareRenderPassDescriptor {
    
    _renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    MTLRenderPassColorAttachmentDescriptor    *colorAttachment  = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.loadAction = MTLLoadActionLoad;
    colorAttachment.clearColor = self.bgClearColor;
    colorAttachment.storeAction = MTLStoreActionStore;
    
    return _renderPassDescriptor != nil;
}
- (void)renderToTextureWithVertices:(const MTLFloat4 *)vertices textureCoordinates:(const MTLFloat2 *)textureCoordinates {
    
#define PosValue 0.75f
#define VertexA1 { -PosValue,  -PosValue, 0.0f, PosValue }
#define VertexB1 {  PosValue,  -PosValue, 0.0f, PosValue }
#define VertexC1 { -PosValue,   PosValue, 0.0f, PosValue }
#define VertexD1 {  PosValue,   PosValue, 0.0f, PosValue }
    MTLFloat4 imageVertices[] = {VertexA1,VertexB1,VertexC1,VertexD1};
    
    [self updateTextureVertexBuffer:_verticsBuffer contents:imageVertices size:MetalImageDefaultRenderVetexCount];
    
    
#define A {0.0f, PosValue}
#define B {PosValue, PosValue}
#define C {0.0f, 0.0f}
#define D {PosValue, 0.0f}
    
    static const MTLFloat2 noRotationTextureCoordinates[] = {A,B,C,D};
    
    [self updateTextureCoordinateBuffer:_coordBuffer contents:noRotationTextureCoordinates size:MetalImageDefaultRenderVetexCount];
    
    id<MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
    
    outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:[self textureSizeForOutput]];
    
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.texture = [outputTexture texture];
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
    NSAssert(renderEncoder != nil, @"Create render encoder failed...");
    [self assembleRenderEncoder:renderEncoder];
    
    [firstInputTexture unlock];
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    {
        [renderEncoder setDepthStencilState:_depthStencilState];
        [renderEncoder setRenderPipelineState:_pipelineState];
#define PosValue 0.25f
#define VertexA1 { -PosValue,  -PosValue, 0.0f, PosValue }
#define VertexB1 {  PosValue,  -PosValue, 0.0f, PosValue }
#define VertexC1 { -PosValue,   PosValue, 0.0f, PosValue }
#define VertexD1 {  PosValue,   PosValue, 0.0f, PosValue }
        MTLFloat4 imageVertices[] = {VertexA1,VertexB1,VertexC1,VertexD1};
        
        [self updateTextureVertexBuffer:_verticsBuffer contents:imageVertices size:MetalImageDefaultRenderVetexCount];
        
        [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
        [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
        [renderEncoder setFragmentTexture:self.lutTexture atIndex:0];
        //    [renderEncoder setFragmentTexture:self.lutTexture atIndex:1];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    }
    
//    {
//        [renderEncoder setDepthStencilState:_depthStencilState];
//        [renderEncoder setRenderPipelineState:_pipelineState];
//        [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
//        [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
//        [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
//    //    [renderEncoder setFragmentTexture:self.lutTexture atIndex:1];
//        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
//    }
//indices:[Int32] = [
//                   0, 1, 2,
//                   0, 2, 3
//                   ];
//    MTLFloat4 imageScalingVertics[4];
//    indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * 4, options: MTLResourceOptions(rawValue: UInt(0))) indexBuffer.label = "Indices"
//    
//    [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangleStrip indexCount:8 indexType:MTLIndexTypeUInt32 indexBuffer:_verticsBuffer indexBufferOffset:0];
//    renderEncoder.drawIndexedPrimitives(
    [renderEncoder endEncoding];
}

@end
