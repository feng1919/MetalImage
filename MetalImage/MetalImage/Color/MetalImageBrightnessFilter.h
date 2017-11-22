//
//  MetalImageBrightnessFilter.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/16.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MetalImageBrightnessFilter : MetalImageFilter

// Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
@property (nonatomic,assign) MTLFloat brightness;

@end
