//
//  MetalImageRGBFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/8/15.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MetalImageRGBFilter : MetalImageFilter

// Normalized values by which each color channel is multiplied. The range is from 0.0 up, with 1.0 as the default.
@property (readwrite, nonatomic) MTLFloat red;
@property (readwrite, nonatomic) MTLFloat green;
@property (readwrite, nonatomic) MTLFloat blue;

@end
