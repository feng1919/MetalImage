//
//  MILuminosityBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MILuminosityBlendFilter.h"

@implementation MILuminosityBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_luminosityBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
