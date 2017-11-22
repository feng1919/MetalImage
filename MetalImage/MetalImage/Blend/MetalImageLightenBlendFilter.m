//
//  MetalImageLightenBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageLightenBlendFilter.h"

@implementation MetalImageLightenBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_lightenBlend"]))
    {
        return nil;
    }
    
    return self;
}



@end
