//
//  MIVignetteFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    packed_float2 vignetteCenter;
    packed_float3 vignetteColor;
    float vignetteStart;
    float vignetteEnd;
}VignetteParameters;

fragment half4 fragment_VignetteFilter(VertexIO         inFrag  [[ stage_in ]],
                                       texture2d<half>  tex2D   [[ texture(0) ]],
                                       constant VignetteParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 sourceImageColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    half d = distance(inFrag.textureCoordinate, float2(parameters.vignetteCenter));
    half percent = smoothstep(half(parameters.vignetteStart), half(parameters.vignetteEnd), d);
    return half4(mix(sourceImageColor.rgb, half3(parameters.vignetteColor), percent), sourceImageColor.a);
}
