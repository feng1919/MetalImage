//
//  MetalImageColorInvertFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/8/25.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageColorInvertFilter.h"

@implementation MetalImageColorInvertFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_colorInvert"]))
    {
        return nil;
    }
    
    return self;
}

@end
