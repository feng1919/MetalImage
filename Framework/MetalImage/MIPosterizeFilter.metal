//
//  MIPosterizeFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_posterize(VertexIO         inFrag  [[ stage_in ]],
                                  texture2d<half>  tex2D   [[ texture(0) ]],
                                  constant float &colorLevels  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 textureColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    return floor((textureColor * colorLevels) + half4(0.5)) / colorLevels;;
}

