//
//  MetalImageCrosshatchFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/9/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MetalImageCrosshatchFilter : MetalImageFilter

// The fractional width of the image to use as the spacing for the crosshatch. The default is 0.03.
@property(readwrite, nonatomic) MTLFloat crossHatchSpacing;

// A relative width for the crosshatch lines. The default is 0.003.
@property(readwrite, nonatomic) MTLFloat lineWidth;


@end
