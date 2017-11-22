//
//  MetalImageOpacityFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/8/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MetalImageOpacityFilter : MetalImageFilter

// Opacity ranges from 0.0 to 1.0, with 1.0 as the normal setting
@property(readwrite, nonatomic) MTLFloat opacity;

@end
