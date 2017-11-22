//
//  MetalImagePreprocess.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/6.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "MetalImagePreprocess.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@interface MetalImagePreprocess () {
    
@protected
    MetalImageTexture *firstInputTexture;
    MetalImageRotationMode inputRotation;
    dispatch_semaphore_t  m_InflightSemaphore;
}

@end

@implementation MetalImagePreprocess

- (instancetype)init {
    if (self = [super init]) {
        m_InflightSemaphore = dispatch_semaphore_create(1);
        _borderSize = 1;
    }
    return self;
}

#pragma mark - MetalImageInput delegate

- (void)setInputTexture:(MetalImageTexture *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    firstInputTexture = newInputFramebuffer;
    [firstInputTexture lock];
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    inputRotation = newInputRotation;
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    dispatch_semaphore_wait(m_InflightSemaphore, DISPATCH_TIME_FOREVER);
    
    id <MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
    __block dispatch_semaphore_t dispatchSemaphore = m_InflightSemaphore;
    [commandBuffer addCompletedHandler:^(id <MTLCommandBuffer> cmdb) {
        dispatch_semaphore_signal(dispatchSemaphore);
    }];
    
    id<MTLTexture> texture = [firstInputTexture texture];
    uint width = (uint)[texture width];
    uint height = (uint)[texture height];
    
    outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:MTLUInt2Make(width+2*_borderSize, height+2*_borderSize)];
    
    id <MTLBlitCommandEncoder> blitEncoder = [commandBuffer blitCommandEncoder];
    NSAssert(blitEncoder != nil, @"Failed to create compute encode.");
    
    [blitEncoder copyFromTexture:texture sourceSlice:0 sourceLevel:0 sourceOrigin:MTLOriginMake(0, 0, 0) sourceSize:MTLSizeMake(width, height, 1)
                       toTexture:[outputTexture texture] destinationSlice:0 destinationLevel:0 destinationOrigin:MTLOriginMake(_borderSize, _borderSize, 0)];
    [blitEncoder endEncoding];
    
    [MetalDevice commitCommandBufferWaitUntilDone:YES];
    
    [self notifyTargetsAboutNewTextureAtTime:frameTime];
    
    [firstInputTexture unlock];
}

- (MetalImageRotationMode)rotationForOutput {
    return inputRotation;
}

@end
