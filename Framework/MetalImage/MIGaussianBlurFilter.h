//
//  MIGaussianBlurFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/9/2.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MITwoPassTextureSamplingFilter.h"

NS_ASSUME_NONNULL_BEGIN

/** A Gaussian blur filter
 *  Interpolated optimization based on Daniel Rákos' work at
 *  http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
 *
 *  NOTE: This approaching calculation is separated, for performance,
 *        to two rendering passes by vertical and horizontal calculation.
 *
 */
@interface MIGaussianBlurFilter : MITwoPassTextureSamplingFilter
{
    id<MTLBuffer> _gaussianKernelBuffer;
    id<MTLBuffer> _radiusBuffer;
}

/** A radius in pixels to use for the blur, with a default of 2.0,
 *  The calculation will acting with a gaussian kernel in the size of
 *  2 * radius + 1 .
 *  
 *  This adjusts the sigma variable in the Gaussian distribution function.
 */
@property (readwrite, nonatomic) unsigned int radius;

@end

NS_ASSUME_NONNULL_END
