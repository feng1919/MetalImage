//
//  MetalImageFunction.m
//  MetalImage
//
//  Created by stonefeng on 2017/2/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFunction.h"
#import <mach/mach.h>
#import <UIKit/UIKit.h>

#define VertexA { -1.0f,  -1.0f, 0.0f, 1.0f }
#define VertexB {  1.0f,  -1.0f, 0.0f, 1.0f }
#define VertexC { -1.0f,   1.0f, 0.0f, 1.0f }
#define VertexD {  1.0f,   1.0f, 0.0f, 1.0f }
MTLFloat4 imageVertices[] = {VertexA,VertexB,VertexC,VertexD};
MTLFloat4 *MetalImageDefaultRenderVetics = imageVertices;
NSUInteger MetalImageDefaultRenderVetexCount = 4;

@implementation MetalImageFunction

dispatch_queue_attr_t MetalImageDefaultQueueAttribute(void)
{
#if TARGET_OS_IPHONE
    return dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0);
#endif
}

void runMetalOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void runMetalOnVideoProcessingQueue(BOOL synchronously, void (^block)(void)) {
    if (synchronously) {
        runMetalSynchronouslyOnVideoProcessingQueue(block);
    }
    else {
        runMetalAsynchronouslyOnVideoProcessingQueue(block);
    }
}

void runMetalSynchronouslyOnVideoProcessingQueue(void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [MetalImageContext sharedContextQueue];
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == videoProcessingQueue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([[[MetalImageContext sharedImageProcessingContext] contextKey] UTF8String]) || [NSThread isMainThread])
#endif
        {
            block();
        }else
        {
            dispatch_sync(videoProcessingQueue, block);
        }
}

void runMetalAsynchronouslyOnVideoProcessingQueue(void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [MetalImageContext sharedContextQueue];
    
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == videoProcessingQueue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([[[MetalImageContext sharedImageProcessingContext] contextKey] UTF8String]))
#endif
        {
            block();
        }else
        {
            dispatch_async(videoProcessingQueue, block);
        }
}

extern void runMetalOnContextQueue(BOOL synchronously, MetalImageContext *context, void (^block)(void)) {
    if (synchronously) {
        runMetalSynchronouslyOnContextQueue(context, block);
    }
    else {
        runMetalAsynchronouslyOnContextQueue(context, block);
    }
}

void runMetalSynchronouslyOnContextQueue(MetalImageContext *context, void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [context contextQueue];
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == videoProcessingQueue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([[[MetalImageContext sharedImageProcessingContext] contextKey] UTF8String]) || [NSThread isMainThread])
#endif
        {
            block();
        }else
        {
            dispatch_sync(videoProcessingQueue, block);
        }
}

void runMetalAsynchronouslyOnContextQueue(MetalImageContext *context, void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [context contextQueue];
    
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == videoProcessingQueue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([[[MetalImageContext sharedImageProcessingContext] contextKey] UTF8String]))
#endif
        {
            block();
        }else
        {
            dispatch_async(videoProcessingQueue, block);
        }
}

void reportAvailableMemoryForMetalImage(NSString *tag)
{
    if (!tag)
        tag = @"Default";
    
    struct task_basic_info info;
    
    mach_msg_type_number_t size = sizeof(info);
    
    kern_return_t kerr = task_info(mach_task_self(),
                                   
                                   TASK_BASIC_INFO,
                                   
                                   (task_info_t)&info,
                                   
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"%@ - Memory used: %u", tag, (unsigned int)info.resident_size); //in bytes
    } else {        
        NSLog(@"%@ - Error: %s", tag, mach_error_string(kerr));        
    }    
}

const MTLFloat2 *TextureCoordinatesForRotation(MetalImageRotationMode rotationMode)
{
    
#define A {0.0f, 1.0f}
#define B {1.0f, 1.0f}
#define C {0.0f, 0.0f}
#define D {1.0f, 0.0f}
    
    static const MTLFloat2 noRotationTextureCoordinates[] = {A,B,C,D};
    static const MTLFloat2 rotateLeftTextureCoordinates[] = {C,A,D,B};
    static const MTLFloat2 rotateRightTextureCoordinates[] = {B,D,A,C};
    static const MTLFloat2 verticalFlipTextureCoordinates[] = {C,D,A,B};
    static const MTLFloat2 horizontalFlipTextureCoordinates[] = {B,A,D,C};
    static const MTLFloat2 rotateRightVerticalFlipTextureCoordinates[] = {D,B,C,A};
    static const MTLFloat2 rotateRightHorizontalFlipTextureCoordinates[] = {A,C,B,D};
    static const MTLFloat2 rotate180TextureCoordinates[] = {D,C,B,A};
    
    switch (rotationMode)
    {
        case kMetalImageNoRotation:
            return noRotationTextureCoordinates;
        case kMetalImageRotateLeft:
            return rotateLeftTextureCoordinates;
        case kMetalImageRotateRight:
            return rotateRightTextureCoordinates;
        case kMetalImageFlipVertical:
            return verticalFlipTextureCoordinates;
        case kMetalImageFlipHorizonal:
            return horizontalFlipTextureCoordinates;
        case kMetalImageRotateRightFlipVertical:
            return rotateRightVerticalFlipTextureCoordinates;
        case kMetalImageRotateRightFlipHorizontal:
            return rotateRightHorizontalFlipTextureCoordinates;
        case kMetalImageRotate180:
            return rotate180TextureCoordinates;
    }
}

@end
