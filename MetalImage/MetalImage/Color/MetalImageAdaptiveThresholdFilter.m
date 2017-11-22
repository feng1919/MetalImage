//
//  MetalImageAdaptiveThresholdFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/9/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageAdaptiveThresholdFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"
#import "MetalImageFilter.h"
#import "MetalImageTwoInputFilter.h"
#import "MetalImageGrayscaleFilter.h"
//#import "MetalImageBoxBlurFilter.h"

@interface MetalImageAdaptiveThresholdFilter() {
    
}

@end

@implementation MetalImageAdaptiveThresholdFilter


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
