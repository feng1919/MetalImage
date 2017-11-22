//
//  MetalImageFilterGroup.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageOutput.h"
#import "MetalImageFilter.h"

@interface MetalImageFilterGroup : MetalImageOutput<MetalImageInput>

@property (nonatomic, strong) MetalImageOutput<MetalImageInput> *terminalFilter;
@property (nonatomic, strong) NSArray<MetalImageOutput<MetalImageInput> *> *initialFilters;
@property (nonatomic, assign) MTLClearColor bgClearColor;

- (void)addFilter:(MetalImageFilter *)filter;
- (void)removeFilter:(MetalImageFilter *)filter;
- (void)removeAllFilters;
- (MetalImageOutput<MetalImageInput> *)filterAtIndex:(NSUInteger)filterIndex;
- (NSUInteger)filterCount;

@end
