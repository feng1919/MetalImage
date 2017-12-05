//
//  MIContrastFilter.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/15.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MIContrastFilter : MetalImageFilter

/** Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
 */
@property (nonatomic,assign) MTLFloat contrast;

@end
