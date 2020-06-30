//
//  MIMaskBilateralFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2020/6/30.
//  Copyright © 2020 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

fragment half4 fragment_MaskBilateralFilter(VertexIOWithSteps    inFrag  [[ stage_in ]],
                                            texture2d<half>     tex2D   [[ texture(0) ]],
                                            texture2d<half>     mask    [[ texture(1) ]],
                                            constant int       &radius  [[ buffer(0) ]],
                                            constant float     *weights [[ buffer(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half3 center = tex2D.sample(quadSampler, inFrag.textureCoordinate).rgb;
    
    half alpha = mask.sample(quadSampler, inFrag.textureCoordinate).r;
    if (alpha < 0.5h) {
        return half4(center, 1.0h);
    }
    
    const half power = 2.0h*half(radius-1)*half(radius-1);
    
    half3 acc_color = half3(0.0h);
    half3 acc_weight = half3(0.0h);
    const int width = 2 * radius + 1;
    for (int i = 0; i < width; i++) {
        float2 textCoordinate = inFrag.texelSteps;
        textCoordinate.y *= float(i-radius);
        for (int j = 0; j < width; j++) {
            textCoordinate.x = inFrag.texelSteps.x * float(j-radius);
            half3 color = tex2D.sample(quadSampler, textCoordinate).rgb;
            half3 delta = color - center;
            delta *= 255.0h;
            delta = delta * delta / power;
            delta = exp(-delta);
            delta *= weights[i*width+j];
            acc_color += delta * color;
            acc_weight += delta;
        }
    }
    
    
    return half4(acc_color / acc_weight, 1.0h);
}

