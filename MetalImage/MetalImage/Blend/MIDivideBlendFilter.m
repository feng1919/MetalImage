//
//  MIDivideBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIDivideBlendFilter.h"

@implementation MIDivideBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_divideBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
