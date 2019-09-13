//
//  MIPolarPixellateFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIPolarPixellateFilter : MetalImageFilter

// The center about which to apply the distortion, with a default of (0.5, 0.5)
@property(readwrite, nonatomic) MTLFloat2 center;
// The amount of distortion to apply, from (-2.0, -2.0) to (2.0, 2.0), with a default of (0.05, 0.05)
@property(readwrite, nonatomic) MTLFloat2 pixelSize;

@end

NS_ASSUME_NONNULL_END
