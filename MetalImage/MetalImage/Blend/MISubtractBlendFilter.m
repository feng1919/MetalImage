//
//  MISubtractBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MISubtractBlendFilter.h"

@implementation MISubtractBlendFilter


- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_subtractBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
