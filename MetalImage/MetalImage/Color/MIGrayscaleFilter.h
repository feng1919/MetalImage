//
//  MIGrayscaleFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/9/27.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

/** Converts an image to grayscale (a slightly faster implementation of the saturation filter,
 *  without the ability to vary the color contribution)
 */
@interface MIGrayscaleFilter : MetalImageFilter

@end
