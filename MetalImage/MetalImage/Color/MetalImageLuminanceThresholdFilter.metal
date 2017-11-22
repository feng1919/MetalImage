//
//  MetalImageLuminanceThresholdFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/9/27.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_luminanceThreshold(VertexIO         inFrag  [[ stage_in ]],
                                           texture2d<float>  tex2D   [[ texture(0) ]],
                                           constant float &threshold   [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float4 textureColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    const float3 W = float3(0.2125, 0.7154, 0.0721);
    
    float luminance = dot(textureColor.rgb, W);
    float thresholdResult = step(threshold, luminance);
    
    return half4(half3(thresholdResult), half(textureColor.a));
}
