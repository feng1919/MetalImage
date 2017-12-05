//
//  MILuminanceThresholdFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/9/27.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

/** Pixels with a luminance above the threshold will appear white, and those below will be black
 */
@interface MILuminanceThresholdFilter : MetalImageFilter

/** Anything above this luminance will be white, and anything below black. Ranges from 0.0 to 1.0, with 0.5 as the default
 */
@property(readwrite, nonatomic) MTLFloat threshold;

@end
