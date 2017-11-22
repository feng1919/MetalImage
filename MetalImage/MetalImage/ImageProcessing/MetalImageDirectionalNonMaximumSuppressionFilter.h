//
//  MetalImageDirectionalNonMaximumSuppressionFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MetalImageDirectionalNonMaximumSuppressionFilter : MetalImageFilter

// The texel width and height determines how far out to sample from this texel.
// By default, this is the normalized width of a pixel, but this can be overridden for different effects.
@property (readwrite, nonatomic) MTLFloat2 texelSize;

// These thresholds set cutoffs for the intensities that definitely get registered (upper threshold) and those that definitely don't (lower threshold)
@property(readwrite, nonatomic) MTLFloat upperThreshold;
@property(readwrite, nonatomic) MTLFloat lowerThreshold;

@end
