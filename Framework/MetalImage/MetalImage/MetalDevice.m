//
//  MetalDevice.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/17.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalDevice.h"
#import <UIKit/UIDevice.h>

static MetalDevice *_sharedMetalDevice = nil;

@interface MetalDevice ()

@property (nonatomic,strong) id<MTLDevice> device;
@property (nonatomic,strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic,strong) id<MTLCommandBuffer> commandBuffer;

@end

@implementation MetalDevice

+ (void)addBundle:(NSBundle *)bundle toArray:(NSMutableArray<NSBundle *> *)bundles {
    if (bundle == nil || [bundles containsObject:bundle]) {
        return;
    }

    [bundles addObject:bundle];
}

+ (NSArray<NSBundle *> *)metalImageResourceBundles {
    NSMutableArray<NSBundle *> *bundles = [NSMutableArray array];
    NSMutableArray<NSBundle *> *searchBundles = [NSMutableArray array];
    NSArray<NSString *> *bundleNames = @[@"MetalImage_MetalImage", @"MetalImage"];

    [self addBundle:[NSBundle bundleWithIdentifier:@"com.fengshi.MetalImage"] toArray:searchBundles];
    [self addBundle:[NSBundle bundleForClass:self] toArray:searchBundles];
    [self addBundle:[NSBundle mainBundle] toArray:searchBundles];

    NSBundle *mainBundle = [NSBundle mainBundle];
    for (NSBundle *bundle in searchBundles) {
        if (bundle != mainBundle) {
            [self addBundle:bundle toArray:bundles];
        }

        NSMutableArray<NSURL *> *searchURLs = [NSMutableArray array];
        if (bundle.resourceURL != nil) {
            [searchURLs addObject:bundle.resourceURL];
        }
        if (bundle.bundleURL != nil && ![searchURLs containsObject:bundle.bundleURL]) {
            [searchURLs addObject:bundle.bundleURL];
        }

        for (NSURL *searchURL in searchURLs) {
            for (NSString *bundleName in bundleNames) {
                NSURL *bundleURL = [searchURL URLByAppendingPathComponent:[bundleName stringByAppendingString:@".bundle"]];
                NSBundle *resourceBundle = [NSBundle bundleWithURL:bundleURL];
                if (resourceBundle != nil) {
                    [self addBundle:resourceBundle toArray:bundles];
                }
            }
        }
    }

    return bundles;
}

+ (nullable id<MTLLibrary>)libraryFromBundle:(NSBundle *)bundle error:(NSError **)error {
    if (bundle == nil) {
        return nil;
    }

    id<MTLLibrary> library = [_sharedMetalDevice.device newDefaultLibraryWithBundle:bundle error:error];
    if (library != nil) {
        return library;
    }

    for (NSString *libraryName in @[@"default", @"MetalImageShader", @"MetalImage"]) {
        NSString *libraryPath = [bundle pathForResource:libraryName ofType:@"metallib"];
        if (libraryPath.length == 0) {
            continue;
        }

        library = [_sharedMetalDevice.device newLibraryWithFile:libraryPath error:error];
        if (library != nil) {
            return library;
        }
    }

    return nil;
}

+ (void)initialize {
    if (self == [MetalDevice class]) {
        _sharedMetalDevice = [[MetalDevice alloc] init];
    }
}

+ (MetalDevice *)sharedInstance {
    return _sharedMetalDevice;
}

+ (id<MTLDevice>)sharedMTLDevice {
    return _sharedMetalDevice.device;
}

+ (id<MTLCommandQueue>)sharedCommandQueue {
    return _sharedMetalDevice.commandQueue;
}

+ (id<MTLLibrary>)MetalImageLibrary {
    //iOS8.0上newDefaultLibrary返回为空的bug
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0f) {
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:@"/"];
    }

    NSError *error = nil;
    for (NSBundle *bundle in [self metalImageResourceBundles]) {
        id<MTLLibrary> library = [self libraryFromBundle:bundle error:&error];
        if (library != nil) {
            return library;
        }
        error = nil;
    }

    NSString *libPath = [[NSBundle mainBundle] pathForResource:@"MetalImageShader" ofType:@"metallib"];
    if (libPath.length > 0) {
        id<MTLLibrary> library = [_sharedMetalDevice.device newLibraryWithFile:libPath error:&error];
        if (library != nil) {
            return library;
        }
    }

    NSLog(@"load metal library failed. err: %@", error);
    NSAssert(NO, @"load metal library failed. err: %@", error);
    return nil;
}

- (instancetype)init {
    if (self = [super init]) {
        self.device = MTLCreateSystemDefaultDevice();
        self.commandQueue = [self.device newCommandQueue];
        
        NSParameterAssert(_commandQueue);
        NSParameterAssert(_device);
    }
    return self;
}

+ (id<MTLCommandBuffer>)sharedCommandBuffer {
    @synchronized (self) {
        if (_sharedMetalDevice.commandBuffer == nil) {
            _sharedMetalDevice.commandBuffer = [_sharedMetalDevice.commandQueue commandBuffer];
//            [_sharedMetalDevice.commandBuffer enqueue];
            
            NSParameterAssert(_sharedMetalDevice);
        }
        return _sharedMetalDevice.commandBuffer;
    }
}

+ (void)commitCommandBuffer {
    [self commitCommandBufferWaitUntilDone:NO];
}

+ (void)commitCommandBufferWithCompletion:(void (^)(id<MTLCommandBuffer>))completion {
    [_sharedMetalDevice.commandBuffer addCompletedHandler:completion];
    [self commitCommandBufferWaitUntilDone:NO];
}

+ (void)commitCommandBufferWaitUntilDone:(BOOL)waitUtilDone {
    @synchronized (self) {
        [_sharedMetalDevice.commandBuffer commit];
        if (waitUtilDone) {
            [_sharedMetalDevice.commandBuffer waitUntilCompleted];
        }
        _sharedMetalDevice.commandBuffer = nil;
    }
}

+ (void)commitCommandBufferWaitUntilScheduled:(BOOL)waitUtilScheduled {
    @synchronized (self) {
        [_sharedMetalDevice.commandBuffer commit];
        if (waitUtilScheduled) {
            [_sharedMetalDevice.commandBuffer waitUntilScheduled];
        }
        _sharedMetalDevice.commandBuffer = nil;
    }
}

@end
