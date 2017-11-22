//
//  MetalImageTwoInputFilter.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoInputFilter.h"
#import "MetalImageFunction.h"
#import "MetalImageTextureCache.h"
#import "MetalDevice.h"

@implementation MetalImageTwoInputFilter

- (instancetype)init {
    return [self initWithVertexFunctionName:@"vertex_common2" fragmentFunctionName:@"fragment_common2"];
}

- (instancetype)initWithFragmentFunctionName:(NSString *)fragmentFunctionName {
    return [self initWithVertexFunctionName:@"vertex_common2" fragmentFunctionName:fragmentFunctionName];
}

- (instancetype)initWithVertexFunction:(id<MTLFunction>)vertexFunction fragmentFunction:(id<MTLFunction>)fragmentFunction {
    if (self = [super initWithVertexFunction:vertexFunction fragmentFunction:fragmentFunction]) {
        secondInputParameter.frameTime = kCMTimeInvalid;
        secondInputParameter.frameCheckDisabled = NO;
        secondInputParameter.hasReceivedFrame = NO;
        secondInputParameter.hasSetTarget = NO;
        secondInputParameter.rotationMode = kMetalImageNoRotation;
        
        [self createTextureCoordinateBuffer2];
    }
    return self;
}

- (void)disableFirstFrameCheck {
    firstInputParameter.frameCheckDisabled = YES;
}

- (void)disableSecondFrameCheck {
    secondInputParameter.frameCheckDisabled = YES;
}

- (void)createTextureCoordinateBuffer2 {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _coordBuffer2 = [device newBufferWithLength:MetalImageDefaultRenderVetexCount*sizeof(MTLFloat2)
                                        options:MTLResourceOptionCPUCacheModeDefault];
    _coordBuffer2.label = @"default texcoords 2";
}

- (void)renderToTextureWithVertices:(const MTLFloat4 *)vertices textureCoordinates:(const MTLFloat2 *)textureCoordinates {
    NSParameterAssert(vertices);
    NSParameterAssert(textureCoordinates);
    
    [self updateTextureVertexBuffer:_verticsBuffer withNewContents:vertices size:MetalImageDefaultRenderVetexCount];
    [self updateTextureCoordinateBuffer:_coordBuffer withNewContents:textureCoordinates size:MetalImageDefaultRenderVetexCount];
    [self updateTextureCoordinateBuffer:_coordBuffer2 withNewContents:TextureCoordinatesForRotation(secondInputParameter.rotationMode) size:MetalImageDefaultRenderVetexCount];
    
    id<MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
    
    outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:[self textureSizeForOutput]];
    
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.texture = [outputTexture texture];
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
    NSAssert(renderEncoder != nil, @"Create render encoder failed...");
    [self assembleRenderEncoder:renderEncoder];
    
    [firstInputTexture unlock];
    [secondInputTexture unlock];
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_coordBuffer2 offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentTexture:[secondInputTexture texture] atIndex:1];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

#pragma mark - MetalImageInput delegate
- (NSInteger)nextAvailableTextureIndex {
    if (firstInputParameter.hasSetTarget) {
        return 1;
    }
    else {
        return 0;
    }
}

- (void)reserveTextureIndex:(NSInteger)index {
    if (index == 0) {
        firstInputParameter.hasSetTarget = YES;
    }
}

- (void)releaseTextureIndex:(NSInteger)index {
    if (index == 0) {
        firstInputParameter.hasSetTarget = NO;
    }
}

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    NSParameterAssert(newInputTexture);
    
    if (textureIndex == 0) {
        firstInputTexture = newInputTexture;
        [firstInputTexture lock];
    }
    else {
        secondInputTexture = newInputTexture;
        [secondInputTexture lock];
    }
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    if (textureIndex == 0) {
        firstInputParameter.rotationMode = newInputRotation;
    }
    else {
        secondInputParameter.rotationMode = newInputRotation;
    }
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    if (firstInputParameter.hasReceivedFrame && secondInputParameter.hasReceivedFrame) {
        return;
    }
    
    BOOL updatedMovieFrameOppositeStillImage = NO;
    
    if (textureIndex == 0)
    {
        firstInputParameter.hasReceivedFrame = YES;
        firstInputParameter.frameTime = frameTime;
        if (secondInputParameter.frameCheckDisabled)
        {
            secondInputParameter.hasReceivedFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(secondInputParameter.frameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else
    {
        secondInputParameter.hasReceivedFrame = YES;
        secondInputParameter.frameTime = frameTime;
        if (firstInputParameter.frameCheckDisabled)
        {
            firstInputParameter.hasReceivedFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstInputParameter.frameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    
    if ((firstInputParameter.hasReceivedFrame && secondInputParameter.hasReceivedFrame) || updatedMovieFrameOppositeStillImage)
    {
        CMTime passOnFrameTime = (!CMTIME_IS_INDEFINITE(firstInputParameter.frameTime)) ? firstInputParameter.frameTime : secondInputParameter.frameTime;
        // Bugfix when trying to record: always use time from first input (unless indefinite, in which case use the second input)
        [super newTextureReadyAtTime:passOnFrameTime atIndex:0];
        firstInputParameter.hasReceivedFrame = NO;
        secondInputParameter.hasReceivedFrame = NO;
    }
}

@end
