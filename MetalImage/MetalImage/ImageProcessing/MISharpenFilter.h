//
//  MISharpenFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/16.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MISharpenFilter : MetalImageFilter

// Sharpness ranges from -4.0 to 4.0, with 0.0 as the normal level
@property(readwrite, nonatomic) MTLFloat sharpness;

@end
