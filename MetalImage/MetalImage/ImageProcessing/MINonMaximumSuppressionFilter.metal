//
//  MINonMaximumSuppressionFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

fragment half4 fragment_NonMaximumSuppressionFilter(VertexIONearbyTexelSampling         inFrag  [[ stage_in ]],
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
    half4 centerColor = texture2D.sample(quadSampler, inFrag.textureCoordinate);
    
    // Use a tiebreaker for pixels to the left and immediately above this one
    half multiplier = 1.0h - step(centerColor.r, topIntensity);
    multiplier = multiplier * (1.0h - step(centerColor.r, topLeftIntensity));
    multiplier = multiplier * (1.0h - step(centerColor.r, leftIntensity));
    multiplier = multiplier * (1.0h - step(centerColor.r, bottomLeftIntensity));
    
    half maxValue = max(centerColor.r, bottomIntensity);
    maxValue = max(maxValue, bottomRightIntensity);
    maxValue = max(maxValue, rightIntensity);
    maxValue = max(maxValue, topRightIntensity);
    
    return half4((centerColor.rgb * step(maxValue, centerColor.r) * multiplier), 1.0h);
}


