//
//  MIBulgeDistortionFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

/// Creates a bulge distortion on the image
@interface MIBulgeDistortionFilter : MetalImageFilter

/// The center about which to apply the distortion, with a default of (0.5, 0.5)
@property(readwrite, nonatomic) MTLFloat2 center;
/// The radius of the distortion, ranging from 0.0 to 1.0, with a default of 0.25
@property(readwrite, nonatomic) MTLFloat radius;
/// The amount of distortion to apply, from -1.0 to 1.0, with a default of 0.5
@property(readwrite, nonatomic) MTLFloat scale;

@end

NS_ASSUME_NONNULL_END
