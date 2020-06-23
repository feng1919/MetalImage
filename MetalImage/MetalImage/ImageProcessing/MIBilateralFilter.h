//
//  MIBilateralFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2020/6/23.
//  Copyright © 2020 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"
#import "MITwoPassTextureSamplingFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIBilateralFilter : MITwoPassTextureSamplingFilter
{
    id<MTLBuffer> _gaussianKernelBuffer;
    id<MTLBuffer> _radiusBuffer;
}

/** A radius in pixels to use for the smoothing, with a default of 2.0,
 *  The calculation will acting with a gaussian kernel in the size of
 *  2 * blurRadiusInPixels + 1 .
 *
 *  This adjusts the sigma variable in the Gaussian distribution function.
 */
@property (readwrite, nonatomic) unsigned int radius;

@end

NS_ASSUME_NONNULL_END
