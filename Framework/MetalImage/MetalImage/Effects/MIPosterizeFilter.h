//
//  MIPosterizeFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN
/** This reduces the color dynamic range into the number of steps specified, leading to a cartoon-like simple shading of the image.
 */

@interface MIPosterizeFilter : MetalImageFilter

/** The number of color levels to reduce the image space to. This ranges from 1 to 256, with a default of 10.
 */
@property(readwrite, nonatomic) MTLUInt colorLevels;

@end

NS_ASSUME_NONNULL_END
