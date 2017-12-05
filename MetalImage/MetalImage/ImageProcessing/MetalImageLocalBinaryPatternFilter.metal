//
//  MetalImageLocalBinaryPatternFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/12/5.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

// This is based on "Accelerating image recognition on mobile devices using GPGPU" by Miguel Bordallo Lopez, Henri Nykanen, Jari Hannuksela, Olli Silven and Markku Vehvilainen
// http://www.ee.oulu.fi/~jhannuks/publications/SPIE2011a.pdf

// Right pixel is the most significant bit, traveling clockwise to get to the upper right, which is the least significant
// If the external pixel is greater than or equal to the center, set to 1, otherwise 0
//
// 2 1 0
// 3   7
// 4 5 6

// 01101101
// 76543210

fragment half4 fragment_LocalBinaryPatternFilter(VertexIONearbyTexelSampling         inFrag  [[ stage_in ]],
                                                 texture2d<half>                   texture2D  [[ texture(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half bottomLeftIntensity = texture2D.sample(quadSampler,  inFrag.bottomLeftTextureCoordinate).r;
    half topRightIntensity = texture2D.sample(quadSampler,  inFrag.topRightTextureCoordinate).r;
    half topLeftIntensity = texture2D.sample(quadSampler,  inFrag.topLeftTextureCoordinate).r;
    half bottomRightIntensity = texture2D.sample(quadSampler,  inFrag.bottomRightTextureCoordinate).r;
    half leftIntensity = texture2D.sample(quadSampler,  inFrag.leftTextureCoordinate).r;
    half rightIntensity = texture2D.sample(quadSampler,  inFrag.rightTextureCoordinate).r;
    half bottomIntensity = texture2D.sample(quadSampler,  inFrag.bottomTextureCoordinate).r;
    half topIntensity = texture2D.sample(quadSampler,  inFrag.topTextureCoordinate).r;
    half centerIntensity = texture2D.sample(quadSampler, inFrag.textureCoordinate).r;
    
    const half4 weight = half4(1.0h/255.0h, 2.0h/255.0h, 4.0h/255.0h, 8.0h/255.0h);
    half4 vstep = half4(centerIntensity);
    half4 v1 = half4(topRightIntensity, topIntensity, topLeftIntensity, leftIntensity);
    half4 v2 = half4(bottomLeftIntensity, bottomIntensity, bottomRightIntensity, rightIntensity);
    
    float byteTally = dot(weight, step(vstep, v1));
    byteTally += dot(weight, step(vstep, v2)) * 16.0h;
    
    return half4(half3(byteTally), 1.0h);
}


