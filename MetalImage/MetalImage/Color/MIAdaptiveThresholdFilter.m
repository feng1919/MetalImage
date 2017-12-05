//
//  MIAdaptiveThresholdFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/9/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIAdaptiveThresholdFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"
#import "MetalImageFilter.h"
#import "MetalImageTwoInputFilter.h"
#import "MIGrayscaleFilter.h"
//#import "MetalImageBoxBlurFilter.h"

@interface MIAdaptiveThresholdFilter() {
    
}

@end

@implementation MIAdaptiveThresholdFilter


#pragma mark -
#pragma mark Accessors

- (void)setBlurRadiusInPixels:(CGFloat)newValue;
{
//    boxBlurFilter.blurRadiusInPixels = newValue;
}

- (CGFloat)blurRadiusInPixels;
{
//    return boxBlurFilter.blurRadiusInPixels;
    return 0;
}

@end
