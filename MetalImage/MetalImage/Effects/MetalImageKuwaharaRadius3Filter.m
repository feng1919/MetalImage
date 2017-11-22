//
//  MetalImageKuwaharaRadius3Filter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageKuwaharaRadius3Filter.h"

@implementation MetalImageKuwaharaRadius3Filter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_KuwaharaRadius3Filter"]))
    {
        return nil;
    }

    return self;
}

@end
