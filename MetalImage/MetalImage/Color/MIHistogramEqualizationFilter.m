//
//  MIHistogramEqualizationFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2021/2/19.
//  Copyright © 2021 fengshi. All rights reserved.
//

#import "MIHistogramEqualizationFilter.h"
#import "MetalDevice.h"
#import "MIAdaptiveLuminanceFilter.h"

@interface MIHistogramEqualizationFilter() {
    MIAdaptiveLuminanceFilter *_adaptiveLuminance;
}

@end

@implementation MIHistogramEqualizationFilter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    _adaptiveLuminance = [[MIAdaptiveLuminanceFilter alloc] init];
    self.downsamplingFactor = 16.0f;
    self.bgClearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0f);
    
    return self;
}

- (void)renderToTexture {
    
    [self updateTextureVertexBuffer:_verticsBuffer
                    withNewContents:MetalImageDefaultRenderVetics
                               size:MetalImageDefaultRenderVetexCount];
    [self updateTextureCoordinateBuffer:_coordBuffer
                        withNewContents:TextureCoordinatesForRotation(firstInputParameter.rotationMode)
                                   size:MetalImageDefaultRenderVetexCount];
    id<MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
    MTLUInt2 inputSize = firstInputTexture.size;
    MTLUInt2 downSamplingSize = MTLUInt2Make(roundf((float)inputSize.x / _downsamplingFactor), roundf((float)inputSize.y / _downsamplingFactor));
    MetalImageTexture *downSamplingTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:downSamplingSize];
    NSParameterAssert(downSamplingTexture);
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.texture = [downSamplingTexture texture];
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
    NSAssert(renderEncoder != nil, @"Create render encoder failed...");
    [self assembleRenderEncoder:renderEncoder];
    [firstInputTexture unlock];

    [MetalDevice commitCommandBufferWaitUntilDone:YES];
    
    unsigned long pixelCount = downSamplingSize.x * downSamplingSize.y;
    unsigned long bytesPerRow = [downSamplingTexture bytesPerRow];
    Byte *bgra = malloc(bytesPerRow * downSamplingSize.y);
    
    if ([MetalImageTexture supportsFastTextureUpload]) {
        void *byteBuffer = [downSamplingTexture byteBuffer];
        memcpy(bgra, byteBuffer, downSamplingSize.y * bytesPerRow);
    }
    else {
        [[downSamplingTexture texture] getBytes:bgra
                                    bytesPerRow:bytesPerRow
                                     fromRegion:MTLRegionMake2D(0, 0, downSamplingSize.x, downSamplingSize.y)
                                    mipmapLevel:0];
    }
    [downSamplingTexture unlock];
    
    int *hist = calloc(256, sizeof(int));
    for (int i = 0; i < downSamplingSize.y; i++) {
        for (int j = 0; j < downSamplingSize.x; j ++) {
            unsigned long index = bytesPerRow * i + j * 4;
            float b = (float)bgra[index];
            float g = (float)bgra[index+1];
            float r = (float)bgra[index+2];
            
            float luminance = r*0.2627f + g*0.6780f + b*0.0593f;
            int lumi = (int)fminf(fmaxf(roundf(luminance), 0.0f), 255.0f);
            hist[lumi] += 1;
        }
    }
    free(bgra);
    
    int threshold = (int)pixelCount / 256 / 2;
    int min = 0;
    for (int i = 0; i < 256; i++) {
        if (hist[i] >= threshold) {
            min = i;
            break;
        }
    }
    int max = 255;
    for (int i = 0; i < 256; i++) {
        if (hist[255-i] >= threshold) {
            max = 255-i;
            break;
        }
    }
    
    free(hist);
    
    if (min >= max) {
        _adaptiveLuminance.scale = 1.0f;
        _adaptiveLuminance.offset = 0.0f;
    }
    else {
        _adaptiveLuminance.scale = 255.0f / (float)(max - min);
        _adaptiveLuminance.offset = -min * _adaptiveLuminance.scale / 255.0f;
    }
}

#pragma mark - MetalImageInput Protocol

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    [super setInputTexture:newInputTexture atIndex:textureIndex];
    [_adaptiveLuminance setInputTexture:newInputTexture atIndex:textureIndex];
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [self renderToTexture];
    [_adaptiveLuminance newTextureReadyAtTime:frameTime atIndex:textureIndex];
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [_adaptiveLuminance setInputRotation:newInputRotation atIndex:textureIndex];
}
#pragma mark - Override pipeline

- (void)addTarget:(id<MetalImageInput>)newTarget {
    [_adaptiveLuminance addTarget:newTarget];
}

- (void)addTarget:(id<MetalImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation {
    [_adaptiveLuminance addTarget:newTarget atTextureLocation:textureLocation];
}

- (void)removeTarget:(id<MetalImageInput>)targetToRemove {
    [_adaptiveLuminance removeTarget:targetToRemove];
}

- (void)removeAllTargets {
    [_adaptiveLuminance removeAllTargets];
}

@end
