//
//  MINormalBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MINormalBlendFilter.h"

@implementation MINormalBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_normalBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
