//
//  MILanczosResamplingFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/12/5.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MILanczosResamplingFilter.h"
#import "MetalDevice.h"

@implementation MILanczosResamplingFilter

- (instancetype)init {
    if (self = [super initWithFirstStageVertexFunctionName:@"vertex_LanczosResamplingFilter"
                            firstStageFragmentFunctionName:@"fragment_LanczosResamplingFilter"
                             secondStageVertexFunctionName:@"vertex_LanczosResamplingFilter"
                           secondStageFragmentFunctionName:@"fragment_LanczosResamplingFilter"]) {
        
        fixedOriginalImageSize = NO;
        
    }
    
    return self;
}

- (void)setOriginalImageSize:(MTLUInt2)originalImageSize {
    NSParameterAssert(!MTLUInt2IsZero(originalImageSize));
    fixedOriginalImageSize = YES;
    if (!MTLUInt2Equal(_originalImageSize, originalImageSize)) {
        _originalImageSize = originalImageSize;
        
        [self setupFilterForSize:_originalImageSize];
    }
}

#pragma mark - Override

- (MTLUInt2)textureSizeForTexel {
    return _originalImageSize;
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
    
    MTLUInt2 currentFBOSize = [self textureSizeForOutput];
    if (MetalImageRotationSwapsWidthAndHeight(firstInputParameter.rotationMode))
    {
        currentFBOSize.y = self.originalImageSize.y;
    }
    else
    {
        currentFBOSize.x = self.originalImageSize.x;
    }
    secondOutputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:currentFBOSize];
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

#pragma mark - MetalImageInput Protocol

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    
    if (!fixedOriginalImageSize) {
        _originalImageSize = newInputTexture.size;
    }
    
    [super setInputTexture:newInputTexture atIndex:textureIndex];
}

#pragma mark -
#pragma mark Accessors

- (void)setVerticalTexelSpacing:(MTLFloat)newValue;
{
    _verticalTexelSpacing = newValue;
    [self setupFilterForSize:_originalImageSize];
}

- (void)setHorizontalTexelSpacing:(MTLFloat)newValue;
{
    _horizontalTexelSpacing = newValue;
    [self setupFilterForSize:_originalImageSize];
}

@end
