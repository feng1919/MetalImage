//
//  MILowPassFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/12/5.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MILowPassFilter.h"

@interface MILowPassFilter()

@end

@implementation MILowPassFilter

- (instancetype)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    // Take in the frame and blend it with the previous one
    dissolveBlendFilter = [[MIDissolveBlendFilter alloc] init];
    [self addFilter:dissolveBlendFilter];
    
    // Buffer the result to be fed back into the blend
    bufferFilter = [[MetalImageBuffer alloc] init];
    [self addFilter:bufferFilter];
    
    // Texture location 0 needs to be the original image for the dissolve blend
    [bufferFilter addTarget:dissolveBlendFilter atTextureLocation:1];
    [dissolveBlendFilter addTarget:bufferFilter];
    
    [dissolveBlendFilter disableSecondFrameCheck];
    
    // To prevent double updating of this filter, disable updates from the sharp image side
    //    self.inputFilterToIgnoreForUpdates = unsharpMaskFilter;
    
    self.initialFilters = [NSArray arrayWithObject:dissolveBlendFilter];
    self.terminalFilter = dissolveBlendFilter;
    
    self.filterStrength = 0.5;
    
    return self;
}

#pragma mark - Accessor

- (void)setFilterStrength:(MTLFloat)filterStrength {
    dissolveBlendFilter.mix = filterStrength;
}

- (MTLFloat)filterStrength {
    return dissolveBlendFilter.mix;
}

#pragma mark - Override

- (void)addTarget:(id<MetalImageInput>)newTarget {
    [self.terminalFilter addTarget:newTarget];
    
    //if use MetalImagePipline,will cause self.termainlFilter removeAllTargets,so need add bufferFilter back
    if (self.terminalFilter == dissolveBlendFilter && ![self.terminalFilter.targets containsObject:bufferFilter]) {
        [self.terminalFilter addTarget:bufferFilter atTextureLocation:1];
    }
}

- (void)addTarget:(id<MetalImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation;
{
    [self.terminalFilter addTarget:newTarget atTextureLocation:textureLocation];
    //if use MetalImagePipline,will cause self.termainlFilter removeAllTargets,so need add bufferFilter back
    if (self.terminalFilter == dissolveBlendFilter && ![self.terminalFilter.targets containsObject:bufferFilter]) {
        [self.terminalFilter addTarget:bufferFilter atTextureLocation:1];
    }
}

@end
