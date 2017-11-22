//
//  MetalImageHueBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageHueBlendFilter.h"

@implementation MetalImageHueBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_hueBlend"]))
    {
        return nil;
    }
    
    return self;
}



@end
