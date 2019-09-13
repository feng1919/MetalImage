//
//  MILuminanceRangeFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/8/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MILuminanceRangeFilter : MetalImageFilter

/** The degree to reduce the luminance range, from 0.0 to 1.0. Default is 0.6.
 */
@property(readwrite, nonatomic) CGFloat rangeReductionFactor;

@end

NS_ASSUME_NONNULL_END
