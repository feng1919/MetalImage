//
//  MIRGBOpeningFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIRGBOpeningFilter.h"
#import "MIRGBDilationFilter.h"
#import "MIRGBErosionFilter.h"

@implementation MIRGBOpeningFilter

- (instancetype)init {
    return [self initWithRadius:1];
}

- (instancetype)initWithRadius:(MTLUInt)radius {
    
    if (self = [super init]) {
        // First pass: erosion
        erosionFilter = [[MIRGBErosionFilter alloc] initWithRadius:radius];
        [self addFilter:erosionFilter];
        
        // Second pass: dilation
        dilationFilter = [[MIRGBDilationFilter alloc] initWithRadius:radius];
        [self addFilter:dilationFilter];
        
        [erosionFilter addTarget:dilationFilter];
        
        self.initialFilters = [NSArray arrayWithObjects:erosionFilter, nil];
        self.terminalFilter = dilationFilter;
    }
    
    return self;
}

- (void)setVerticalTexelSpacing:(MTLFloat)newValue;
{
    _verticalTexelSpacing = newValue;
    erosionFilter.verticalTexelSpacing = newValue;
    dilationFilter.verticalTexelSpacing = newValue;
}

- (void)setHorizontalTexelSpacing:(MTLFloat)newValue;
{
    _horizontalTexelSpacing = newValue;
    erosionFilter.horizontalTexelSpacing = newValue;
    dilationFilter.horizontalTexelSpacing = newValue;
}

@end
