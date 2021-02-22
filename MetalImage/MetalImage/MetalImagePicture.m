//
//  MetalImagePicture.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImagePicture.h"
#import "MetalImageContext.h"

@implementation MetalImagePicture

#pragma mark -
#pragma mark Initialization and teardown

- (instancetype)initWithImage:(UIImage *)newImage {
    return [self initWithImage:newImage smoothlyScaleOutput:NO removePremultiplication:NO];
}

- (instancetype)initWithImage:(UIImage *)newImage smoothlyScaleOutput:(BOOL)smoothlyScaleOutput removePremultiplication:(BOOL)removePremultiplication {
    if (!(self = [super init]))
    {
        return nil;
    }
    NSParameterAssert(newImage);
    
    CGImageRef newImageSource = newImage.CGImage;
    
    hasProcessedImage = NO;
    shouldSmoothlyScaleOutput = smoothlyScaleOutput;
    imageUpdateSemaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_signal(imageUpdateSemaphore);
    
    
    // TODO: Dispatch this whole thing asynchronously to move image loading off main thread
    CGFloat widthOfImage = CGImageGetWidth(newImageSource);
    CGFloat heightOfImage = CGImageGetHeight(newImageSource);
    
    // If passed an empty image reference, CGContextDrawImage will fail in future versions of the SDK.
    NSAssert( widthOfImage > 0 && heightOfImage > 0, @"Passed image must not be empty - it should be at least 1px tall and wide");
    
    pixelSizeOfImage = CGSizeMake(widthOfImage, heightOfImage);
    CGSize pixelSizeToUseForTexture = pixelSizeOfImage;
    
    BOOL shouldRedrawUsingCoreGraphics = NO;
    
    // For now, deal with images larger than the maximum texture size by resizing to be within that limit
    CGSize scaledImageSizeToFitOnGPU = [MetalImageTexture sizeThatFitsWithinATextureForSize:pixelSizeOfImage];
    if (!CGSizeEqualToSize(scaledImageSizeToFitOnGPU, pixelSizeOfImage))
    {
        pixelSizeOfImage = scaledImageSizeToFitOnGPU;
        pixelSizeToUseForTexture = pixelSizeOfImage;
        shouldRedrawUsingCoreGraphics = YES;
    }
    
    if (shouldSmoothlyScaleOutput)
    {
        // In order to use mipmaps, you need to provide power-of-two textures, so convert to the next largest power of two and stretch to fill
        CGFloat powerClosestToWidth = ceil(log2(pixelSizeOfImage.width));
        CGFloat powerClosestToHeight = ceil(log2(pixelSizeOfImage.height));
        
        pixelSizeToUseForTexture = CGSizeMake(pow(2.0, powerClosestToWidth), pow(2.0, powerClosestToHeight));
        
        shouldRedrawUsingCoreGraphics = YES;
    }
    
    GLubyte *imageData = NULL;
    CFDataRef dataFromImageDataProvider = NULL;
    BOOL isLitteEndian = YES;
    BOOL alphaFirst = NO;
    BOOL premultiplied = NO;
    
    if (!shouldRedrawUsingCoreGraphics) {
        /* Check that the memory layout is compatible with GL, as we cannot use glPixelStore to
         * tell GL about the memory layout with GLES.
         */
        if (CGImageGetBytesPerRow(newImageSource) != CGImageGetWidth(newImageSource) * 4 ||
            CGImageGetBitsPerPixel(newImageSource) != 32 ||
            CGImageGetBitsPerComponent(newImageSource) != 8)
        {
            shouldRedrawUsingCoreGraphics = YES;
        } else {
            /* Check that the bitmap pixel format is compatible with GL */
            CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(newImageSource);
            if ((bitmapInfo & kCGBitmapFloatComponents) != 0) {
                /* We don't support float components for use directly in GL */
                shouldRedrawUsingCoreGraphics = YES;
            } else {
                CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
                if (byteOrderInfo == kCGBitmapByteOrder32Little) {
                    /* Little endian, for alpha-first we can use this bitmap directly in GL */
                    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
                    if (alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaFirst) {
                        alphaFirst = YES;
                        premultiplied = alphaInfo == kCGImageAlphaPremultipliedFirst;
                    }
                    else {
                        shouldRedrawUsingCoreGraphics = YES;
                    }
                }
                else {
                    shouldRedrawUsingCoreGraphics = YES;
                }
            }
        }
    }
    
    //    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
    if (shouldRedrawUsingCoreGraphics)
    {
        // For resized or incompatible image: redraw
        imageData = (GLubyte *) calloc(1, (int)pixelSizeToUseForTexture.width * (int)pixelSizeToUseForTexture.height * 4);
        
        CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)pixelSizeToUseForTexture.width, (size_t)pixelSizeToUseForTexture.height, 8, (size_t)pixelSizeToUseForTexture.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        //        CGContextSetBlendMode(imageContext, kCGBlendModeCopy); // From Technical Q&A QA1708: http://developer.apple.com/library/ios/#qa/qa1708/_index.html
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, pixelSizeToUseForTexture.width, pixelSizeToUseForTexture.height), newImageSource);
        CGContextRelease(imageContext);
        CGColorSpaceRelease(genericRGBColorspace);
        isLitteEndian = YES;
        alphaFirst = YES;
        premultiplied = YES;
    }
    else
    {
        // Access the raw image bytes directly
        dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
        imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    }
    
    if (removePremultiplication && premultiplied) {
        NSUInteger    totalNumberOfPixels = round(pixelSizeToUseForTexture.width * pixelSizeToUseForTexture.height);
        uint32_t    *pixelP = (uint32_t *)imageData;
        uint32_t    pixel;
        CGFloat        srcR, srcG, srcB, srcA;
        
        for (NSUInteger idx=0; idx<totalNumberOfPixels; idx++, pixelP++) {
            pixel = isLitteEndian ? CFSwapInt32LittleToHost(*pixelP) : CFSwapInt32BigToHost(*pixelP);
            
            if (alphaFirst) {
                srcA = (CGFloat)((pixel & 0xff000000) >> 24) / 255.0f;
            }
            else {
                srcA = (CGFloat)(pixel & 0x000000ff) / 255.0f;
                pixel >>= 8;
            }
            
            srcR = (CGFloat)((pixel & 0x00ff0000) >> 16) / 255.0f;
            srcG = (CGFloat)((pixel & 0x0000ff00) >> 8) / 255.0f;
            srcB = (CGFloat)(pixel & 0x000000ff) / 255.0f;
            
            srcR /= srcA; srcG /= srcA; srcB /= srcA;
            
            pixel = (uint32_t)(srcR * 255.0) << 16;
            pixel |= (uint32_t)(srcG * 255.0) << 8;
            pixel |= (uint32_t)(srcB * 255.0);
            
            if (alphaFirst) {
                pixel |= (uint32_t)(srcA * 255.0) << 24;
            }
            else {
                pixel <<= 8;
                pixel |= (uint32_t)(srcA * 255.0);
            }
            *pixelP = isLitteEndian ? CFSwapInt32HostToLittle(pixel) : CFSwapInt32HostToBig(pixel);
        }
    }
    
    //    elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0;
    //    NSLog(@"Core Graphics drawing time: %f", elapsedTime);
    
    //    CGFloat currentRedTotal = 0.0f, currentGreenTotal = 0.0f, currentBlueTotal = 0.0f, currentAlphaTotal = 0.0f;
    //    NSUInteger totalNumberOfPixels = round(pixelSizeToUseForTexture.width * pixelSizeToUseForTexture.height);
    //
    //    for (NSUInteger currentPixel = 0; currentPixel < totalNumberOfPixels; currentPixel++)
    //    {
    //        currentBlueTotal += (CGFloat)imageData[(currentPixel * 4)] / 255.0f;
    //        currentGreenTotal += (CGFloat)imageData[(currentPixel * 4) + 1] / 255.0f;
    //        currentRedTotal += (CGFloat)imageData[(currentPixel * 4 + 2)] / 255.0f;
    //        currentAlphaTotal += (CGFloat)imageData[(currentPixel * 4) + 3] / 255.0f;
    //    }
    //
    //    NSLog(@"Debug, average input image red: %f, green: %f, blue: %f, alpha: %f", currentRedTotal / (CGFloat)totalNumberOfPixels, currentGreenTotal / (CGFloat)totalNumberOfPixels, currentBlueTotal / (CGFloat)totalNumberOfPixels, currentAlphaTotal / (CGFloat)totalNumberOfPixels);
    
//    runMetalSynchronouslyOnVideoProcessingQueue(^{
        
        MTLUInt2 texSize = MTLUInt2Make(pixelSizeToUseForTexture.width, pixelSizeToUseForTexture.height);
        outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:texSize];
        [outputTexture disableReferenceCounting];
        
        [[outputTexture texture] replaceRegion:MTLRegionMake2D(0, 0, texSize.x, texSize.y)
                                   mipmapLevel:0
                                         slice:0
                                     withBytes:imageData
                                   bytesPerRow:texSize.x*4
                                 bytesPerImage:texSize.x*texSize.y*4];
        
//        glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
//        if (self.shouldSmoothlyScaleOutput)
//        {
//            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
//        }
//        // no need to use self.outputTextureOptions here since pictures need this texture formats and type
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)pixelSizeToUseForTexture.width, (int)pixelSizeToUseForTexture.height, 0, format, GL_UNSIGNED_BYTE, imageData);
//
//        if (self.shouldSmoothlyScaleOutput)
//        {
//            glGenerateMipmap(GL_TEXTURE_2D);
//        }
//        glBindTexture(GL_TEXTURE_2D, 0);
    
//    });
    
    if (shouldRedrawUsingCoreGraphics)
    {
        free(imageData);
    }
    else
    {
        if (dataFromImageDataProvider)
        {
            CFRelease(dataFromImageDataProvider);
        }
    }
    
    return self;
}

// ARC forbids explicit message send of 'release'; since iOS 6 even for dispatch_release() calls: stripping it out in that case is required.
- (void)dealloc;
{
    [outputTexture enableReferenceCounting];
    [outputTexture unlock];
    
#if !OS_OBJECT_USE_OBJC
    if (imageUpdateSemaphore != NULL)
    {
        dispatch_release(imageUpdateSemaphore);
    }
#endif
}

#pragma mark -
#pragma mark Image rendering

- (void)removeAllTargets {
    [super removeAllTargets];
    hasProcessedImage = NO;
}

- (void)processImage {
    [self processImageWithCompletionHandler:nil];
}

- (BOOL)processImageWithCompletionHandler:(void (^)(void))completion {
    
    hasProcessedImage = YES;
    
    if (dispatch_semaphore_wait(imageUpdateSemaphore, DISPATCH_TIME_NOW) != 0) {
        if (completion) {
            completion();
        }
        return NO;
    }
    
    runMetalAsynchronouslyOnVideoProcessingQueue(^{
        for (id<MetalImageInput> currentTarget in targets) {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [currentTarget setInputRotation:kMetalImageNoRotation atIndex:textureIndexOfTarget];
            [currentTarget setInputTexture:outputTexture atIndex:textureIndexOfTarget];
            [currentTarget newTextureReadyAtTime:kCMTimeIndefinite atIndex:textureIndexOfTarget];
        }
        
        dispatch_semaphore_signal(imageUpdateSemaphore);
        
        if (completion) {
            completion();
        }
    });
    
    return YES;
}

@end
