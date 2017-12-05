//
//  MIRGBErosionFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MITwoPassTextureSamplingFilter.h"

// For each pixel, this sets it to the minimum value of each color channel in a rectangular neighborhood extending out dilationRadius pixels from the center.
// This extends out dark features, and can be used for abstraction of color images.

@interface MIRGBErosionFilter : MITwoPassTextureSamplingFilter

// Acceptable values for erosionRadius, which sets the distance in pixels to sample out from the center, are 1, 2, 3, and 4.
- (id)initWithRadius:(MTLUInt)erosionRadius;

@end
