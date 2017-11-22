//
//  MetalImagePrewittEdgeDetectionFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImagePrewittEdgeDetectionFilter.h"

@implementation MetalImagePrewittEdgeDetectionFilter

- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_PrewittEdgeDetectionFilter"]) {
        self.edgeStrength = 1.0;
    }
    return self;
}

@end
