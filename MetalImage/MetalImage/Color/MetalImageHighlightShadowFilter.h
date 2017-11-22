//
//  MetalImageHighlightShadowFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/7/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MetalImageHighlightShadowFilter : MetalImageFilter

/**
 * 0 - 1, increase to lighten shadows.
 * @default 0
 */
@property(readwrite, nonatomic) MTLFloat shadows;

/**
 * 0 - 1, decrease to darken highlights.
 * @default 1
 */
@property(readwrite, nonatomic) MTLFloat highlights;

@end
