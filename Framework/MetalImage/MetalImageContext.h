//
//  MetalImageContext.h
//  MetalImage
//
//  Created by stonefeng on 2017/2/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVMetalTextureCache.h>
#import "MetalImageTextureCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalImageContext : NSObject

@property (nonatomic, readonly) dispatch_queue_t contextQueue;

- (instancetype)initWithProcessingQueueName:(NSString *)queueName;

- (NSString *)contextKey;

- (CVMetalTextureCacheRef)coreVideoTextureCache;
- (MetalImageTextureCache *)textureCache;

+ (MetalImageContext *)sharedImageProcessingContext;
+ (MetalImageTextureCache *)sharedTextureCache;
+ (dispatch_queue_t)sharedContextQueue;

@end

NS_ASSUME_NONNULL_END
