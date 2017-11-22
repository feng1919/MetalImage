//
//  MetalImageScreenBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageScreenBlendFilter.h"

@implementation MetalImageScreenBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_screenBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
