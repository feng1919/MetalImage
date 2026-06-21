//
//  MIDilationFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MITwoPassTextureSamplingFilter.h"

// For each pixel, this sets it to the maximum value of the red channel in a rectangular neighborhood extending out dilationRadius pixels from the center.
// This extends out bright features, and is most commonly used with black-and-white thresholded images.

NS_ASSUME_NONNULL_BEGIN

@interface MIDilationFilter : MITwoPassTextureSamplingFilter

// Acceptable values for dilationRadius, which sets the distance in pixels to sample out from the center, are 1, 2, 3, and 4.
- (instancetype)initWithRadius:(MTLUInt)dilationRadius;

@end

NS_ASSUME_NONNULL_END
