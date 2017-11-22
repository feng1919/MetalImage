//
//  MetalImageSaturationFilter.metal
//  MetalImage
//
//  Created by Stone Feng on 2017/8/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_saturation(VertexIO         inFrag   [[ stage_in ]],
                                   texture2d<half>  tex2D   [[ texture(0) ]],
                                   constant float &saturation [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 inColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham
    const half3 luminanceWeighting = half3(0.2125h, 0.7154h, 0.0721h);
    half luminance = dot(inColor.rgb, luminanceWeighting);
    half3 greyScaleColor = half3(luminance);
    return half4(mix(greyScaleColor, inColor.rgb, (half)saturation), inColor.a);
}

