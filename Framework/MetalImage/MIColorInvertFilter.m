//
//  MIColorInvertFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/8/25.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIColorInvertFilter.h"

@implementation MIColorInvertFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_colorInvert"]))
    {
        return nil;
    }
    
    return self;
}

@end
