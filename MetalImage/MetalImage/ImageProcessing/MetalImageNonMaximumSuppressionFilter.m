//
//  MetalImageNonMaximumSuppressionFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageNonMaximumSuppressionFilter.h"

@implementation MetalImageNonMaximumSuppressionFilter

- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_NonMaximumSuppressionFilter"]) {
        
    }
    
    return self;
}

@end
