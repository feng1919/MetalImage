//
//  MetalImageFASTCornerDetectionFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFASTCornerDetectionFilter.h"

@implementation MetalImageFASTCornerDetectionFilter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
//        [derivativeFilter addTarget:blurFilter];
//        [blurFilter addTarget:harrisCornerDetectionFilter];
//        [harrisCornerDetectionFilter addTarget:nonMaximumSuppressionFilter];
//        [simpleThresholdFilter addTarget:colorPackingFilter];
//    
//        self.initialFilters = [NSArray arrayWithObjects:derivativeFilter, nil];
//        self.terminalFilter = colorPackingFilter;
//        self.terminalFilter = nonMaximumSuppressionFilter;
    
    return self;
}


@end
