//
//  MetalDevice.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/17.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalDevice : NSObject

+ (nonnull MetalDevice *)sharedInstance;
+ (nullable id<MTLDevice>)sharedMTLDevice;
+ (nullable id<MTLLibrary>)MetalImageLibrary;
+ (nullable id<MTLCommandQueue>)sharedCommandQueue;

+ (nullable id<MTLCommandBuffer>)sharedCommandBuffer;
+ (void)commitCommandBuffer;
+ (void)commitCommandBufferWithCompletion:(void(^)(id<MTLCommandBuffer>))completion;
+ (void)commitCommandBufferWaitUntilScheduled:(BOOL)waitUtilScheduled;
+ (void)commitCommandBufferWaitUntilDone:(BOOL)waitUtilDone;

@end

NS_ASSUME_NONNULL_END
