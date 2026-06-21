//
//  MetalImageFilterGroup.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilterGroup.h"
#import "MetalDevice.h"

@interface MetalImageFilterGroup ()

@property (nonatomic,strong) NSMutableArray<MetalImageOutput<MetalImageInput> *> *filterArray;

@end

@implementation MetalImageFilterGroup

- (instancetype)init {
    if (self = [super init]) {
        self.filterArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - MetalImageInput delegate

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    for (MetalImageOutput<MetalImageInput> *currentFilter in _initialFilters) {
        [currentFilter setInputTexture:newInputTexture atIndex:textureIndex];
    }
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    for (MetalImageOutput<MetalImageInput> *currentFilter in _initialFilters) {
        [currentFilter setInputRotation:newInputRotation atIndex:textureIndex];
    }
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    for (MetalImageOutput<MetalImageInput> *currentFilter in _initialFilters) {
        [currentFilter newTextureReadyAtTime:frameTime atIndex:textureIndex];
    }
}

- (MetalImageRotationMode)rotationForOutput {
    return kMetalImageNoRotation;
}

#pragma mark - chain management


- (void)addFilter:(MetalImageOutput<MetalImageInput> *)filter {
    if (filter) {
        @synchronized(self) {
            [_filterArray addObject:filter];
        }
    }
    else {
        NSAssert(NO, @"filter is nil...");
    }
}

- (void)removeFilter:(MetalImageOutput<MetalImageInput> *)filter {
    if (filter) {
        @synchronized(self) {
            [_filterArray removeObject:filter];
        }
    }
    else {
        NSAssert(NO, @"filter is nil...");
    }
}

- (void)removeAllFilters {
    @synchronized(self) {
        [_filterArray removeAllObjects];
    }
}

- (MetalImageOutput<MetalImageInput> *)filterAtIndex:(NSUInteger)filterIndex {
    if (filterIndex < _filterArray.count) {
        @synchronized(self) {
            return _filterArray[filterIndex];
        }
    }
    else {
        return nil;
    }
}

- (NSUInteger)filterCount {
    @synchronized(self) {
        return _filterArray.count;
    }
}

- (void)addTarget:(id<MetalImageInput>)newTarget {
    [_terminalFilter addTarget:newTarget];
}

- (void)addTarget:(id<MetalImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation {
    [_terminalFilter addTarget:newTarget atTextureLocation:textureLocation];
}

- (void)removeTarget:(id<MetalImageInput>)targetToRemove;
{
    [_terminalFilter removeTarget:targetToRemove];
}

- (void)removeAllTargets;
{
    [_terminalFilter removeAllTargets];
}

- (NSArray *)targets;
{
    return [_terminalFilter targets];
}

@end
