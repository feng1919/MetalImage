//
//  MISepiaFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/8/23.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MISepiaFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@implementation MISepiaFilter

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    self.intensity = 1.0;
    self.colorMatrix = (MTLFloat4x4){
        {0.3588, 0.7044, 0.1368, 0.0},
        {0.2990, 0.5870, 0.1140, 0.0},
        {0.2392, 0.4696, 0.0912 ,0.0},
        {0,0,0,1.0},
    };
    
    return self;
}

@end
