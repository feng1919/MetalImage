//
//  MIHistogramFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/11/3.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "MIHistogramFilter.h"
#import "MetalDevice.h"
#import <UIKit/UIKit.h>

@interface MIHistogramFilter() {
    
    MetalImageHistogramType _histogramType;
    
    MTLFloat3 _mean;
    MTLFloat3 _std;
}

@end

@implementation MIHistogramFilter

- (instancetype)init {
    return [self initWithHistogramType:kMetalImageHistogramTypeHist];
}

- (id)initWithHistogramType:(MetalImageHistogramType)histogramType {
    
    if (self = [super init]) {

        _histogramType = histogramType;
        
        self.downsamplingFactor = 16.0f;
        self.bgClearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0f);
        
    }
    
    return self;
}

- (void)dealloc {
    
}

- (MTLUInt2)textureSizeForOutput {
    return MTLUInt2Make(256, 3);
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
    
    int *histRed = calloc(256, sizeof(int));
    int *histGreen = calloc(256, sizeof(int));
    int *histBlue = calloc(256, sizeof(int));
    
    for (int i = 0; i < downSamplingSize.y; i++) {
        for (int j = 0; j < downSamplingSize.x; j ++) {
            unsigned long index = bytesPerRow * i + j * 4;
            Byte b = bgra[index];
            Byte g = bgra[index+1];
            Byte r = bgra[index+2];
            
            histBlue[b] += 1;
            histGreen[g] += 1;
            histRed[r] += 1;
        }
    }
    free(bgra);
    
    if (_histogramType == kMetalImageHistogramTypeSTD ||
        _histogramType == kMetalImageHistogramTypeMean) {
        double sum_r = 0.0f;
        double sum_g = 0.0f;
        double sum_b = 0.0f;
        for (int i = 0; i < 256; i++) {
            sum_r += histRed[i] * i;
            sum_g += histGreen[i] * i;
            sum_b += histBlue[i] * i;
        }
        
        _mean.x = sum_b / (double)pixelCount;
        _mean.y = sum_g / (double)pixelCount;
        _mean.z = sum_r / (double)pixelCount;
    }
    
    if (_histogramType == kMetalImageHistogramTypeSTD) {
        double sum_r = 0.0f;
        double sum_g = 0.0f;
        double sum_b = 0.0f;
        
        for (int i = 0; i < 256; i++) {
            sum_b += (i - _mean.x) * (i - _mean.x) * histBlue[i];
            sum_g += (i - _mean.y) * (i - _mean.y) * histGreen[i];
            sum_r += (i - _mean.z) * (i - _mean.z) * histRed[i];
        }
        
        _std.x = sum_b / (float)pixelCount;
        _std.y = sum_g / (float)pixelCount;
        _std.z = sum_r / (float)pixelCount;
    }
    
    MTLUInt2 outputSize = [self textureSizeForOutput];
    Byte *byteBuffer = malloc(outputSize.x * outputSize.y * 4);
    bytesPerRow = outputSize.x * 4;
    
    if (_histogramType == kMetalImageHistogramTypeHist) {
        for (int i = 0; i < 256; i++) {
            histRed[i] *= (inputSize.x * inputSize.y) / (float)pixelCount;
            histBlue[i] *= (inputSize.x * inputSize.y) / (float)pixelCount;
            histGreen[i] *= (inputSize.x * inputSize.y) / (float)pixelCount;
        }
        for (int i = 0; i < 256; i ++) {
            unsigned long index = i * 4;
            byteBuffer[index] = (histRed[i] / 4096) << 2;
            byteBuffer[index+1] = ((histRed[i] % 4096) / 64) << 2;
            byteBuffer[index+2] = (histRed[i] % 64) << 2;
            byteBuffer[index+3] = 0xff;
            
            index = bytesPerRow + i * 4;
            byteBuffer[index] = (histGreen[i] / 4096) << 2;
            byteBuffer[index+1] = ((histGreen[i] % 4096) / 64) << 2;
            byteBuffer[index+2] = (histGreen[i] % 64) << 2;
            byteBuffer[index+3] = 0xff;
            
            index = bytesPerRow * 2 + i * 4;
            byteBuffer[index] = (histBlue[i] / 4096) << 2;
            byteBuffer[index+1] = ((histBlue[i] % 4096) / 64) << 2;
            byteBuffer[index+2] = (histBlue[i] % 64) << 2;
            byteBuffer[index+3] = 0xff;
        }
    }
    
    if (_histogramType == kMetalImageHistogramTypeMean) {
        Byte b = roundf(_mean.x);
        Byte g = roundf(_mean.y);
        Byte r = roundf(_mean.z);
        for (int j = 0; j < 3; j++) {
            for (int i = 0; i < 256; i++) {
                unsigned long index = bytesPerRow*j + i *4;
                byteBuffer[index] = b;
                byteBuffer[index+1] = g;
                byteBuffer[index+2] = r;
                byteBuffer[index+3] = 0xff;
            }
        }
    }
    
    if (_histogramType == kMetalImageHistogramTypeSTD) {
        _std.x = roundf(_std.x);
        _std.y = roundf(_std.y);
        _std.z = roundf(_std.z);
        
        int x0 = ((int)_std.x / 256) << 4;
        int x1 = (((int)_std.x % 256) / 16) << 4;
        int x2 = ((int)_std.x % 16) << 4;
        
        int y0 = ((int)_std.y / 256) << 4;
        int y1 = (((int)_std.y % 256) / 16) << 4;
        int y2 = ((int)_std.y % 16) << 4;
        
        int z0 = ((int)_std.z / 256) << 4;
        int z1 = (((int)_std.z % 256) / 16) << 4;
        int z2 = ((int)_std.z % 16) << 4;
        
        for (int i = 0; i < 256; i ++) {
            unsigned long index = i * 4;
            byteBuffer[index] = x0;
            byteBuffer[index+1] = x1;
            byteBuffer[index+2] = x2;
            byteBuffer[index+3] = 0xff;
            
            index = bytesPerRow + i * 4;
            byteBuffer[index] = y0;
            byteBuffer[index+1] = y1;
            byteBuffer[index+2] = y2;
            byteBuffer[index+3] = 0xff;
            
            index = bytesPerRow * 2 + i * 4;
            byteBuffer[index] = z0;
            byteBuffer[index+1] = z1;
            byteBuffer[index+2] = z2;
            byteBuffer[index+3] = 0xff;
        }
    }
    
    /*
    printf("\n");
    for (int i = 0; i < outputSize.y; i++) {
        int offset = i * 256 * 4;
        printf("\n");
        for (int j = 0; j < 256; j ++) {
            int index = offset + j * 4;
            printf("(%d, %d, %d) ", byteBuffer[index], byteBuffer[index+1], byteBuffer[index+2]);
        }
    }
    
    printf("\ntotal pixels: %ld", pixelCount);
    printf("\nmean: %0.2f, %0.2f, %0.2f", _mean.x, _mean.y, _mean.z);
    printf("\nstd: %0.2f, %0.2f, %0.2f", _std.x, _std.y, _std.z);
    
    printf("\nred: [");
    for (int i = 0; i < 256; i++) {
        printf("%d, ", histRed[i]);
    }
    printf(" ]\n");
    
    printf("\ngreen: [");
    for (int i = 0; i < 256; i++) {
        printf("%d, ", histGreen[i]);
    }
    printf(" ]\n");
    
    printf("\nblue: [");
    for (int i = 0; i < 256; i++) {
        printf("%d, ", histBlue[i]);
    }
    printf(" ]\n");
    
    free(histGreen);
    free(histBlue);
    free(histRed);
    */
    
    /*
    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGContextRef context = CGBitmapContextCreate(byteBuffer, outputSize.x, outputSize.y, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgimage];
    CGContextRelease(context);
     */
    
    outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:[self textureSizeForOutput]];
    NSParameterAssert(outputTexture);
        
    bytesPerRow = [outputTexture bytesPerRow];
    Byte *contents = [outputTexture byteBuffer];
    for (int i = 0; i < outputSize.y; i++) {
        memcpy(contents+bytesPerRow*i, byteBuffer+(outputSize.x*4*i), outputSize.x*4);
    }
    
    free(byteBuffer);
}

#pragma mark - MetalImageInput Protocol

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [self renderToTexture];
    [self notifyTargetsAboutNewTextureAtTime:frameTime];
}

@end
