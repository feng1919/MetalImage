//
//  MetalImageFunction.h
//  MetalImage
//
//  Created by stonefeng on 2017/2/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageContext.h"
#import "MetalImageGlobal.h"

NS_ASSUME_NONNULL_BEGIN

extern MTLFloat4 *MetalImageDefaultRenderVetics;
extern NSUInteger MetalImageDefaultRenderVetexCount;

@interface MetalImageFunction : NSObject

extern dispatch_queue_attr_t MetalImageDefaultQueueAttribute(void);

extern void runMetalOnMainQueueWithoutDeadlocking(void (^block)(void));
extern void runMetalSynchronouslyOnVideoProcessingQueue(void (^block)(void));
extern void runMetalAsynchronouslyOnVideoProcessingQueue(void (^block)(void));
extern void runMetalOnVideoProcessingQueue(BOOL synchronously, void (^block)(void));
extern void runMetalSynchronouslyOnContextQueue(MetalImageContext *context, void (^block)(void));
extern void runMetalAsynchronouslyOnContextQueue(MetalImageContext *context, void (^block)(void));
extern void runMetalOnContextQueue(BOOL synchronously, MetalImageContext *context, void (^block)(void));
extern void reportAvailableMemoryForMetalImage(NSString *tag);

extern const MTLFloat2 *TextureCoordinatesForRotation(MetalImageRotationMode rotationMode);

@end

NS_ASSUME_NONNULL_END
