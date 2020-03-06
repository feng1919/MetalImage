//
//  MetalImageView.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/3.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageView.h"
#import "MetalImageContext.h"
#import "MetalImageTypes.h"
#import "MetalImageFunction.h"
#import "MetalDevice.h"
#import "UIImage+Texture.h"

@import AVFoundation;

@interface MetalImageView () {
    MTLFloat4 imageScalingVertics[4];
    MTLUInt2 inputImageSize;
}

@property (nonatomic, strong) id<MTLBuffer> verticsBuffer;
@property (nonatomic, strong) id<MTLBuffer> coordBuffer;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLDepthStencilState> depthStencilState;
@property (nonatomic, strong) MTLRenderPassDescriptor *renderPassDescriptor;

- (void)buildUp;
- (void)tearDown;

@end

@implementation MetalImageView

+(Class)layerClass
{
    return [CAMetalLayer class];
}

- (instancetype)init {
    if (self = [super init]) {
        [self buildUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self buildUp];
    }
    return self;
}

- (void)dealloc {
    [self tearDown];
}

- (void)buildUp {
    self.opaque = YES;
    self.backgroundColor = [UIColor clearColor];
    self.bgClearColor = MTLClearColorMake(0.0f, 0.0f, 0.0f, 1.0f);
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    CAMetalLayer *metalLayer = (CAMetalLayer *)self.layer;
    metalLayer = (CAMetalLayer*) self.layer;
    metalLayer.device = device;
    metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    metalLayer.framebufferOnly = YES;
    
    inputRotationMode = kMetalImageNoRotation;
    
    _fillMode = kMetalImageFillModePreserveAspectRatio;
    [self fillTextureVerticsWithWidthScaling:1.0f heightScaling:1.0f];
    
    [self updateTextureVertics];
    [self updateTextureCoordinates];
    [self prepareRenderPipeline];
    [self prepareRenderDepthStencilState];
    [self prepareRenderPassDescriptor];
}

- (void)tearDown {
    
}

- (void)updateTextureVertics {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _verticsBuffer = [device newBufferWithBytes:imageScalingVertics
                                         length:MetalImageDefaultRenderVetexCount*sizeof(MTLFloat4)
                                        options:MTLResourceOptionCPUCacheModeDefault];
    if(!_verticsBuffer) {
        NSLog(@">> ERROR: Failed creating a vertex buffer for a quad!");
        return ;
    }
    _verticsBuffer.label = @"quad vertices";
}

- (void)updateTextureCoordinates {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    const MTLFloat2 *textureCoordinates = TextureCoordinatesForRotation(inputRotationMode);
    _coordBuffer = [device newBufferWithBytes:textureCoordinates
                                       length:MetalImageDefaultRenderVetexCount*sizeof(MTLFloat2)
                                      options:MTLResourceOptionCPUCacheModeDefault];
    if (!_coordBuffer) {
        NSLog(@">> ERROR: Failed creating a 2d texture coordinate buffer!");
        return;
    }
    _coordBuffer.label = @"quad texcoords";
}

- (BOOL)prepareRenderPipeline
{
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    id<MTLLibrary> renderLibrary = [MetalDevice MetalImageLibrary];
    if (!renderLibrary && device) {
        NSError *liberr = nil;
        renderLibrary = [device newLibraryWithFile:@"CommonStruct.metallib" error:&liberr];
        NSAssert(liberr == nil, @"Create library failed...%@", liberr);
    }
    
    id <MTLFunction> vertexProgram   = [renderLibrary newFunctionWithName:@"vertex_common"];
    id <MTLFunction> fragmentProgram = [renderLibrary newFunctionWithName:@"fragment_common"];
    if (!vertexProgram || !fragmentProgram) {
        return NO;
    }
    
    MTLRenderPipelineDescriptor *pQuadPipelineStateDescriptor = [MTLRenderPipelineDescriptor new];
    pQuadPipelineStateDescriptor.depthAttachmentPixelFormat      = MTLPixelFormatInvalid;
    pQuadPipelineStateDescriptor.stencilAttachmentPixelFormat    = MTLPixelFormatInvalid;
    pQuadPipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pQuadPipelineStateDescriptor.sampleCount                     = 1;
    pQuadPipelineStateDescriptor.vertexFunction                  = vertexProgram;
    pQuadPipelineStateDescriptor.fragmentFunction                = fragmentProgram;
    
    NSError *pError = nil;
    _pipelineState = [device newRenderPipelineStateWithDescriptor:pQuadPipelineStateDescriptor error:&pError];
    if(pError) {
        NSLog(@">> ERROR: Failed acquiring pipeline state descriptor: %@", pError);
    }
    
    return _pipelineState != nil;
}

- (BOOL)prepareRenderDepthStencilState
{
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    MTLDepthStencilDescriptor *pDepthStateDesc = [MTLDepthStencilDescriptor new];
    
    if(!pDepthStateDesc){
        NSLog(@">> ERROR: Failed creating a depth stencil descriptor!");
        return NO;
    }
    
    pDepthStateDesc.depthCompareFunction = MTLCompareFunctionAlways;
    pDepthStateDesc.depthWriteEnabled    = NO;
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

#pragma mark - Fill mode
- (void)setFillMode:(MetalImageFillModeType)newValue;
{
    _fillMode = newValue;
    [self updateViewGeometry];
}

- (void)updateViewGeometry
{
    __block CGRect frame;
    __block CGSize currentViewSize;
    runMetalOnMainQueueWithoutDeadlocking(^{
        frame = self.bounds;
        currentViewSize = self.bounds.size;
    });
    runMetalSynchronouslyOnVideoProcessingQueue(^{
        CGFloat heightScaling, widthScaling;
        CGSize imageSize = CGSizeMake(inputImageSize.x, inputImageSize.y);
        CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(imageSize, frame);
        
        switch(_fillMode)
        {
            case kMetalImageFillModeStretch:
            {
                widthScaling = 1.0;
                heightScaling = 1.0;
            }
                break;
                
            case kMetalImageFillModePreserveAspectRatio:
            {
                widthScaling = insetRect.size.width / currentViewSize.width;
                heightScaling = insetRect.size.height / currentViewSize.height;
            }
                break;
                
            case kMetalImageFillModePreserveAspectRatioAndFill:
            {
                widthScaling = currentViewSize.height / insetRect.size.height;
                heightScaling = currentViewSize.width / insetRect.size.width;
            }
                break;
        }
        
        [self fillTextureVerticsWithWidthScaling:widthScaling heightScaling:heightScaling];
    });
}

- (void)fillTextureVerticsWithWidthScaling:(CGFloat)widthScaling heightScaling:(CGFloat)heightScaling {
    imageScalingVertics[0] = MTLFloat4Make(-widthScaling, -heightScaling, 0.0f, 1.0f);
    imageScalingVertics[1] = MTLFloat4Make( widthScaling, -heightScaling, 0.0f, 1.0f);
    imageScalingVertics[2] = MTLFloat4Make(-widthScaling,  heightScaling, 0.0f, 1.0f);
    imageScalingVertics[3] = MTLFloat4Make( widthScaling,  heightScaling, 0.0f, 1.0f);
}

- (void)updateInputImageSize {
    if (firstInputTexture) {
        
        MTLUInt2 newSize = [firstInputTexture size];
        if (MetalImageRotationSwapsWidthAndHeight(inputRotationMode)) {
            MTLUInt2Swap(&newSize);
        }
        if (!MTLUInt2Equal(inputImageSize, newSize)) {
            inputImageSize = newSize;
            if (!MTLUInt2IsZero(newSize)) {
                [self updateViewGeometry];
                [self updateTextureVertics];
            }
        }
    }
}

#pragma mark - MetalImageInput Protocol

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    if (inputRotationMode != newInputRotation) {
        inputRotationMode = newInputRotation;
        [self updateTextureCoordinates];
        
        NSLog(@"update rotaion mode:%ld", (unsigned long)newInputRotation);
    }
}

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    firstInputTexture = newInputTexture;
    [firstInputTexture lock];
    [self updateInputImageSize];
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    runMetalOnMainQueueWithoutDeadlocking(^{
        
        CAMetalLayer *metalLayer = (CAMetalLayer *)self.layer;
        id<MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
        id<CAMetalDrawable> currentDrawable = [metalLayer nextDrawable];
        if (currentDrawable == nil) {
            NSLog(@"Obtain drawable failed...");
            return;
        }
        
        MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
        colorAttachment.texture = [currentDrawable texture];
        
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
        [renderEncoder setDepthStencilState:_depthStencilState];
        [renderEncoder setRenderPipelineState:_pipelineState];
        [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
        [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
        [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:currentDrawable];
        
        [MetalDevice commitCommandBufferWaitUntilDone:NO];
        
        currentDrawable = nil;
        
        [firstInputTexture unlock];
        firstInputTexture = nil;
    });
}

@end
