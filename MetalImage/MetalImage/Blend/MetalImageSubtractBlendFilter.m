//
//  MetalImageSubtractBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageSubtractBlendFilter.h"

@implementation MetalImageSubtractBlendFilter


- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_subtractBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
