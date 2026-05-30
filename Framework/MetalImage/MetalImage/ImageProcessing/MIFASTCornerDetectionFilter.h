//
//  MIFASTCornerDetectionFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilterGroup.h"
#import "MIGrayscaleFilter.h"
#import "MI3x3TextureSamplingFilter.h"
#import "MINonMaximumSuppressionFilter.h"

NS_ASSUME_NONNULL_BEGIN
/*
 An implementation of the Features from Accelerated Segment Test (FAST) feature detector as described in the following publications:
 
 E. Rosten and T. Drummond. Fusing points and lines for high performance tracking. IEEE International Conference on Computer Vision, 2005.
 E. Rosten and T. Drummond. Machine learning for high-speed corner detection.  European Conference on Computer Vision, 2006.
 
 For more about the FAST feature detector, see the resources here:
 http://www.edwardrosten.com/work/fast.html
 */

@interface MIFASTCornerDetectionFilter : MetalImageFilterGroup {
    MIGrayscaleFilter *luminanceReductionFilter;
    MI3x3TextureSamplingFilter *featureDetectionFilter;
    MINonMaximumSuppressionFilter *nonMaximumSuppressionFilter;
    // Generate a lookup texture based on the bit patterns
    
    // Step 1: convert to monochrome if necessary
    // Step 2: do a lookup at each pixel based on the Bresenham circle, encode comparison in two color components
    // Step 3: do non-maximum suppression of close corner points
}

@end

NS_ASSUME_NONNULL_END
