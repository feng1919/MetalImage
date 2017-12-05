//
//  MIStretchDistortionFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

/** Creates a stretch distortion of the image
 */
@interface MIStretchDistortionFilter : MetalImageFilter

/** The center about which to apply the distortion, with a default of (0.5, 0.5)
 */
@property(readwrite, nonatomic) MTLFloat2 center;

@end
