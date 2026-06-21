//
//  MetalImageTwoPassFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoPassFilter.h"
#import "MetalDevice.h"
#import <UIKit/UIKit.h>

@implementation MetalImageTwoPassFilter

- (nonnull instancetype)initWithFirstStageFragmentFunctionName:(nonnull NSString *)firstStageFragmentFunctionName
                               secondStageFragmentFunctionName:(nonnull NSString *)secondStageFragmentFunctionName
{
    return [self initWithFirstStageVertexFunctionName:@"vertex_common"
                       firstStageFragmentFunctionName:firstStageFragmentFunctionName
                        secondStageVertexFunctionName:@"vertex_common"
                      secondStageFragmentFunctionName:secondStageFragmentFunctionName];
}

- (nonnull instancetype)initWithFirstStageFragmentFunction:(nonnull id<MTLFunction>)firstStageFragmentFunction
                               secondStageFragmentFunction:(nonnull id<MTLFunction>)secondStageFragmentFunction
{
    NSParameterAssert(firstStageFragmentFunction);
    id<MTLLibrary> defaultLibrary = [MetalDevice MetalImageLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertex_common"];
    
    return [self initWithFirstStageVertexFunction:vertexFunction
                       firstStageFragmentFunction:firstStageFragmentFunction
                        secondStageVertexFunction:vertexFunction
                      secondStageFragmentFunction:secondStageFragmentFunction];
}

- (instancetype)initWithFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString
                      firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString
                       secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString
                     secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString
{
#warning TODO
    return nil;
}

- (nonnull instancetype)initWithFirstStageVertexFunctionName:(nonnull NSString *)firstStageVertexFunctionName
                              firstStageFragmentFunctionName:(nonnull NSString *)firstStageFragmentFunctionName
                               secondStageVertexFunctionName:(nonnull NSString *)secondStageVertexFunctionName
                             secondStageFragmentFunctionName:(nonnull NSString *)secondStageFragmentFunctionName
{
    NSParameterAssert(firstStageVertexFunctionName);
    NSParameterAssert(firstStageFragmentFunctionName);
    NSParameterAssert(secondStageVertexFunctionName);
    NSParameterAssert(secondStageFragmentFunctionName);
    
    //iOS8.0上newDefaultLibrary返回为空的bug
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0f) {
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:@"/"];
    }
    
    //    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    id<MTLLibrary> defaultLibrary = [MetalDevice MetalImageLibrary];
    id<MTLFunction> firstStageVertexFunction = [defaultLibrary newFunctionWithName:firstStageVertexFunctionName];
    NSParameterAssert(firstStageVertexFunction);
    id<MTLFunction> firstStageFragmentFunction = [defaultLibrary newFunctionWithName:firstStageFragmentFunctionName];
    NSParameterAssert(firstStageFragmentFunction);
    id<MTLFunction> secondStageVertexFunction = [defaultLibrary newFunctionWithName:secondStageVertexFunctionName];
    NSParameterAssert(secondStageVertexFunction);
    id<MTLFunction> secondStageFragmentFunction = [defaultLibrary newFunctionWithName:secondStageFragmentFunctionName];
    NSParameterAssert(secondStageFragmentFunction);
    
    self = [super initWithVertexFunction:firstStageVertexFunction fragmentFunction:firstStageFragmentFunction];
    NSParameterAssert(self);
    
    if (self) {
        
        _secondStageVertexFunction = secondStageVertexFunction;
        _secondStageFragmetnFunction = secondStageFragmentFunction;
        
        [self createSecondTextureCoordinateBuffer];
        [self prepareSecondRenderPipeline];
        [self prepareSecondRenderDepthStencilState];
        [self prepareSecondRenderPassDescriptor];
    }
    return self;
}

- (nonnull instancetype)initWithFirstStageVertexFunction:(nonnull id<MTLFunction>)firstStageVertexFunction
                              firstStageFragmentFunction:(nonnull id<MTLFunction>)firstStageFragmentFunction
                               secondStageVertexFunction:(nonnull id<MTLFunction>)secondStageVertexFunction
                             secondStageFragmentFunction:(nonnull id<MTLFunction>)secondStageFragmentFunction
{
    if (self = [super initWithVertexFunction:firstStageVertexFunction fragmentFunction:firstStageFragmentFunction]) {
        NSParameterAssert(secondStageVertexFunction);
        NSParameterAssert(secondStageFragmentFunction);
        
        _secondStageVertexFunction = secondStageVertexFunction;
        _secondStageFragmetnFunction = secondStageFragmentFunction;
        
        [self createSecondTextureCoordinateBuffer];
        [self prepareSecondRenderPipeline];
        [self prepareSecondRenderDepthStencilState];
        [self prepareSecondRenderPassDescriptor];
    }
    return self;
}

- (void)createSecondTextureCoordinateBuffer {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _secondCoordBuffer = [device newBufferWithLength:MetalImageDefaultRenderVetexCount*sizeof(MTLFloat2)
                                       options:MTLResourceOptionCPUCacheModeDefault];
    _secondCoordBuffer.label = @"default texcoords";
}

- (BOOL)prepareSecondRenderPipeline {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    
    MTLRenderPipelineDescriptor *pQuadPipelineStateDescriptor = [MTLRenderPipelineDescriptor new];
    pQuadPipelineStateDescriptor.depthAttachmentPixelFormat      = MTLPixelFormatInvalid;
    pQuadPipelineStateDescriptor.stencilAttachmentPixelFormat    = MTLPixelFormatInvalid;
    pQuadPipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pQuadPipelineStateDescriptor.sampleCount                     = 1;
    pQuadPipelineStateDescriptor.vertexFunction                  = _secondStageVertexFunction;
    pQuadPipelineStateDescriptor.fragmentFunction                = _secondStageFragmetnFunction;
    
    NSError *pError = nil;
    _secondStagePipelineState = [device newRenderPipelineStateWithDescriptor:pQuadPipelineStateDescriptor error:&pError];
    if (pError) {
        NSLog(@">> ERROR: Failed acquiring pipeline state descriptor: %@", pError);
    }
    
    return _secondStagePipelineState != nil;
}

- (BOOL)prepareSecondRenderDepthStencilState {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    MTLDepthStencilDescriptor *pDepthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    
    if (!pDepthStateDesc) {
        NSLog(@">> ERROR: Failed creating a depth stencil descriptor!");
        return NO;
    }
    
    //    pDepthStateDesc.depthCompareFunction = MTLCompareFunctionNever;
    //    pDepthStateDesc.depthWriteEnabled    = NO;
    _secondStageDepthStencilState = [device newDepthStencilStateWithDescriptor:pDepthStateDesc];
    
    return _secondStageDepthStencilState != nil;
}

- (BOOL)prepareSecondRenderPassDescriptor {
    
    _secondStageRenderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    MTLRenderPassColorAttachmentDescriptor    *colorAttachment  = _secondStageRenderPassDescriptor.colorAttachments[0];
    colorAttachment.loadAction = MTLLoadActionClear;
    colorAttachment.clearColor = self.bgClearColor;
    colorAttachment.storeAction = MTLStoreActionStore;
    
    return _secondStageRenderPassDescriptor != nil;
}

- (void)renderToTextureWithVertices:(const MTLFloat4 *)vertices textureCoordinates:(const MTLFloat2 *)textureCoordinates {
    NSParameterAssert(vertices);
    NSParameterAssert(textureCoordinates);
    
    [self updateTextureVertexBuffer:_verticsBuffer
                    withNewContents:vertices
                               size:MetalImageDefaultRenderVetexCount];
    [self updateTextureCoordinateBuffer:_coordBuffer
                        withNewContents:textureCoordinates
                                   size:MetalImageDefaultRenderVetexCount];
    
    id<MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
    
    secondOutputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:[self textureSizeForOutput]];
    NSParameterAssert(secondOutputTexture);
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.texture = [secondOutputTexture texture];
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
    NSAssert(renderEncoder != nil, @"Create render encoder failed...");
    [self assembleRenderEncoder:renderEncoder];
    [firstInputTexture unlock];
    
    [self updateTextureCoordinateBuffer:_secondCoordBuffer
                        withNewContents:TextureCoordinatesForRotation(kMetalImageNoRotation)
                                   size:MetalImageDefaultRenderVetexCount];
    outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:[self textureSizeForOutput]];
    NSParameterAssert(outputTexture);
    MTLRenderPassColorAttachmentDescriptor *colorAttachment1 = _secondStageRenderPassDescriptor.colorAttachments[0];
    colorAttachment1.texture = [outputTexture texture];
    id<MTLRenderCommandEncoder> secondStageRenderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_secondStageRenderPassDescriptor];
    NSAssert(secondStageRenderEncoder != nil, @"Create second stage render encoder failed...");
    [self assembleSecondStageRenderEncoder:secondStageRenderEncoder];
    [secondOutputTexture unlock];
}

- (void)assembleSecondStageRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_secondStageDepthStencilState];
    [renderEncoder setRenderPipelineState:_secondStagePipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_secondCoordBuffer offset:0 atIndex:1];
    [renderEncoder setFragmentTexture:[secondOutputTexture texture] atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
