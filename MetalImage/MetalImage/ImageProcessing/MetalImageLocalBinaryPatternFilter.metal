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
                                                 texture2d<float>                   texture2D  [[ texture(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float bottomLeftIntensity = texture2D.sample(quadSampler,  inFrag.bottomLeftTextureCoordinate).r;
    float topRightIntensity = texture2D.sample(quadSampler,  inFrag.topRightTextureCoordinate).r;
    float topLeftIntensity = texture2D.sample(quadSampler,  inFrag.topLeftTextureCoordinate).r;
    float bottomRightIntensity = texture2D.sample(quadSampler,  inFrag.bottomRightTextureCoordinate).r;
    float leftIntensity = texture2D.sample(quadSampler,  inFrag.leftTextureCoordinate).r;
    float rightIntensity = texture2D.sample(quadSampler,  inFrag.rightTextureCoordinate).r;
    float bottomIntensity = texture2D.sample(quadSampler,  inFrag.bottomTextureCoordinate).r;
    float topIntensity = texture2D.sample(quadSampler,  inFrag.topTextureCoordinate).r;
    float centerIntensity = texture2D.sample(quadSampler, inFrag.textureCoordinate).r;
    
    const float4 weight = float4(1.0/255.0, 2.0/255.0, 4.0/255.0, 8.0/255.0);
    float4 vstep = float4(centerIntensity);
    float4 v1 = float4(topRightIntensity, topIntensity, topLeftIntensity, leftIntensity);
    float4 v2 = float4(bottomLeftIntensity, bottomIntensity, bottomRightIntensity, rightIntensity);
    
    float byteTally = dot(weight, step(vstep, v1));
    byteTally += dot(weight, step(vstep, v2)) * 16.0;
    
    return half4(half3(byteTally), 1.0h);
}


