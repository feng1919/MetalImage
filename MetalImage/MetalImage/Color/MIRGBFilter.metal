//
//  MIRGBFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/8/15.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_rgbAdjustment(VertexIO         inFrag   [[ stage_in ]],
                                      texture2d<half>  tex2D   [[ texture(0) ]],
                                      constant packed_float3 &rgb [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 inColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    return half4(inColor.x * half(rgb[0]), inColor.y * half(rgb[1]), inColor.z * half(rgb[2]), inColor.a);
}


