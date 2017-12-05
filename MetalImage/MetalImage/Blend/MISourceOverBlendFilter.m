//
//  MISourceOverBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MISourceOverBlendFilter.h"

@implementation MISourceOverBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_sourceOverBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
