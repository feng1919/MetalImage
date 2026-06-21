//
//  MIOpacityFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/8/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_opacity(VertexIO         inFrag  [[ stage_in ]],
                                texture2d<half>  tex2D   [[ texture(0) ]],
                                constant float &opacity  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 source = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    return half4(source.rgb, source.a * half(opacity));
}
