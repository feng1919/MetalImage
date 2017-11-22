//
//  MetalImageThresholdEdgeDetectionFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageSobelEdgeDetectionFilter.h"

@interface MetalImageThresholdEdgeDetectionFilter : MetalImageSobelEdgeDetectionFilter

/** Any edge above this threshold will be black, and anything below white.
 *  Ranges from 0.0 to 1.0, with 0.8 as the default
 */
@property(readwrite, nonatomic) MTLFloat threshold;

@end
