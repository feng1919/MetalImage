//
//  MetalImageDirectionalNonMaximumSuppressionFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

typedef struct {
    float texelWidth;
    float texelHeight;
    float upperThreshold;
    float lowerThreshold;
}DirectionalNonMaximumSuppressionParameters;

fragment half4 fragment_DirectionalNonMaximumSuppressionFilter(VertexIO inFrag[[ stage_in ]],
                                                               texture2d<half> texture2D[[ texture(0) ]],
                                                               constant DirectionalNonMaximumSuppressionParameters &parameters [[buffer(0)]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half3 currentGradientAndDirection = texture2D.sample(qsampler, inFrag.textureCoordinate).rgb;
    float2 gradientDirection = ((float2(currentGradientAndDirection.gb) * 2.0) - 1.0) * float2(parameters.texelWidth, parameters.texelHeight);
    
    half firstSampledGradientMagnitude = texture2D.sample(qsampler, inFrag.textureCoordinate + float2(gradientDirection)).r;
    half secondSampledGradientMagnitude = texture2D.sample(qsampler, inFrag.textureCoordinate - float2(gradientDirection)).r;
    
    float multiplier = step(firstSampledGradientMagnitude, currentGradientAndDirection.r);
    multiplier = multiplier * step(secondSampledGradientMagnitude, currentGradientAndDirection.r);
    
    float thresholdCompliance = smoothstep(parameters.lowerThreshold, parameters.upperThreshold, float(currentGradientAndDirection.r));
    multiplier = multiplier * thresholdCompliance;
    
    return half4(half3(multiplier), 1.0h);
}

