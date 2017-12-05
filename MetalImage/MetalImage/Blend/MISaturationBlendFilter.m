//
//  MISaturationBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MISaturationBlendFilter.h"

@implementation MISaturationBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_saturationBlend"]))
    {
        return nil;
    }
    
    return self;
}


@end
