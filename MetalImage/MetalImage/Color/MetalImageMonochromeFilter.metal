//
//  MetalImageMonochromeFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/7/22.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_monochrome(VertexIO         inFrag  [[ stage_in ]],
                                   texture2d<half>  tex2D   [[ texture(0) ]],
                                   constant float4 &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    const half3 luminanceWeighting = half3(0.2125h, 0.7154h, 0.0721h);

    //desat, then apply overlay blend
    half4 textureColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    half luminance = dot(textureColor.rgb, luminanceWeighting);
    
    half4 desat = half4(half3(luminance), 1.0h);
        
    //overlay
    half4 outputColor = half4((desat.r < 0.5h ? (2.0h * desat.r * half(parameters[0])) :
                               (1.0h - 2.0h * (1.0h - desat.r) * (1.0h - half(parameters[0])))),
                              (desat.g < 0.5h ? (2.0h * desat.g * half(parameters[1])) :
                               (1.0h - 2.0h * (1.0h - desat.g) * (1.0h - half(parameters[1])))),
                              (desat.b < 0.5h ? (2.0h * desat.b * half(parameters[2])) :
                               (1.0h - 2.0h * (1.0h - desat.b) * (1.0h - half(parameters[2])))),
                              1.0h
                              );
    
    return half4(mix(textureColor.rgb, outputColor.rgb, half(parameters[3])), textureColor.a);
}
