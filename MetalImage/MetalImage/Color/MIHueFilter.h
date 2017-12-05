//
//  MIHueFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/7/22.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MIHueFilter : MetalImageFilter {
    GLint hueAdjustUniform;
}

@property (nonatomic, readwrite) CGFloat hue;

@end
