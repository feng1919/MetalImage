//
//  MetalImageInput.h
//  MetalImage
//
//  Created by stonefeng on 2017/2/11.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "MetalImageGlobal.h"
#import "MetalImageTexture.h"

typedef struct {
    CMTime frameTime;
    MetalImageRotationMode rotationMode;
    BOOL frameCheckDisabled;
    BOOL hasReceivedFrame;
    BOOL hasSetTarget;
}MetalImageInputParameter;

NS_ASSUME_NONNULL_BEGIN

@protocol MetalImageInput <NSObject>

@required
- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex;
- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;

@optional
- (NSInteger)nextAvailableTextureIndex;
- (void)reserveTextureIndex:(NSInteger)textureIndex;
- (void)releaseTextureIndex:(NSInteger)textureIndex;

- (CGSize)maximumOutputSize;
- (void)endProcessing;
- (BOOL)shouldIgnoreUpdatesToThisTarget;
- (BOOL)enabled;
- (BOOL)wantsMonochromeInput;
- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue;


@end

NS_ASSUME_NONNULL_END
