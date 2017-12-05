//
//  MIDarkenBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIDarkenBlendFilter.h"

@implementation MIDarkenBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_darkenBlend"]))
    {
        return nil;
    }
    
    return self;
}


@end
