//
//  MISaturationFilter.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MISaturationFilter : MetalImageFilter

/** Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
 */
@property (nonatomic,assign) MTLFloat saturation;

@end
