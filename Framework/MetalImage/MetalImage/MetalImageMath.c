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

void make_gaussian_distribution(const unsigned int radius, const float sigma, const bool normalize, float *buffer)
{
    assert(buffer != NULL);
    assert(sigma > 0.0f);
    assert(radius > 0);
    
    // generate the normal gaussian weights for a given sigma
    float total_weights = 0.0f;
    float power = normalize?1.0f/sqrt(2.0f * M_PI * pow(sigma, 2.0)):1.0f; // for reducing the cost of pow calculation
    float std = 2.0 * pow(sigma, 2.0);
    for (int i = 0; i < radius + 1; i++) {
        buffer[i] = power * exp(-(float)(i*i) / std);
        
        if (normalize) {
            if (i == 0) {
                total_weights += buffer[i];
            }
            else {
                total_weights += 2.0f * buffer[i];
            }
        }
    }
    
    // normalize the weights
    if (normalize) {
        for (int i = 0; i < radius + 1; i ++) {
            buffer[i] /= total_weights;
        }
    }
}

void make_gaussian_distribution_2d(const unsigned int radius, const float sigma,  const bool normalize, float *buffer)
{
    assert(buffer != NULL);
    assert(sigma > 0.0f);
    assert(radius > 0);
    
    // generate the normal gaussian weights for a given sigma
    float total_weights = 0.0f;
    float power = normalize?1.0f/sqrt(2.0f * M_PI * pow(sigma, 2.0)):1.0f; // for reducing the cost of pow calculation
    float std = 2.0 * pow(sigma, 2.0);
    int width = 2*radius+1;
    for (int i = 0; i < width; i++) {
        int dx = i - radius;
        for (int j = 0; j < width; j++) {
            int dy = j - radius;
            buffer[i*width+j] = power * exp(-(float)(dx*dx+dy*dy) / std);
            
            if (normalize) {
                total_weights += buffer[i*width+j];
            }
        }
    }
    
    // normalize the weights
    if (normalize) {
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < width; j++) {
                buffer[i*width+j] /= total_weights;
            }
        }
    }
}
