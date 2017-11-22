//
//  MetalImageDirectionalSobelEdgeDetectionFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageDirectionalSobelEdgeDetectionFilter.h"

@implementation MetalImageDirectionalSobelEdgeDetectionFilter

- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_DirectionalSobelEdgeDetectionFilter"]) {
        
    }
    
    return self;
}

@end
