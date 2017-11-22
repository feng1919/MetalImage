//
//  MetalImageTwoPassTextureSamplingFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/9/2.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoPassFilter.h"

@interface MetalImageTwoPassTextureSamplingFilter : MetalImageTwoPassFilter {
    
@protected
    id<MTLBuffer> verticalBuffer;
    id<MTLBuffer> horizontalBuffer;
    MTLUInt2 lastImageSize;
}

// This sets the spacing between texels (in pixels) when sampling for the first. By default, this is 1.0
@property (nonatomic, assign) MTLFloat verticalTexelSpacing;
@property (nonatomic, assign) MTLFloat horizontalTexelSpacing;

@end
