//
//  MetalImageGrayscaleFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/9/27.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageGrayscaleFilter.h"

@implementation MetalImageGrayscaleFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_luminance"]))
    {
        return nil;
    }
    
    return self;
}

@end
