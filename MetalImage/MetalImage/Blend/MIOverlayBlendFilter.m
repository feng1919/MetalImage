//
//  MIOverlayBlendFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIOverlayBlendFilter.h"

@implementation MIOverlayBlendFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_overlayBlend"]))
    {
        return nil;
    }
    
    return self;
}

@end
