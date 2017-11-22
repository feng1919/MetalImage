//
//  MetalImageExclusionBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageExclusionBlendFilter.h"

@implementation MetalImageExclusionBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_exclusionBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
