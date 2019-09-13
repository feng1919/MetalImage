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
 Interpolated optimization based on Daniel Rákos' work at http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
 */
@interface MIGaussianBlurFilter : MITwoPassTextureSamplingFilter
{
    BOOL shouldResizeBlurRadiusWithImageSize;
    CGFloat _blurRadiusInPixels;
    
    id<MTLBuffer> _gaussianKernelBuffer;
}

/** A multiplier for the spacing between texels, ranging from 0.0 on up, with a default of 1.0. Adjusting this may slightly increase the blur strength, but will introduce artifacts in the result.
 */
@property (readwrite, nonatomic) CGFloat texelSpacingMultiplier;

/** A radius in pixels to use for the blur, with a default of 2.0. This adjusts the sigma variable in the Gaussian distribution function.
 */
@property (readwrite, nonatomic) CGFloat blurRadiusInPixels;

/** Setting these properties will allow the blur radius to scale with the size of the image. These properties are mutually exclusive; setting either will set the other to 0.
 */
@property (readwrite, nonatomic) CGFloat blurRadiusAsFractionOfImageWidth;
@property (readwrite, nonatomic) CGFloat blurRadiusAsFractionOfImageHeight;

/// The number of times to sequentially blur the incoming image. The more passes, the slower the filter.
@property (readwrite, nonatomic) NSUInteger blurPasses;

+ (NSArray<NSNumber *> *)gaussianWeightsBufferForStandardBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;

- (void)switchToVertexShader:(NSString *)newVertexShader fragmentShader:(NSString *)newFragmentShader;

@end

NS_ASSUME_NONNULL_END
