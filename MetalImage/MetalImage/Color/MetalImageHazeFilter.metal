//
//  MetalImageHazeFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/8/23.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    float hazeDistance;
    float slope;
}HazeParameters;

fragment half4 fragment_haze(VertexIO         inFrag  [[ stage_in ]],
                             texture2d<half>  tex2D   [[ texture(0) ]],
                             constant HazeParameters &hazeParameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 color = half4(1.0);
    float  d = inFrag.textureCoordinate.y * hazeParameters.slope  +  hazeParameters.hazeDistance;
    half4 c = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    c = (c - d * color) / (1.0h - half4(d));
    
    return half4(c);
}
