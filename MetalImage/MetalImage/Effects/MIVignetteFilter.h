//
//  MIVignetteFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

/** Performs a vignetting effect, fading out the image at the edges
 */
@interface MIVignetteFilter : MetalImageFilter

// the center for the vignette in tex coords (defaults to 0.5, 0.5)
@property (nonatomic, readwrite) MTLFloat2 vignetteCenter;

// The color to use for the Vignette (defaults to black)
@property (nonatomic, readwrite) MTLFloat3 vignetteColor;

// The normalized distance from the center where the vignette effect starts. Default of 0.5.
@property (nonatomic, readwrite) MTLFloat vignetteStart;

// The normalized distance from the center where the vignette effect ends. Default of 0.75.
@property (nonatomic, readwrite) MTLFloat vignetteEnd;

@end

NS_ASSUME_NONNULL_END
