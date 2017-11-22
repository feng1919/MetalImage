//
//  MetalImageGammaFilter.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MetalImageGammaFilter : MetalImageFilter

// Gamma ranges from 0.0 to 3.0, with 1.0 as the normal level
@property (nonatomic,assign) MTLFloat gamma;

@end
