//
//  MetalImageTextureCache.m
//  MetalImage
//
//  Created by stonefeng on 2017/2/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTextureCache.h"
#import "MetalImageFunction.h"
#import "MetalImageContext.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#endif

@interface MetalImageTextureCache () {
    //    NSCache *framebufferCache;
    NSMutableDictionary *framebufferCache;
    NSMutableDictionary *framebufferTypeCounts;
    NSMutableArray *activeImageCaptureList; // Where framebuffers that may be lost by a filter, but which are still needed for a UIImage, etc., are stored
    id memoryWarningObserver;
    
    dispatch_queue_t framebufferCacheQueue;
}

@end

@implementation MetalImageTextureCache


#pragma mark - Initialization and teardown

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    __unsafe_unretained __typeof__ (self) weakSelf = self;
    memoryWarningObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        __typeof__ (self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf purgeAllUnassignedTextures];
        }
    }];
#else
#endif
    
    //    framebufferCache = [[NSCache alloc] init];
    framebufferCache = [[NSMutableDictionary alloc] init];
    framebufferTypeCounts = [[NSMutableDictionary alloc] init];
    activeImageCaptureList = [[NSMutableArray alloc] init];
    framebufferCacheQueue = dispatch_queue_create("com.fengshi.MetalImage.framebufferCacheQueue", NULL);
    
    return self;
}

- (void)dealloc;
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#else
#endif
}

#pragma mark - Framebuffer management
- (NSString *)hashForSize:(MTLUInt2)size pixelFormat:(int)pixelFormat {
    return [NSString stringWithFormat:@"width%d-height%d-format%d",size.x, size.y, pixelFormat];
}

- (MetalImageTexture *)fetchTextureWithSize:(MTLUInt2)size {
    return [self fetchTextureWithSize:size pixelFormat:[MetalImageTexture defaultPixelFormat]];
}

- (MetalImageTexture *)fetchTextureWithSize:(MTLUInt2)size pixelFormat:(int)pixelFormat {
    
    @synchronized (self) {
        MetalImageTexture *textureFromCache = nil;
        
        NSString *lookupHash = [self hashForSize:size pixelFormat:pixelFormat];
        NSNumber *numberOfMatchingTexturesInCache = [framebufferTypeCounts objectForKey:lookupHash];
        NSInteger numberOfMatchingTextures = [numberOfMatchingTexturesInCache integerValue];
        
        //        NSLog(@"=========");
        //        NSLog(@"lookupHash : %@",lookupHash);
        
        if ([numberOfMatchingTexturesInCache integerValue] < 1)
        {
            // Nothing in the cache, create a new framebuffer to use
            textureFromCache = [[MetalImageTexture alloc] initWithTextureSize:size];
            //            NSLog(@"create new buffer: %p",textureFromCache);
        }
        else
        {
            // Something found, pull the old framebuffer and decrement the count
            NSInteger currentTextureID = (numberOfMatchingTextures - 1);
            while ((textureFromCache == nil) && (currentTextureID >= 0))
            {
                NSString *textureHash = [NSString stringWithFormat:@"%@-%ld", lookupHash, (long)currentTextureID];
                textureFromCache = [framebufferCache objectForKey:textureHash];
                // Test the values in the cache first, to see if they got invalidated behind our back
                if (textureFromCache != nil)
                {
                    // Withdraw this from the cache while it's in use
                    //                    NSLog(@"reuse buffer: %@", textureFromCache);
                    [framebufferCache removeObjectForKey:textureHash];
                }
                currentTextureID--;
            }
            
            currentTextureID++;
            
            [framebufferTypeCounts setObject:[NSNumber numberWithInteger:currentTextureID] forKey:lookupHash];
            
            if (textureFromCache == nil)
            {
                textureFromCache = [[MetalImageTexture alloc] initWithTextureSize:size];
                //                NSLog(@"create new buffer2: %p",textureFromCache);
            }
        }
        //NSLog(@"In cache: %@", framebufferCache.allValues);
        
        [textureFromCache enableReferenceCounting];
        [textureFromCache lock];
        return textureFromCache;
    }
}

- (void)cacheTexture:(MetalImageTexture *)texture;
{
    @synchronized (self) {
        [texture clearAllLocks];
        
        NSString *lookupHash = [self hashForSize:texture.size pixelFormat:texture.pixelFormat];
        NSNumber *numberOfMatchingTexturesInCache = [framebufferTypeCounts objectForKey:lookupHash];
        NSInteger numberOfMatchingTextures = [numberOfMatchingTexturesInCache integerValue];
        
        NSString *textureHash = [NSString stringWithFormat:@"%@-%ld", lookupHash, (long)numberOfMatchingTextures];
        
        [framebufferCache setObject:texture forKey:textureHash];
        [framebufferTypeCounts setObject:[NSNumber numberWithInteger:(numberOfMatchingTextures + 1)] forKey:lookupHash];
    }
}

- (void)purgeAllUnassignedTextures
{
    @synchronized (self) {
        NSLog(@"purgeAllUnassignedTextures");
        [framebufferCache removeAllObjects];
        [framebufferTypeCounts removeAllObjects];
        CVMetalTextureCacheFlush([[MetalImageContext sharedImageProcessingContext] coreVideoTextureCache], 0);
    }
}

- (void)addFramebufferToActiveImageCaptureList:(MetalImageTexture *)framebuffer;
{
    @synchronized (self) {
        [activeImageCaptureList addObject:framebuffer];
    }
}

- (void)removeFramebufferFromActiveImageCaptureList:(MetalImageTexture *)framebuffer;
{
    @synchronized (self) {
        [activeImageCaptureList removeObject:framebuffer];
    }
}

@end

@implementation MTLTextureDescriptor (reuseIdentifier)

- (NSString *)reuseIdentifier {
    return [NSString stringWithFormat:@"%dx%dx%d-%d-%d-%d",
            (int)self.width, (int)self.height, (int)self.depth, (int)self.pixelFormat, (int)self.textureType, (int)self.mipmapLevelCount];
}

@end


