//
//  MetalImageClosingFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilterGroup.h"

@class MetalImageErosionFilter;
@class MetalImageDilationFilter;

// A filter that first performs a dilation on the red channel of an image, followed by an erosion of the same radius.
// This helps to filter out smaller dark elements.

@interface MetalImageClosingFilter : MetalImageFilterGroup
{
    MetalImageErosionFilter *erosionFilter;
    MetalImageDilationFilter *dilationFilter;
}

@property(readwrite, nonatomic) MTLFloat verticalTexelSpacing, horizontalTexelSpacing;

- (instancetype)initWithRadius:(MTLUInt)radius;

@end
