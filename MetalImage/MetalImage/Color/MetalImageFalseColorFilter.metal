//
//  MetalImageFalseColorFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/7/23.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    packed_float3 firstColor;
    packed_float3 secondColor;
}TwoColors;

fragment half4 fragment_falseColor(VertexIO         inFrag  [[ stage_in ]],
                                   texture2d<half>  tex2D   [[ texture(0) ]],
                                   constant TwoColors &twoColors  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    const half3 luminanceWeighting = half3(0.2125h, 0.7154h, 0.0721h);
    
    half4 textureColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    half luminance = dot(textureColor.rgb, luminanceWeighting);
    
    half3 firstColor = half3(twoColors.firstColor);
    half3 secondColor = half3(twoColors.secondColor);
    return half4(mix(firstColor.rgb, secondColor.rgb, luminance), textureColor.a);
}

