//
//  MIPerlinNoiseFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIPerlinNoiseFilter : MetalImageFilter

@property (readwrite, nonatomic) MTLFloat4 colorStart;
@property (readwrite, nonatomic) MTLFloat4 colorFinish;

@property (readwrite, nonatomic) MTLFloat scale;


@end

NS_ASSUME_NONNULL_END
