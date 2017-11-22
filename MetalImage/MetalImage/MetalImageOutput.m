//
//  MetalImageOutput.m
//  MetalImage
//
//  Created by stonefeng on 2017/2/11.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageOutput.h"

@implementation MetalImageOutput

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    targets = [[NSMutableArray alloc] init];
    targetTextureIndices = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc
{
    [self removeAllTargets];
}

#pragma mark - Managing targets

- (MetalImageTexture *)outputTexture {
    return outputTexture;
}

- (MetalImageRotationMode)rotationForOutput {
    return kMetalImageNoRotation;
}

- (MTLUInt2)textureSizeForOutput {
    return MTLUInt2Zero;
//    if (MetalImageRotationSwapsWidthAndHeight([self rotationForOutput])) {
//        MTLUInt2 textureSize = outputTexture.size;
//        return MTLUInt2Make(textureSize.y, textureSize.x);
//    }
//    else {
//        return outputTexture.size;
//    }
}

- (void)removeOutputTexture {
    if (outputTexture.isReferenceCountingEnable) {
        [outputTexture unlock];
        outputTexture = nil;
    }
}

- (void)setOutputTextureToTargets {
    for (id<MetalImageInput> currentTarget in targets) {
        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
        NSInteger textureIndex = [targetTextureIndices[indexOfObject] integerValue];
        [currentTarget setInputRotation:[self rotationForOutput] atIndex:textureIndex];
        [currentTarget setInputTexture:outputTexture atIndex:textureIndex];
    }
}

- (void)notifyTargetsAboutNewTextureAtTime:(CMTime)time {
    
    [self setOutputTextureToTargets];
    [self removeOutputTexture];
    
    for (id<MetalImageInput> currentTarget in targets)
    {
        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
        NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        [currentTarget newTextureReadyAtTime:time atIndex:textureIndex];
    }
}

- (NSArray*)targets
{
    @synchronized (self) {
        return [NSArray arrayWithArray:targets];
    }
}

- (void)addTarget:(id<MetalImageInput>)newTarget
{
    @synchronized (self) {
        NSInteger nextAvailableTextureIndex = 0;
        if ([newTarget respondsToSelector:@selector(nextAvailableTextureIndex)]) {
            nextAvailableTextureIndex = [newTarget nextAvailableTextureIndex];
        }
        
        [self addTarget:newTarget atTextureLocation:nextAvailableTextureIndex];
    }
}

- (void)addTarget:(id<MetalImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation
{
    @synchronized (self) {
        if([targets containsObject:newTarget])
        {
            return;
        }
        
        [targets addObject:newTarget];
        [targetTextureIndices addObject:[NSNumber numberWithInteger:textureLocation]];
        
        if ([newTarget respondsToSelector:@selector(reserveTextureIndex:)]) {
            [newTarget reserveTextureIndex:textureLocation];
        }
    }
}

- (void)removeTarget:(id<MetalImageInput>)targetToRemove
{
    @synchronized (self) {
        if(![targets containsObject:targetToRemove])
        {
            return;
        }
        
        NSInteger indexOfObject = [targets indexOfObject:targetToRemove];
        NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        
        [targetTextureIndices removeObjectAtIndex:indexOfObject];
        [targets removeObject:targetToRemove];
        
        if ([targetToRemove respondsToSelector:@selector(releaseTextureIndex:)]) {
            [targetToRemove releaseTextureIndex:textureIndexOfTarget];
        }
    }
}

- (void)removeAllTargets
{
    @synchronized (self) {
        [targets removeAllObjects];
        [targetTextureIndices removeAllObjects];
    }
}

@end
