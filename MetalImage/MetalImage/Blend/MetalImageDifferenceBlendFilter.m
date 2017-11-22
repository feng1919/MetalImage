//
//  MetalImageDifferenceBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageDifferenceBlendFilter.h"

@implementation MetalImageDifferenceBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_differenceBlend"]))
    {
        return nil;
    }
    
    return self;
}


@end
