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

// GCD matches queue-specific keys BY POINTER ADDRESS. The key must be a
// stable address: using [queueName UTF8String] creates a temporary buffer
// per call whose address equality is not guaranteed, and a miss makes the
// runMetal* helpers dispatch_sync onto the queue they are already running
// on (guaranteed deadlock). Extern so MetalImageFunction.m can test against
// the same address.
extern void * const MetalImageContextQueueSpecificKey;

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
