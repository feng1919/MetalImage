//
//  MetalImageLuminanceRangeFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/8/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_luminanceRange(VertexIO         inFrag  [[ stage_in ]],
                                       texture2d<half>  tex2D   [[ texture(0) ]],
                                       constant float &rangeReduction  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 textureColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham
    const half3 luminanceWeighting = half3(0.2125h, 0.7154h, 0.0721h);
    
    half luminance = dot(textureColor.rgb, luminanceWeighting);
    half luminanceRatio = ((0.5h - luminance) * rangeReduction);
    
    return half4((textureColor.rgb) + (luminanceRatio), textureColor.w);
}


