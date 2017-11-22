//
//  MetalImageMedianFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/18.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageMedianFilter.h"

@implementation MetalImageMedianFilter

- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_MedianFilter"]) {
        
    }
    return self;
}

@end
