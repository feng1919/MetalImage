//
//  MetalImageContrastFilter.metal
//  MetalImage
//
//  Created by Stone Feng on 2017/8/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_contrast(VertexIO         inFrag   [[ stage_in ]],
                                 texture2d<half>  tex2D   [[ texture(0) ]],
                                 constant float &contrast [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 inColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    return half4((inColor.rgb - half3(0.5h))* contrast + half3(0.5h), inColor.a);
}

kernel void kernal_contrast(texture2d<float, access::read> inTexture [[texture(0)]],
                            texture2d<float, access::write> outTexture [[texture(1)]],
                            constant float &contrast [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    const float4 outColor = float4((inColor.rgb - float3(0.5f))* contrast + float3(0.5f), inColor.a);
    outTexture.write(outColor, gid);
}

