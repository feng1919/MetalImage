//
//  MetalImageOutput.h
//  MetalImage
//
//  Created by stonefeng on 2017/2/11.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetalImageFunction.h"
#import "MetalImageInput.h"
#import "MetalImageTexture.h"

@interface MetalImageOutput : NSObject {
    
@protected
    MetalImageTexture *outputTexture;
    NSMutableArray <id<MetalImageInput>> *targets;
    NSMutableArray <NSNumber *> *targetTextureIndices;
}

/// @name Managing targets
- (MetalImageTexture *)outputTexture;
- (MetalImageRotationMode)rotationForOutput;
- (MTLUInt2)textureSizeForOutput;

- (void)removeOutputTexture;
- (void)setOutputTextureToTargets;
- (void)notifyTargetsAboutNewTextureAtTime:(CMTime)time;

/** Returns an array of the current targets.
 */
- (NSArray<id<MetalImageInput>>*)targets;

/** Adds a target to receive notifications when new frames are available.
 
 The target will be asked for its next available texture.
 
 See [MetalImageInput newFrameReadyAtTime:]
 
 @param newTarget Target to be added
 */
- (void)addTarget:(id<MetalImageInput>)newTarget;

/** Adds a target to receive notifications when new frames are available.
 
 See [MetalImageInput newFrameReadyAtTime:]
 
 @param newTarget Target to be added
 */
- (void)addTarget:(id<MetalImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation;

/** Removes a target. The target will no longer receive notifications when new frames are available.
 
 @param targetToRemove Target to be removed
 */
- (void)removeTarget:(id<MetalImageInput>)targetToRemove;

/** Removes all targets.
 */
- (void)removeAllTargets;

@end
