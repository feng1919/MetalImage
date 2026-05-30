//
//  MIGlassSphereFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIGlassSphereFilter.h"

@implementation MIGlassSphereFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_GlassSphereFilter"]))
    {
        return nil;
    }
    
    return self;
}


@end
