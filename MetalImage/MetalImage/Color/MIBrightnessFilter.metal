//
//  MIBrightnessFilter.metal
//  MetalImage
//
//  Created by Stone Feng on 2017/8/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_brightness(VertexIO         inFrag   [[ stage_in ]],
                                   texture2d<half>  tex2D   [[ texture(0) ]],
                                   constant float &brightness [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 inColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    return half4((inColor.rgb + half3(brightness)), inColor.a);
}
