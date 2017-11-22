//
//  MetalImageXYDerivativeFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageXYDerivativeFilter.h"

@implementation MetalImageXYDerivativeFilter

- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_MetalImageXYDerivativeFilter"]) {
        self.edgeStrength = 1.0;
    }
    return self;
}

@end
