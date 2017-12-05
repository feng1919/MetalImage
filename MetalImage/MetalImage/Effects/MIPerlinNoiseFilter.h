//
//  MIPerlinNoiseFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MIPerlinNoiseFilter : MetalImageFilter

@property (readwrite, nonatomic) MTLFloat4 colorStart;
@property (readwrite, nonatomic) MTLFloat4 colorFinish;

@property (readwrite, nonatomic) MTLFloat scale;


@end
