//
//  MILightenBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MILightenBlendFilter.h"

@implementation MILightenBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_lightenBlend"]))
    {
        return nil;
    }
    
    return self;
}



@end
