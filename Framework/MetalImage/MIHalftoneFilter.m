//
//  MIHalftoneFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIHalftoneFilter.h"
#import "MetalDevice.h"

@implementation MIHalftoneFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_HalftoneFilter"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    self.buffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.fractionalWidthOfAPixel = 0.01;
    
    return self;
}

@end
