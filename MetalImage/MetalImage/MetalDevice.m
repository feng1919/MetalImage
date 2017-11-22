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
    static NSString *MetalImageBundleName = @"com.tencent.MetalImage";
    NSBundle *MetalImageBundle = [NSBundle bundleWithIdentifier:MetalImageBundleName];
    
    //iOS8.0上newDefaultLibrary返回为空的bug
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0f) {
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:@"/"];
    }
    
    if (MetalImageBundle) {
        //load from dynamic framework
        
        NSError *error = nil;
        id<MTLLibrary> library = [_sharedMetalDevice.device newDefaultLibraryWithBundle:MetalImageBundle error:&error];
        
        if (error) {
            NSLog(@"load metal library failed. err: %@", error);
            NSAssert(NO, @"load metal library failed. err: %@", error);
        }
        
        return library;
    }
    else {
        //load from static library
        
        NSError *error = nil;
        //        NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks"];
        NSString *libPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"MetalImageShader.metallib"];
        id<MTLLibrary> library = [_sharedMetalDevice.device newLibraryWithFile:libPath error:&error];
        
        if (error) {
            NSLog(@"load metal library failed. err: %@", error);
            NSAssert(NO, @"load metal library failed. err: %@", error);
        }
        
        return library;
    }
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
            [_sharedMetalDevice.commandBuffer enqueue];
            
            NSParameterAssert(_sharedMetalDevice);
        }
        return _sharedMetalDevice.commandBuffer;
    }
}

+ (void)commitCommandBuffer {
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

@end
