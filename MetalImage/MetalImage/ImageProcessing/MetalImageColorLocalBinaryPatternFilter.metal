//
//  MetalImageColorLocalBinaryPatternFilter.metal
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

fragment half4 fragment_ColorLocalBinaryPatternFilter(VertexIONearbyTexelSampling         inFrag  [[ stage_in ]],
                                                      texture2d<float>                   texture2D  [[ texture(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float4 bottomLeftIntensity = texture2D.sample(quadSampler,  inFrag.bottomLeftTextureCoordinate);
    float4 topRightIntensity = texture2D.sample(quadSampler,  inFrag.topRightTextureCoordinate);
    float4 topLeftIntensity = texture2D.sample(quadSampler,  inFrag.topLeftTextureCoordinate);
    float4 bottomRightIntensity = texture2D.sample(quadSampler,  inFrag.bottomRightTextureCoordinate);
    float4 leftIntensity = texture2D.sample(quadSampler,  inFrag.leftTextureCoordinate);
    float4 rightIntensity = texture2D.sample(quadSampler,  inFrag.rightTextureCoordinate);
    float4 bottomIntensity = texture2D.sample(quadSampler,  inFrag.bottomTextureCoordinate);
    float4 topIntensity = texture2D.sample(quadSampler,  inFrag.topTextureCoordinate);
    float4 centerIntensity = texture2D.sample(quadSampler, inFrag.textureCoordinate);
    
    float4 byteTally = 1.0 / 255.0 * step(centerIntensity, topRightIntensity);
    byteTally += 2.0 / 255.0 * step(centerIntensity, topIntensity);
    byteTally += 4.0 / 255.0 * step(centerIntensity, topLeftIntensity);
    byteTally += 8.0 / 255.0 * step(centerIntensity, leftIntensity);
    byteTally += 16.0 / 255.0 * step(centerIntensity, bottomLeftIntensity);
    byteTally += 32.0 / 255.0 * step(centerIntensity, bottomIntensity);
    byteTally += 64.0 / 255.0 * step(centerIntensity, bottomRightIntensity);
    byteTally += 128.0 / 255.0 * step(centerIntensity, rightIntensity);
    
    return half4(half3(byteTally.rgb), 1.0h);
}


