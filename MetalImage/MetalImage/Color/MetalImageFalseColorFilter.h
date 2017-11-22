//
//  MetalImageFalseColorFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/7/23.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MetalImageFalseColorFilter : MetalImageFilter

// The first and second colors specify what colors replace the dark and light areas of the image, respectively.
// The defaults are (0.0, 0.0, 0.5) amd (1.0, 0.0, 0.0).
@property (readwrite, nonatomic) MTLFloat4 firstColor;
@property (readwrite, nonatomic) MTLFloat4 secondColor;

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end
