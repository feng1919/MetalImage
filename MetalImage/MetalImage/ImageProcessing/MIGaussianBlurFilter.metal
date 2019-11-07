//
//  MIGaussianBlurFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2019/11/7.
//  Copyright © 2019 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

fragment half4 fragment_GaussianVertical(VertexIOWithSteps     inFrag  [[ stage_in ]],
                                         texture2d<half>       tex2D   [[ texture(0) ]],
                                         constant int &radius          [[ buffer(0) ]],
                                         constant float *weights       [[ buffer(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 steps = float2(0.0f, inFrag.texelSteps.y);
//    const float2 steps = float2(0.0f, 1.0f/1920.0f);
    
    half3 sum = half3(0.0h);
    sum += tex2D.sample(quadSampler, inFrag.textureCoordinate).rgb * weights[0];
    for (int i = 1; i < radius; i++) {
        sum += tex2D.sample(quadSampler, inFrag.textureCoordinate - steps * i).rgb * weights[i];
        sum += tex2D.sample(quadSampler, inFrag.textureCoordinate + steps * i).rgb * weights[i];
    }
    
    return half4(sum, 1.0h);
}

fragment half4 fragment_GaussianHorizontal(VertexIOWithSteps     inFrag  [[ stage_in ]],
                                           texture2d<half>       tex2D   [[ texture(0) ]],
                                           constant int &radius          [[ buffer(0) ]],
                                           constant float *weights       [[ buffer(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 steps = float2(inFrag.texelSteps.x, 0.0f);
//    const float2 steps = float2(1.0f/1080.0f, 0.0f);
    
    half3 sum = half3(0.0h);
    sum += tex2D.sample(quadSampler, inFrag.textureCoordinate).rgb * weights[0];
    for (int i = 1; i < radius; i++) {
        sum += tex2D.sample(quadSampler, inFrag.textureCoordinate - steps * i).rgb * weights[i];
        sum += tex2D.sample(quadSampler, inFrag.textureCoordinate + steps * i).rgb * weights[i];
    }
    
    return half4(sum, 1.0h);
}
