//
//  MIHighPassFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/12/5.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIHighPassFilter.h"

@implementation MIHighPassFilter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    // Start with a low pass filter to define the component to be removed
    lowPassFilter = [[MILowPassFilter alloc] init];
    [self addFilter:lowPassFilter];
    
    // Take the difference of the current frame from the low pass filtered result to get the high pass
    differenceBlendFilter = [[MIDifferenceBlendFilter alloc] init];
    [self addFilter:differenceBlendFilter];
    
    // Texture location 0 needs to be the original image for the difference blend
    [lowPassFilter addTarget:differenceBlendFilter atTextureLocation:1];
    
    self.initialFilters = [NSArray arrayWithObjects:lowPassFilter, differenceBlendFilter, nil];
    self.terminalFilter = differenceBlendFilter;
    
    self.filterStrength = 0.5;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setFilterStrength:(MTLFloat)newValue;
{
    lowPassFilter.filterStrength = newValue;
}

- (MTLFloat)filterStrength;
{
    return lowPassFilter.filterStrength;
}

@end
