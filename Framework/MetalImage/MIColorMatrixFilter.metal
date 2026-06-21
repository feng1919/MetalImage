//
//  MIColorMatrixFilter.metal
//  MetalImage
//
//  Created by Stone Feng on 2017/8/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

struct ColorMatrix
{
    packed_float4 red;
    packed_float4 green;
    packed_float4 blue;
    packed_float4 alpha;
    float intensity;
};

fragment half4 fragment_colorMatrix(VertexIO         inFrag   [[ stage_in ]],
                                    texture2d<half>  tex2D   [[ texture(0) ]],
                                    constant ColorMatrix &matrixParameter [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 inColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);

    half4x4 colorMatrix = half4x4(half4(matrixParameter.red),
                                  half4(matrixParameter.green),
                                  half4(matrixParameter.blue),
                                  half4(matrixParameter.alpha));
    half4 outputColor = inColor * colorMatrix;
    half intensity = (half)matrixParameter.intensity;

    return mix(inColor, outputColor, intensity);
}

