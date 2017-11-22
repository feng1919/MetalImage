//
//  MetalImageGrayscaleFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/9/27.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_luminance(VertexIO         inFrag  [[ stage_in ]],
                                  texture2d<float>  tex2D   [[ texture(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float4 textureColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    const float3 W = float3(0.2125h, 0.7154h, 0.0721h);
    
    float luminance = dot(textureColor.rgb, W);
    
    return half4(half3(luminance), half(textureColor.a));
}
