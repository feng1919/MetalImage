//
//  MetalImageColorMatrixFilter.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

/** Transforms the colors of an image by applying a matrix to them
 */
#import "MetalImageFilter.h"

@interface MetalImageColorMatrixFilter : MetalImageFilter

/** A 4x4 matrix used to transform each color in an image
 */
@property(readwrite, nonatomic) MTLFloat4x4 colorMatrix;

/** The degree to which the new transformed color replaces the original color for each pixel
 */
@property(readwrite, nonatomic) MTLFloat intensity;


@property(nonatomic, strong) id<MTLBuffer> buffer;


- (void)updateBufferContents;

@end
