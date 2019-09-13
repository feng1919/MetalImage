//
//  MIExposureFilter.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIExposureFilter : MetalImageFilter

// Exposure ranges from -10.0 to 10.0, with 0.0 as the normal level
@property (nonatomic,assign) MTLFloat exposure;

@end

NS_ASSUME_NONNULL_END
