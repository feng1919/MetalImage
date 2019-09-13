//
//  MIRGBClosingFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilterGroup.h"

@class MIRGBErosionFilter;
@class MIRGBDilationFilter;

// A filter that first performs a dilation on each color channel of an image, followed by an erosion of the same radius.
// This helps to filter out smaller dark elements.

NS_ASSUME_NONNULL_BEGIN

@interface MIRGBClosingFilter : MetalImageFilterGroup
{
    MIRGBErosionFilter *erosionFilter;
    MIRGBDilationFilter *dilationFilter;
}

@property(readwrite, nonatomic) MTLFloat verticalTexelSpacing, horizontalTexelSpacing;

- (instancetype)initWithRadius:(MTLUInt)radius;

@end

NS_ASSUME_NONNULL_END
