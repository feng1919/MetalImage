//
//  MetalImageColorPackingFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexColorPacking
{
    float4 position [[position]];
    float2 centerTextureCoordinate [[user(texturecoord)]];
    float2 upperLeftInputTextureCoordinate;
    float2 upperRightInputTextureCoordinate;
    float2 lowerLeftInputTextureCoordinate;
    float2 lowerRightInputTextureCoordinate;
};

vertex VertexColorPacking vertex_ColorPackingFilter(constant float4         *pPosition   [[ buffer(0) ]],
                                                    constant packed_float2  *pTexCoords  [[ buffer(1) ]],
                                                    constant packed_float2  &texelOffset [[ buffer(2) ]],
                                                    uint                     vid         [[ vertex_id ]])
{
    float2 inputTextureCoordinate = pTexCoords[vid];
    float2 offset = float2(texelOffset);
    
    VertexColorPacking outVertices;
    outVertices.position = pPosition[vid];
    outVertices.upperLeftInputTextureCoordinate = inputTextureCoordinate - offset;
    outVertices.upperRightInputTextureCoordinate = inputTextureCoordinate + float2(offset.x, -offset.y);
    outVertices.lowerLeftInputTextureCoordinate = inputTextureCoordinate + float2(-offset.x, offset.y);
    outVertices.lowerRightInputTextureCoordinate = inputTextureCoordinate + offset;
    
    return outVertices;
}

fragment half4 fragment_ColorPackingFilter(VertexColorPacking inFrag[[ stage_in ]],
                                           texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half upperLeftIntensity = texture2D.sample(qsampler, inFrag.upperLeftInputTextureCoordinate).r;
    half upperRightIntensity = texture2D.sample(qsampler, inFrag.upperRightInputTextureCoordinate).r;
    half lowerLeftIntensity = texture2D.sample(qsampler, inFrag.lowerLeftInputTextureCoordinate).r;
    half lowerRightIntensity = texture2D.sample(qsampler, inFrag.lowerRightInputTextureCoordinate).r;
    
    return half4(upperLeftIntensity, upperRightIntensity, lowerLeftIntensity, lowerRightIntensity);
}


