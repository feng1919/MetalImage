//
//  MIHueBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIHueBlendFilter.h"

@implementation MIHueBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_hueBlend"]))
    {
        return nil;
    }
    
    return self;
}



@end
