//
//  MetalImageCGAColorspaceFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageCGAColorspaceFilter.h"

@implementation MetalImageCGAColorspaceFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_cgaColorspace"]))
    {
        return nil;
    }
    
    return self;
}

@end
