//
//  MetalImageSolarizeFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/9/2.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

/** Pixels with a luminance above the threshold will invert their color
 */
@interface MetalImageSolarizeFilter : MetalImageFilter

/** Anything above this luminance will be inverted, and anything below normal. Ranges from 0.0 to 1.0, with 0.5 as the default
 */
@property(readwrite, nonatomic) CGFloat threshold;

@end
