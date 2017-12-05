//
//  MIHardLightBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIHardLightBlendFilter.h"

@implementation MIHardLightBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_hardlightBlend"]))
    {
        return nil;
    }
    
    return self;
}


@end
