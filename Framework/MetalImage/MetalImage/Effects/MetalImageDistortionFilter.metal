//
//  MIBulgeDistortionFilter.metal
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
    float scale;
    float aspectRatio;
}DistortionParameters;

fragment half4 fragment_BulgeDistortionFilter(VertexIO         inFrag  [[ stage_in ]],
                                              texture2d<half>  tex2D   [[ texture(0) ]],
                                              constant DistortionParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 center = parameters.center;
    float2 textureCoordinate = inFrag.textureCoordinate;
    float2 textureCoordinateToUse = float2(textureCoordinate.x, ((textureCoordinate.y - center.y) * parameters.aspectRatio) + center.y);
    float dist = distance((float2)parameters.center, textureCoordinateToUse);
    
    textureCoordinateToUse = textureCoordinate;
    
    if (dist < parameters.radius)
    {
        textureCoordinateToUse -= center;
        float percent = 1.0 - ((parameters.radius - dist) / parameters.radius) * parameters.scale;
        percent = percent * percent;
        
        textureCoordinateToUse = textureCoordinateToUse * percent;
        textureCoordinateToUse += center;
    }
    
    return tex2D.sample(quadSampler, textureCoordinateToUse);
}

fragment half4 fragment_PinchDistortionFilter(VertexIO         inFrag  [[ stage_in ]],
                                              texture2d<half>  tex2D   [[ texture(0) ]],
                                              constant DistortionParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 center = parameters.center;
    float2 textureCoordinate = inFrag.textureCoordinate;
    float2 textureCoordinateToUse = float2(textureCoordinate.x, (textureCoordinate.y * parameters.aspectRatio + 0.5 - 0.5 * parameters.aspectRatio));
    float dist = distance((float2)parameters.center, textureCoordinateToUse);
    
    textureCoordinateToUse = textureCoordinate;
    
    if (dist < parameters.radius)
    {
        textureCoordinateToUse -= center;
        float percent = 1.0 + ((0.5 - dist) / 0.5) * parameters.scale;
        textureCoordinateToUse = textureCoordinateToUse * percent;
        textureCoordinateToUse += center;
    }

    return tex2D.sample(quadSampler, textureCoordinateToUse);
}

fragment half4 fragment_StretchDistortionFilter(VertexIO         inFrag  [[ stage_in ]],
                                                texture2d<half>  tex2D   [[ texture(0) ]],
                                                constant packed_float2 &center  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 normCoord = 2.0 * inFrag.textureCoordinate - 1.0;
    float2 normCenter = 2.0 * center - 1.0;
    
    normCoord -= normCenter;
    float2 s = sign(normCoord);
    normCoord = abs(normCoord);
    normCoord = 0.5 * normCoord + 0.5 * smoothstep(0.25, 0.5, normCoord) * normCoord;
    normCoord = s * normCoord;
    normCoord += normCenter;
    
    float2 textureCoordinateToUse = normCoord / 2.0 + 0.5;
    
    return tex2D.sample(quadSampler, textureCoordinateToUse);
}


