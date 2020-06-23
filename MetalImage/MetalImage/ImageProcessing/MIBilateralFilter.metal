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
    
    half3 sum = half3(0.0h);
    sum += tex2D.sample(quadSampler, inFrag.textureCoordinate).rgb * weights[0];
    for (int i = 1; i < radius; i++) {
        sum += tex2D.sample(quadSampler, inFrag.textureCoordinate - inFrag.texelSteps * i).rgb * weights[i];
        sum += tex2D.sample(quadSampler, inFrag.textureCoordinate + inFrag.texelSteps * i).rgb * weights[i];
    }
    
    return half4(sum, 1.0h);
}
