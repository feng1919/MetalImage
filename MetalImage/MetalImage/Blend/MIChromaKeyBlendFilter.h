//
//  MIChromaKeyBlendFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoInputFilter.h"

@interface MIChromaKeyBlendFilter : MetalImageTwoInputFilter

/** The threshold sensitivity controls how similar pixels need to be colored to be replaced
 
 The default value is 0.3
 */
@property(readwrite, nonatomic) MTLFloat thresholdSensitivity;

/** The degree of smoothing controls how gradually similar colors are replaced in the image
 
 The default value is 0.1
 */
@property(readwrite, nonatomic) MTLFloat smoothing;

/** The color to be replaced is specified using individual red, green, and blue components (normalized to 1.0).
 
 The default is green: (0.0, 1.0, 0.0).
 
 colorToReplace RGB components of color to be replaced
 */
@property (nonatomic, assign) MTLFloat3 colorToReplace;


@end
