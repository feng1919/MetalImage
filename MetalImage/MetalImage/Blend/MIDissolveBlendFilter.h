//
//  MIDissolveBlendFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoInputFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIDissolveBlendFilter : MetalImageTwoInputFilter

// Mix ranges from 0.0 (only image 1) to 1.0 (only image 2), with 0.5 (half of either) as the normal level
@property(readwrite, nonatomic) MTLFloat mix;

@end

NS_ASSUME_NONNULL_END
