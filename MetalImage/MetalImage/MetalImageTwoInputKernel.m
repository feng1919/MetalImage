//
//  MetalImageTwoInputKernel.m
//  MetalImage
//
//  Created by stonefeng on 2017/4/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoInputKernel.h"
#import "MetalDevice.h"

@implementation MetalImageTwoInputKernel

- (instancetype)init {
    return [self initWithFunctionName:@"kernel_default2"];
}

#pragma mark - MetalImageInput delegate
- (NSInteger)nextAvailableTextureIndex {
    if (firstInputParameter.hasSetTarget) {
        return 1;
    }
    else {
        return 0;
    }
}

- (void)reserveTextureIndex:(NSInteger)index {
    if (index == 0) {
        firstInputParameter.hasSetTarget = YES;
    }
}

- (void)releaseTextureIndex:(NSInteger)index {
    if (index == 0) {
        firstInputParameter.hasSetTarget = NO;
    }
}

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    NSParameterAssert(newInputTexture);
    
    if (textureIndex == 0) {
        firstInputTexture = newInputTexture;
        [firstInputTexture lock];
    }
    else {
        secondInputTexture = newInputTexture;
        [secondInputTexture lock];
    }
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    if (textureIndex == 0) {
        firstInputParameter.rotationMode = newInputRotation;
    }
    else {
        secondInputParameter.rotationMode = newInputRotation;
    }
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    if (firstInputParameter.hasReceivedFrame && secondInputParameter.hasReceivedFrame) {
        return;
    }
    
    BOOL updatedMovieFrameOppositeStillImage = NO;
    
    if (textureIndex == 0)
    {
        firstInputParameter.hasReceivedFrame = YES;
        firstInputParameter.frameTime = frameTime;
        if (secondInputParameter.frameCheckDisabled)
        {
            secondInputParameter.hasReceivedFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(secondInputParameter.frameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else
    {
        secondInputParameter.hasReceivedFrame = YES;
        secondInputParameter.frameTime = frameTime;
        if (firstInputParameter.frameCheckDisabled)
        {
            firstInputParameter.hasReceivedFrame = YES;
        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstInputParameter.frameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    
    if ((firstInputParameter.hasReceivedFrame && secondInputParameter.hasReceivedFrame) || updatedMovieFrameOppositeStillImage)
    {
        CMTime passOnFrameTime = (!CMTIME_IS_INDEFINITE(firstInputParameter.frameTime)) ? firstInputParameter.frameTime : secondInputParameter.frameTime;
        // Bugfix when trying to record: always use time from first input (unless indefinite, in which case use the second input)
        [super newTextureReadyAtTime:passOnFrameTime atIndex:0];
        firstInputParameter.hasReceivedFrame = NO;
        secondInputParameter.hasReceivedFrame = NO;
    }
}

- (void)computeTexture {
    
    id <MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
    id <MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    [self assembleComputeEncoder:computeEncoder];
    
    [firstInputTexture unlock];
    [secondInputTexture unlock];
}


@end
