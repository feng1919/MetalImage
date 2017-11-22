//
//  MetalImageColorBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageColorBlendFilter.h"

@implementation MetalImageColorBlendFilter


- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_colorBlend"]))
    {
        return nil;
    }
    
    return self;
}


@end
