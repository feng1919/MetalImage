//
//  MICannyEdgeDetectionFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2021/2/20.
//  Copyright © 2021 fengshi. All rights reserved.
//

#import "MICannyEdgeDetectionFilter.h"
#import "MIDirectionalSobelEdgeDetectionFilter.h"
#import "MIWeakPixelInclusionFilter.h"
#import "MIBilateralFilter.h"
#import "MIGrayscaleFilter.h"
#import "MIDirectionalNonMaximumSuppressionFilter.h"

@interface MICannyEdgeDetectionFilter() {
    MIGrayscaleFilter *_grayscale;
    MIBilateralFilter *_bilateral;
    MIDirectionalSobelEdgeDetectionFilter *_edgeDetection;
    MIWeakPixelInclusionFilter *_weakPixelInclusion;
    MIDirectionalNonMaximumSuppressionFilter *_nms;
}

@end

@implementation MICannyEdgeDetectionFilter

- (instancetype)init {
    if (self = [super init]) {
        _grayscale = [[MIGrayscaleFilter alloc] init];
        _bilateral = [[MIBilateralFilter alloc] init];
        _edgeDetection = [[MIDirectionalSobelEdgeDetectionFilter alloc] init];
        _nms = [[MIDirectionalNonMaximumSuppressionFilter alloc] init];
        _weakPixelInclusion = [[MIWeakPixelInclusionFilter alloc] init];
        
        [_bilateral addTarget:_grayscale];
        [_grayscale addTarget:_edgeDetection];
        [_edgeDetection addTarget:_nms];
        [_nms addTarget:_weakPixelInclusion];
        
        self.initialFilters = @[_bilateral];
        self.terminalFilter = _weakPixelInclusion;
        
        self.blurRadiusInPixels = 5.0;
        self.upperThreshold = 0.4;
        self.lowerThreshold = 0.1;
    }
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setBlurRadiusInPixels:(CGFloat)newValue;
{
    _bilateral.radius = newValue;
}

- (CGFloat)blurRadiusInPixels;
{
    return _bilateral.radius;
}

- (void)setTexelWidth:(CGFloat)newValue;
{
    MTLFloat2 texelSize = _edgeDetection.texelSize;
    texelSize.x = newValue;
    _edgeDetection.texelSize = texelSize;
}

- (CGFloat)texelWidth;
{
    return _edgeDetection.texelSize.x;
}

- (void)setTexelHeight:(CGFloat)newValue;
{
    MTLFloat2 texelSize = _edgeDetection.texelSize;
    texelSize.y = newValue;
    _edgeDetection.texelSize = texelSize;
}

- (CGFloat)texelHeight;
{
    return _edgeDetection.texelSize.y;
}

- (void)setUpperThreshold:(CGFloat)newValue;
{
    _nms.upperThreshold = newValue;
}

- (CGFloat)upperThreshold;
{
    return _nms.upperThreshold;
}

- (void)setLowerThreshold:(CGFloat)newValue;
{
    _nms.lowerThreshold = newValue;
}

- (CGFloat)lowerThreshold;
{
    return _nms.lowerThreshold;
}

@end
