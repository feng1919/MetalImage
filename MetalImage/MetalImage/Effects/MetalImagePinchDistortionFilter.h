//
//  MetalImagePinchDistortionFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

/** Creates a pinch distortion of the image
 */
@interface MetalImagePinchDistortionFilter : MetalImageFilter

/** The center about which to apply the distortion, with a default of (0.5, 0.5)
 */
@property(readwrite, nonatomic) MTLFloat2 center;
/** The radius of the distortion, ranging from 0.0 to 2.0, with a default of 1.0
 */
@property(readwrite, nonatomic) MTLFloat radius;
/** The amount of distortion to apply, from -2.0 to 2.0, with a default of 0.5
 */
@property(readwrite, nonatomic) MTLFloat scale;

@end
