//
//  MICannyEdgeDetectionFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2021/2/20.
//  Copyright © 2021 fengshi. All rights reserved.
//

#import "MetalImageFilterGroup.h"

NS_ASSUME_NONNULL_BEGIN

/** This applies the edge detection process described by John Canny in
 
 Canny, J., A Computational Approach To Edge Detection, IEEE Trans. Pattern Analysis and Machine Intelligence, 8(6):679–698, 1986.
 
 and implemented in OpenGL ES by

 A. Ensor, S. Hall. GPU-based Image Analysis on Mobile Devices. Proceedings of Image and Vision Computing New Zealand 2011.

 It starts with a conversion to luminance, followed by an accelerated 9-hit Gaussian blur. A Sobel operator is applied to obtain the overall
 gradient strength in the blurred image, as well as the direction (in texture sampling steps) of the gradient. A non-maximum suppression filter
 acts along the direction of the gradient, highlighting strong edges that pass the threshold and completely removing those that fail the lower
 threshold. Finally, pixels from in-between these thresholds are either included in edges or rejected based on neighboring pixels.
 */

@interface MICannyEdgeDetectionFilter : MetalImageFilterGroup

/** The image width and height factors tweak the appearance of the edges.
 
 These parameters affect the visibility of the detected edges
 
 By default, they match the inverse of the filter size in pixels
 */
@property(readwrite, nonatomic) CGFloat texelWidth;
/** The image width and height factors tweak the appearance of the edges.
 
 These parameters affect the visibility of the detected edges
 
 By default, they match the inverse of the filter size in pixels
 */
@property(readwrite, nonatomic) CGFloat texelHeight;

/** The underlying blur radius for the Gaussian blur. Default is 2.0.
 */
@property (readwrite, nonatomic) CGFloat blurRadiusInPixels;


/** Any edge with a gradient magnitude above this threshold will pass and show up in the final result.
 */
@property(readwrite, nonatomic) CGFloat upperThreshold;

/** Any edge with a gradient magnitude below this threshold will fail and be removed from the final result.
 */
@property(readwrite, nonatomic) CGFloat lowerThreshold;

@end

NS_ASSUME_NONNULL_END
