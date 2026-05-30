//
//  MetalImageContext.m
//  MetalImage
//
//  Created by stonefeng on 2017/2/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageContext.h"
#import "MetalImageFunction.h"
#import "MetalDevice.h"
#import <Metal/MTLCommandQueue.h>

@interface MetalImageContext () {
    CVMetalTextureCacheRef _coreVideoTextureCache;
    MetalImageTextureCache *_textureCache;
}

@property (nonatomic,strong) NSString *metalContextQueueKey;

@end

@implementation MetalImageContext
@synthesize contextQueue = _contextQueue;

- (instancetype)init {
    return [self initWithProcessingQueueName:@"com.fengshi.metalProcessingQueue"];
}

- (instancetype)initWithProcessingQueueName:(NSString *)queueName {
    if (!(self = [super init]))
    {
        return nil;
    }
    
    _metalContextQueueKey = queueName;
    _contextQueue = dispatch_queue_create([queueName UTF8String], MetalImageDefaultQueueAttribute());
#if OS_OBJECT_USE_OBJC
    dispatch_queue_set_specific(_contextQueue, [_metalContextQueueKey UTF8String], (__bridge void *)self, NULL);
#endif
    
    return self;
}

- (void)dealloc {
    
}

- (NSString *)contextKey {
    return self.metalContextQueueKey;
}

+ (MetalImageContext *)sharedImageProcessingContext
{
    static dispatch_once_t pred;
    static MetalImageContext *sharedImageProcessingContext = nil;
    
    dispatch_once(&pred, ^{
        sharedImageProcessingContext = [[[self class] alloc] init];
    });
    return sharedImageProcessingContext;
}

+ (dispatch_queue_t)sharedContextQueue;
{
    return [[self sharedImageProcessingContext] contextQueue];
}

+ (MetalImageTextureCache *)sharedTextureCache {
    return [[self sharedImageProcessingContext] textureCache];
}

#pragma mark - Accessors

- (CVMetalTextureCacheRef)coreVideoTextureCache {
    if (_coreVideoTextureCache == NULL)
    {
        CVReturn err = CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, [MetalDevice sharedMTLDevice], NULL, &_coreVideoTextureCache);
        
        if (err)
        {
            NSAssert(NO, @"Error at CVMetalTextureCacheCreate %d", err);
        }
        
    }
    
    return _coreVideoTextureCache;
}

- (MetalImageTextureCache *)textureCache {
    if (_textureCache == nil)
    {
        _textureCache = [[MetalImageTextureCache alloc] init];
    }
    
    return _textureCache;
}

@end
