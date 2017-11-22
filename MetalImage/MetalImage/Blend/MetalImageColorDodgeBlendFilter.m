//
//  MetalImageColorDodgeBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageColorDodgeBlendFilter.h"

@implementation MetalImageColorDodgeBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_colorDodgeBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
