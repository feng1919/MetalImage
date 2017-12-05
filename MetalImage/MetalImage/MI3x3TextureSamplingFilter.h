//
//  MI3x3TextureSamplingFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/17.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MI3x3TextureSamplingFilter : MetalImageFilter {
    
@protected
    BOOL hasOverriddenImageSizeFactor;
    MTLUInt2 lastImageSize;
}

// The texel width and height determines how far out to sample from this texel.
// By default, this is the normalized width of a pixel, but this can be overridden for different effects.
@property (readwrite, nonatomic) MTLFloat2 texelSize;
@property (nonatomic, strong, readonly) id<MTLBuffer> texelSizeBuffer;

@end
