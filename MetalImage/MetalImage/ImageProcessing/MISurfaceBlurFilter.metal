//
//  MISurfaceBlurFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2020/6/23.
//  Copyright © 2020 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_Surface_Blur(VertexIOWithSteps   inFrag     [[ stage_in ]],
                                     texture2d<half>     texture2D  [[ texture(0) ]],
                                     constant int        &radius    [[ buffer(0) ]],
                                     constant float      &gamma     [[ buffer(1) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half3 texture0 = texture2D.sample(quadSampler, inFrag.textureCoordinate).rgb;
    
    float3 accumulator = float3(0.0f);
    float3 accumulator_k = float3(0.0f);
    const float eps = 0.0001f;
    const int iter = 2 * radius + 1;
    
    int col, row;
    for (row = 0; row < iter; row++) {
        for (col = 0; col < iter; col ++) {
            float2 textCoord = float2(inFrag.textureCoordinate.x + inFrag.texelSteps.x * (col-radius),
                                      inFrag.textureCoordinate.y + inFrag.texelSteps.y * (row-radius));
            half3 texture = texture2D.sample(quadSampler, textCoord).rgb;
            float3 k = 1.0f - float3(abs(texture - texture0)) / gamma;
            k += eps;
            
            accumulator_k += k;
            accumulator += k * float3(texture);
        }
    }
    
    half3 color = half3(accumulator / accumulator_k);
    if (color.r < 0.0h || color.g < 0.0h || color.b < 0.0h) {
        return half4(texture0, 1.0h);
    }
    
    if (color.r > 1.0h || color.g > 1.0h || color.b > 1.0h) {
        return half4(texture0, 1.0h);
    }
    
    return half4(color, 1.0h);
}




