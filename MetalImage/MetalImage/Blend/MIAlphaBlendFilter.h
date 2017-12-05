//
//  MIAlphaBlendFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoInputFilter.h"

@interface MIAlphaBlendFilter : MetalImageTwoInputFilter

// Mix ranges from 0.0 (only image 1) to 1.0 (only image 2), with 1.0 as the normal level
@property(readwrite, nonatomic) CGFloat mix;

@end
