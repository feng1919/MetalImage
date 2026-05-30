//
//  MISurfaceBlurFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2020/6/23.
//  Copyright © 2020 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

fragment half4 fragment_BilateralFilter(VertexIOWithSteps    inFrag  [[ stage_in ]],
                                         texture2d<half>     tex2D   [[ texture(0) ]],
                                         constant int       &radius  [[ buffer(0) ]],
                                         constant float     *weights [[ buffer(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    const half power = 2.0h*half(radius-1)*half(radius-1);
    
    half3 center = tex2D.sample(quadSampler, inFrag.textureCoordinate).rgb;
    
    half3 acc_color = half3(0.0h);
    acc_color += center;
    
    half3 acc_weight = half3(1.0h);
    
    for (int i = 1; i < radius; i++) {
        half3 color = tex2D.sample(quadSampler, inFrag.textureCoordinate - inFrag.texelSteps * i).rgb;
        half3 delta = color - center;
        delta *= 255.0f;
        delta = delta * delta / power;
        delta = exp(-delta);
        delta *= weights[i];
        acc_color += delta * color;
        acc_weight += delta;
    }
    
    for (int i = 1; i < radius; i++) {
        half3 color = tex2D.sample(quadSampler, inFrag.textureCoordinate + inFrag.texelSteps * i).rgb;
        half3 delta = color - center;
        delta *= 255.0f;
        delta = delta * delta / power;
        delta = exp(-delta);
        delta *= weights[i];
        acc_color += delta * color;
        acc_weight += delta;
    }
    
    return half4(acc_color / acc_weight, 1.0h);
}



