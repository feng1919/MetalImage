//
//  MIMultiplyBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIMultiplyBlendFilter.h"

@implementation MIMultiplyBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_multiplyBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
