//
//  MetalImageColorInvertFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/8/25.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_colorInvert(VertexIO         inFrag  [[ stage_in ]],
                             texture2d<half>  tex2D   [[ texture(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 c = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    return half4(half3(1.0h)-c.rgb, c.a);
}
