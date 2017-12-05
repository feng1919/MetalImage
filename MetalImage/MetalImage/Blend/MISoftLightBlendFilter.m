//
//  MISoftLightBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MISoftLightBlendFilter.h"

@implementation MISoftLightBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_softlightBlend"]))
    {
        return nil;
    }
    
    return self;
}


@end
