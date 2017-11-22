//
//  MetalImagePolkaDotFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImagePolkaDotFilter.h"
#import "MetalDevice.h"

@implementation MetalImagePolkaDotFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_PolkaDotFilter"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    self.buffer = [device newBufferWithLength:sizeof(MTLFloat)*3 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.fractionalWidthOfAPixel = 0.05;
    self.dotScaling = 0.90;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setDotScaling:(MTLFloat)newValue;
{
    _dotScaling = newValue;
    
    MTLFloat *bufferContents = (MTLFloat *)[self.buffer contents];
    bufferContents[2] = _dotScaling;
}

@end
