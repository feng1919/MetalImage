//
//  MIWhiteBalanceFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/7/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

/**
 * Created by Alaric Cole
 * Allows adjustment of color temperature in terms of what an image was effectively shot in.
 * This means higher Kelvin values will warm the image, while lower values will cool it.
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface MIWhiteBalanceFilter : MetalImageFilter

//choose color temperature, in degrees Kelvin
@property(readwrite, nonatomic) CGFloat temperature;

//adjust tint to compensate
@property(readwrite, nonatomic) CGFloat tint;

@end

NS_ASSUME_NONNULL_END
