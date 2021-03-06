//
//  MetalImageMath.h
//  MetalImage
//
//  Created by Feng Stone on 2020/6/23.
//  Copyright © 2020 fengshi. All rights reserved.
//

#ifndef MetalImageMath_h
#define MetalImageMath_h

#include <stdio.h>
#include <stdbool.h>

void make_gaussian_distribution(const unsigned int radius, const float sigma,  const bool normalize, float *buffer);
void make_gaussian_distribution_2d(const unsigned int radius, const float sigma,  const bool normalize, float *buffer);

#endif /* MetalImageMath_h */
