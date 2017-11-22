//
//  MetalImageDarkenBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageDarkenBlendFilter.h"

@implementation MetalImageDarkenBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_darkenBlend"]))
    {
        return nil;
    }
    
    return self;
}


@end
