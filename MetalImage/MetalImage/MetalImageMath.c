//
//  MetalImageMath.c
//  MetalImage
//
//  Created by Feng Stone on 2020/6/23.
//  Copyright © 2020 fengshi. All rights reserved.
//

#include "MetalImageMath.h"
#include <assert.h>
#include <math.h>


void make_gaussian_distribution(const unsigned int radius, const float sigma, float *buffer)
{
    assert(buffer != NULL);
    assert(sigma > 0.0f);
    
    // generate the normal gaussian weights for a given sigma
    float total_weights = 0.0f;
    float power = 1.0f / sqrt(2.0f * M_PI * pow(sigma, 2.0)); // for reducing the cost of pow calculation
    float std = 2.0 * pow(sigma, 2.0);
    for (int i = 0; i < radius + 1; i++) {
        buffer[i] = power * exp(-pow(i, 2.0) / std);
        
        if (i == 0) {
            total_weights += buffer[i];
        }
        else {
            total_weights += 2.0f * buffer[i];
        }
    }
    
    // normalize the weights
    for (int i = 0; i < radius + 1; i ++) {
        buffer[i] /= total_weights;
    }
}
