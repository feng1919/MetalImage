//
//  MIAdaptiveThresholdFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/9/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilterGroup.h"

@interface MIAdaptiveThresholdFilter : MetalImageFilterGroup

/** A multiplier for the background averaging blur radius in pixels, with a default of 4
 */
@property(readwrite, nonatomic) CGFloat blurRadiusInPixels;

@end
