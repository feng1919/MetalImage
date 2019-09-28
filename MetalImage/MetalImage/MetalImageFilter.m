//
//  MetalImageFilter.m
//  MetalImage
//
//  Created by stonefeng on 2017/2/11.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"
#import "MetalImageFunction.h"
#import "MetalImageTextureCache.h"
#import "MetalDevice.h"
#import <UIKit/UIKit.h>

@implementation MetalImageFilter

- (instancetype)init {
    return [self initWithVertexFunctionName:@"vertex_common" fragmentFunctionName:@"fragment_common"];
}

- (instancetype)initWithFragmentFunctionName:(NSString *)fragmentFunctionName {
    return [self initWithVertexFunctionName:@"vertex_common" fragmentFunctionName:fragmentFunctionName];
}

- (instancetype)initWithFragmentFunction:(id<MTLFunction>)fragmentFunction {
    NSParameterAssert(fragmentFunction);
    id<MTLLibrary> defaultLibrary = [MetalDevice MetalImageLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertex_common"];
    return [self initWithVertexFunction:vertexFunction fragmentFunction:fragmentFunction];
}

- (instancetype)initWithVertexFunctionName:(NSString *)vertexFunctionName fragmentFunctionName:(NSString *)fragmentFunctionName {
    NSParameterAssert(vertexFunctionName);
    NSParameterAssert(fragmentFunctionName);
    
    //iOS8.0上newDefaultLibrary返回为空的bug
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0f) {
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:@"/"];
    }
    
    //    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    id<MTLLibrary> defaultLibrary = [MetalDevice MetalImageLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:vertexFunctionName];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:fragmentFunctionName];
    return [self initWithVertexFunction:vertexFunction fragmentFunction:fragmentFunction];
}

- (instancetype)initWithVertexFunction:(id<MTLFunction>)vertexFunction fragmentFunction:(id<MTLFunction>)fragmentFunction {
    if (self = [super init]) {
        NSParameterAssert(vertexFunction);
        NSParameterAssert(fragmentFunction);
        
        _vertexFunction = vertexFunction;
        _fragmentFunction = fragmentFunction;
        _bgClearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0f);
        
        firstInputParameter.frameTime = kCMTimeInvalid;
        firstInputParameter.frameCheckDisabled = NO;
        firstInputParameter.hasReceivedFrame = NO;
        firstInputParameter.hasSetTarget = NO;
        firstInputParameter.rotationMode = kMetalImageNoRotation;
        
//        vertexBufferArray = [NSMutableArray array];
//        fragmentBufferArray = [NSMutableArray array];
//        vertexTextureArray = [NSMutableArray array];
//        fragmentTextureArray = [NSMutableArray array];
        
        [self createTextureVertexBuffer];
        [self createTextureCoordinateBuffer];
        [self prepareRenderPipeline];
        [self prepareRenderDepthStencilState];
        [self prepareRenderPassDescriptor];
    }
    return self;
}

- (void)createTextureVertexBuffer {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _verticsBuffer = [device newBufferWithLength:MetalImageDefaultRenderVetexCount*sizeof(MTLFloat4)
                                         options:MTLResourceOptionCPUCacheModeDefault];
    _verticsBuffer.label = @"default vertices";
}

- (void)createTextureCoordinateBuffer {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _coordBuffer = [device newBufferWithLength:MetalImageDefaultRenderVetexCount*sizeof(MTLFloat2)
                                       options:MTLResourceOptionCPUCacheModeDefault];
    _coordBuffer.label = @"default texcoords";
}

- (BOOL)prepareRenderPipeline {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    
    MTLRenderPipelineDescriptor *pQuadPipelineStateDescriptor = [MTLRenderPipelineDescriptor new];
    pQuadPipelineStateDescriptor.depthAttachmentPixelFormat      = MTLPixelFormatInvalid;
    pQuadPipelineStateDescriptor.stencilAttachmentPixelFormat    = MTLPixelFormatInvalid;
    pQuadPipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pQuadPipelineStateDescriptor.rasterSampleCount               = 1;
    pQuadPipelineStateDescriptor.vertexFunction                  = _vertexFunction;
    pQuadPipelineStateDescriptor.fragmentFunction                = _fragmentFunction;
    
    NSError *pError = nil;
    _pipelineState = [device newRenderPipelineStateWithDescriptor:pQuadPipelineStateDescriptor error:&pError];
    if (pError) {
        NSLog(@">> ERROR: Failed acquiring pipeline state descriptor: %@", pError);
        NSParameterAssert(NO);
    }
    
    return _pipelineState != nil;
}

- (BOOL)prepareRenderDepthStencilState {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    MTLDepthStencilDescriptor *pDepthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    
    if (!pDepthStateDesc) {
        NSLog(@">> ERROR: Failed creating a depth stencil descriptor!");
    }
    
    //    pDepthStateDesc.depthCompareFunction = MTLCompareFunctionNever;
    //    pDepthStateDesc.depthWriteEnabled    = NO;
    _depthStencilState = [device newDepthStencilStateWithDescriptor:pDepthStateDesc];
    
    return _depthStencilState != nil;
}

- (BOOL)prepareRenderPassDescriptor {
    
    _renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    MTLRenderPassColorAttachmentDescriptor    *colorAttachment  = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.loadAction = MTLLoadActionClear;
    colorAttachment.clearColor = _bgClearColor;
    colorAttachment.storeAction = MTLStoreActionStore;
    
    return _renderPassDescriptor != nil;
}

- (MTLUInt2)textureSizeForOutput {
    if (MTLUInt2IsZero(_outputImageSize)) {
        MTLUInt2 textureSize = [firstInputTexture size];
        return MetalImageRotationSwapsWidthAndHeight(firstInputParameter.rotationMode)?MTLUInt2Make(textureSize.y, textureSize.x):textureSize;
    }
    else {
        return _outputImageSize;
    }
}

- (MetalImageRotationMode)rotationForOutput {
    return kMetalImageNoRotation;
}

- (void)updateTextureVertexBuffer:(id<MTLBuffer>)buffer withNewContents:(const MTLFloat4 *)newContents size:(size_t)size {
    NSParameterAssert(buffer);
    NSParameterAssert(newContents);
    
    MTLFloat4 *contents = (MTLFloat4 *)[buffer contents];
    for (int i = 0; i < size; i++) {
        contents[i] = newContents[i];
    }
}

- (void)updateTextureCoordinateBuffer:(id<MTLBuffer>)buffer withNewContents:(const MTLFloat2 *)newContents size:(size_t)size {
    NSParameterAssert(buffer);
    NSParameterAssert(newContents);
    
    MTLFloat2 *contents = (MTLFloat2 *)[buffer contents];
    for (int i = 0; i < size; i++) {
        contents[i] = newContents[i];
    }
}

- (void)renderToTextureWithVertices:(const MTLFloat4 *)vertices textureCoordinates:(const MTLFloat2 *)textureCoordinates {
    NSParameterAssert(vertices);
    NSParameterAssert(textureCoordinates);
    
    [self updateTextureVertexBuffer:_verticsBuffer withNewContents:vertices size:MetalImageDefaultRenderVetexCount];
    [self updateTextureCoordinateBuffer:_coordBuffer withNewContents:textureCoordinates size:MetalImageDefaultRenderVetexCount];
    
    id<MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];

    outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:[self textureSizeForOutput]];
    NSParameterAssert(outputTexture);
    
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.texture = [outputTexture texture];
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
    NSAssert(renderEncoder != nil, @"Create render encoder failed...");
    [self assembleRenderEncoder:renderEncoder];
    
    [firstInputTexture unlock];
}

#pragma mark - MetalImageInput delegate
- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    NSParameterAssert(newInputTexture);
    
    firstInputTexture = newInputTexture;
    [firstInputTexture lock];
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    firstInputParameter.rotationMode = newInputRotation;
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    firstInputParameter.frameTime = frameTime;
    
    [self renderToTextureWithVertices:MetalImageDefaultRenderVetics
                   textureCoordinates:TextureCoordinatesForRotation(firstInputParameter.rotationMode)];
    
    [self notifyTargetsAboutNewTextureAtTime:frameTime];
}

#pragma mark - set up render resources
#warning TODO

- (void)setVertexBuffer:(id <MTLBuffer>)buffer offset:(NSUInteger)offset atIndex:(NSUInteger)index {
    
}

- (void)setVertexTexture:(id <MTLTexture>)texture atIndex:(NSUInteger)index {
    
}

- (void)setFragmentBuffer:(id <MTLBuffer>)buffer offset:(NSUInteger)offset atIndex:(NSUInteger)index {
    
}

- (void)setFragmentTexture:(id <MTLTexture>)texture atIndex:(NSUInteger)index {
    
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
