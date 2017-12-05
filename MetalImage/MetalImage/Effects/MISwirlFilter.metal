//
//  MISwirlFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    packed_float2 center;
    float radius;
    float angle;
}SwirlParameters;

fragment half4 fragment_swirlFilter(VertexIO         inFrag  [[ stage_in ]],
                                    texture2d<half>  tex2D   [[ texture(0) ]],
                                    constant SwirlParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 textureCoordinateToUse = inFrag.textureCoordinate;
    float dist = distance(parameters.center, textureCoordinateToUse);
    
    if (dist < parameters.radius)
    {
        textureCoordinateToUse -= parameters.center;
        float percent = (parameters.radius - dist) / parameters.radius;
        float theta = percent * percent * parameters.angle * 8.0;
        float s = sin(theta);
        float c = cos(theta);
        textureCoordinateToUse = float2(dot(textureCoordinateToUse, float2(c, -s)), dot(textureCoordinateToUse, float2(s, c)));
        textureCoordinateToUse += parameters.center;
    }
    
    return tex2D.sample(quadSampler, textureCoordinateToUse);
}
