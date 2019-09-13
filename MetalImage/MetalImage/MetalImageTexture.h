//
//  MetalImageTexture.h
//  MetalImage
//
//  Created by stonefeng on 2017/2/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import "MetalImageTypes.h"

@class UIImage;
@interface MetalImageTexture : NSObject 

@property (nonatomic,strong,readonly) id<MTLTexture> texture;
@property (nonatomic,readonly) MTLUInt2 size;
@property (nonatomic,readonly) int pixelFormat;

- (instancetype)initWithTextureSize:(MTLUInt2)size;
- (instancetype)initWithTextureSize:(MTLUInt2)size pixelFormat:(int)pixelFormat;
- (instancetype)initWithTextureSize:(MTLUInt2)size textureUsage:(MTLTextureUsage)usage;

+ (BOOL)supportsFastTextureUpload;
+ (CGSize)sizeThatFitsWithinATextureForSize:(CGSize)inputSize;
+ (int)defaultPixelFormat;

// Reference counting
- (MetalImageTexture *)lock;
- (void)unlock;
- (void)clearAllLocks;
- (void)disableReferenceCounting;
- (void)enableReferenceCounting;
- (BOOL)isReferenceCountingEnable;
- (NSUInteger)referenceCounting;

// Raw data bytes
- (void)lockForReading;
- (void)unlockAfterReading;
- (NSUInteger)bytesPerRow;
- (Byte *)byteBuffer;

// debug
- (UIImage *)imageFromTexture;

@end

