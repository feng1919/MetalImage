//
//  MIAddBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIAddBlendFilter.h"

@implementation MIAddBlendFilter


- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_addBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
