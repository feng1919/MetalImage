//
//  MetalImageLinearBurnBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageLinearBurnBlendFilter.h"

@implementation MetalImageLinearBurnBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_linearBurnBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
