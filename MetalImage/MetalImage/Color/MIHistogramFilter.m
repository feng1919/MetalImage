//
//  MIHistogramFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/11/3.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "MIHistogramFilter.h"
#import "MetalDevice.h"

@implementation MIHistogramFilter

- (instancetype)init {
    return [self initWithHistogramType:kMetalImageHistogramRGB];
}

- (id)initWithHistogramType:(MetalImageHistogramType)newHistogramType {
    
    NSString *vertexName = nil;
    
    switch (newHistogramType) {
        case kMetalImageHistogramRed:
            vertexName = @"vertex_redHistogramSampling";
            break;
            
        case kMetalImageHistogramBlue:
            vertexName = @"vertex_blueHistogramSampling";
            break;
            
        case kMetalImageHistogramGreen:
            vertexName = @"vertex_greenHistogramSampling";
            break;
            
        case kMetalImageHistogramLuminance:
            vertexName = @"vertex_luminanceHistogramSampling";
            break;
            
        case kMetalImageHistogramRGB:
            vertexName = @"vertex_redHistogramSampling";
            break;
            
        default:
            break;
    }
    
    histogramType = newHistogramType;
    
    if (self = [super initWithVertexFunctionName:vertexName fragmentFunctionName:@"fragment_histogramAccumulation"]) {
        self.downsamplingFactor = 16.0f;
        self.bgClearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0f);
    }
    
    return self;
}

- (void)dealloc {
//    if (vertexSamplingCoordinates != NULL && ![MetalImageTexture supportsFastTextureUpload]) {
//        free(vertexSamplingCoordinates);
//    }
}

- (MTLUInt2)textureSizeForOutput {
    return MTLUInt2Make(256, 3);
}

- (void)createTextureVertexBuffer {
}

- (void)createTextureCoordinateBuffer {
}

- (BOOL)prepareRenderPipeline {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    
    MTLRenderPipelineDescriptor *pQuadPipelineStateDescriptor = [MTLRenderPipelineDescriptor new];
    pQuadPipelineStateDescriptor.depthAttachmentPixelFormat      = MTLPixelFormatInvalid;
    pQuadPipelineStateDescriptor.stencilAttachmentPixelFormat    = MTLPixelFormatInvalid;
//    pQuadPipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pQuadPipelineStateDescriptor.sampleCount                     = 1;
    pQuadPipelineStateDescriptor.vertexFunction                  = _vertexFunction;
    pQuadPipelineStateDescriptor.fragmentFunction                = _fragmentFunction;
    
    MTLRenderPipelineColorAttachmentDescriptor *pipelineColorAttachment = [[MTLRenderPipelineColorAttachmentDescriptor alloc] init];
    [pipelineColorAttachment setBlendingEnabled:YES];
    [pipelineColorAttachment setSourceRGBBlendFactor:MTLBlendFactorOne];
    [pipelineColorAttachment setDestinationRGBBlendFactor:MTLBlendFactorOne];
    [pipelineColorAttachment setRgbBlendOperation:MTLBlendOperationAdd];
    [pipelineColorAttachment setPixelFormat:MTLPixelFormatBGRA8Unorm];
    [[pQuadPipelineStateDescriptor colorAttachments] setObject:pipelineColorAttachment atIndexedSubscript:0];
    
    NSError *pError = nil;
    _pipelineState = [device newRenderPipelineStateWithDescriptor:pQuadPipelineStateDescriptor error:&pError];
    if (pError) {
        NSLog(@">> ERROR: Failed acquiring pipeline state descriptor: %@", pError);
    }
    
    return _pipelineState != nil;
}

- (void)renderToTexture {
    
    NSUInteger pixelCount = firstInputTexture.size.x * firstInputTexture.size.y;
    NSUInteger pixelBufferLength = pixelCount * 4;
    if (_pixelBuffer == NULL) {
        _pixelBuffer = [[MetalDevice sharedMTLDevice] newBufferWithLength:pixelBufferLength options:MTLResourceCPUCacheModeDefaultCache];
    }
    
    [MetalDevice commitCommandBufferWaitUntilDone:YES];
    if ([MetalImageTexture supportsFastTextureUpload]) {
        void *vertexSamplingCoordinates = [firstInputTexture byteBuffer];
        memcpy([_pixelBuffer contents], vertexSamplingCoordinates, pixelBufferLength);
    }
    else {
        [[firstInputTexture texture] getBytes:[_pixelBuffer contents]
                                  bytesPerRow:firstInputTexture.size.x * 4
                                   fromRegion:MTLRegionMake2D(0, 0, firstInputTexture.size.x, firstInputTexture.size.y)
                                  mipmapLevel:0];
    }
    
    outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:[self textureSizeForOutput]];
    NSParameterAssert(outputTexture);
    
    id<MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
    
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.texture = [outputTexture texture];
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
    NSAssert(renderEncoder != nil, @"Create render encoder failed...");
    
//    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_pixelBuffer offset:0 atIndex:0];
//    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
//    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypePoint vertexStart:0 vertexCount:pixelCount>>5];
    
//    [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypePoint
//                              indexCount:firstInputTexture.size.x * firstInputTexture.size.y / (CGFloat)_downsamplingFactor
//                               indexType:MTLIndexTypeUInt16
//                             indexBuffer:_pixelBuffer
//                       indexBufferOffset:((unsigned int)_downsamplingFactor - 1)*4];
    
    [renderEncoder endEncoding];
    
    [firstInputTexture unlock];
    
//    [MetalDevice commitCommandBufferWaitUntilDone:YES];
//    NSData *data = [NSData dataWithBytes:[outputTexture byteBuffer] length:256*3*4];
//    NSLog(@"data: %@",data);
}

#pragma mark - MetalImageInput Protocol

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [self renderToTexture];
    [self notifyTargetsAboutNewTextureAtTime:frameTime];
}

@end
