//
//  MISobelEdgeDetectionFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoPassFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MISobelEdgeDetectionFilter : MetalImageTwoPassFilter {
    
@protected
    BOOL hasOverriddenImageSizeFactor;
    MTLUInt2 lastImageSize;
}

@property (nonatomic, strong) id<MTLBuffer> vertexSlotBuffer;
@property (nonatomic, strong) id<MTLBuffer> fragmentSlotBuffer;

// The texel width and height factors tweak the appearance of the edges.
// By default, they match the inverse of the filter size in pixels.
@property (nonatomic, assign) MTLFloat2 texelSize;

// The filter strength property affects the dynamic range of the filter.
// High values can make edges more visible, but can lead to saturation.
// Default of 1.0.
@property (readwrite, nonatomic) MTLFloat edgeStrength;

@end

NS_ASSUME_NONNULL_END
