//
//  MetalImage3x3ConvolutionFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/18.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImage3x3TextureSamplingFilter.h"

/** Runs a 3x3 convolution kernel against the image
 */
@interface MetalImage3x3ConvolutionFilter : MetalImage3x3TextureSamplingFilter

/** Convolution kernel to run against the image
 
 The convolution kernel is a 3x3 matrix of values to apply to the pixel and its 8 surrounding pixels.
 The matrix is specified in row-major order, with the top left pixel being one.one and the bottom right three.three
 If the values in the matrix don't add up to 1.0, the image could be brightened or darkened.
 */
@property(readwrite, nonatomic) MTLFloat3x3 convolutionKernel;

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end
