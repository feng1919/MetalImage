//
//  MIDilationFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "MIDilationAndErosion.metal"

vertex VertexDilationRadius1 vertex_DilationFilterRadius1(constant float4         *pPosition   [[ buffer(0) ]],
                                                          constant packed_float2  *pTexCoords  [[ buffer(1) ]],
                                                          constant packed_float2  &texelOffset [[ buffer(2) ]],
                                                          uint                     vid         [[ vertex_id ]])
{
    float2 inputTextureCoordinate = pTexCoords[vid];
    float2 offset = float2(texelOffset);
    
    VertexDilationRadius1 outVertices;
    outVertices.position = pPosition[vid];
    outVertices.centerTextureCoordinate = inputTextureCoordinate;
    outVertices.oneStepNegativeTextureCoordinate = inputTextureCoordinate - offset;
    outVertices.oneStepPositiveTextureCoordinate = inputTextureCoordinate + offset;
    
    return outVertices;
}

fragment half4 fragment_DilationFilterRadius1(VertexDilationRadius1 inFrag[[ stage_in ]],
                                              texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);

    half centerIntensity = texture2D.sample(qsampler, inFrag.centerTextureCoordinate).r;
    half oneStepPositiveIntensity = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate).r;
    half oneStepNegativeIntensity = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate).r;
    
    half maxValue = max(centerIntensity, oneStepPositiveIntensity);
    maxValue = max(maxValue, oneStepNegativeIntensity);
    
    return half4(half3(maxValue), 1.0h);
}

////////////////////////////////////////////////////////////////////////////////////////////

vertex VertexDilationRadius2 vertex_DilationFilterRadius2(constant float4         *pPosition   [[ buffer(0) ]],
                                                          constant packed_float2  *pTexCoords  [[ buffer(1) ]],
                                                          constant packed_float2  &texelOffset [[ buffer(2) ]],
                                                          uint                     vid         [[ vertex_id ]])
{
    float2 inputTextureCoordinate = pTexCoords[vid];
    float2 offset = float2(texelOffset);
    
    VertexDilationRadius2 outVertices;
    outVertices.position = pPosition[vid];
    outVertices.centerTextureCoordinate = inputTextureCoordinate;
    outVertices.oneStepNegativeTextureCoordinate = inputTextureCoordinate - offset;
    outVertices.oneStepPositiveTextureCoordinate = inputTextureCoordinate + offset;
    outVertices.twoStepsNegativeTextureCoordinate = inputTextureCoordinate - (offset * 2.0);
    outVertices.twoStepsPositiveTextureCoordinate = inputTextureCoordinate + (offset * 2.0);
    
    return outVertices;
}

fragment half4 fragment_DilationFilterRadius2(VertexDilationRadius2 inFrag[[ stage_in ]],
                                              texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half centerIntensity = texture2D.sample(qsampler, inFrag.centerTextureCoordinate).r;
    half oneStepPositiveIntensity = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate).r;
    half oneStepNegativeIntensity = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate).r;
    half twoStepsPositiveIntensity = texture2D.sample(qsampler, inFrag.twoStepsPositiveTextureCoordinate).r;
    half twoStepsNegativeIntensity = texture2D.sample(qsampler, inFrag.twoStepsNegativeTextureCoordinate).r;
    
    half maxValue = max(centerIntensity, oneStepPositiveIntensity);
    maxValue = max(maxValue, oneStepNegativeIntensity);
    maxValue = max(maxValue, twoStepsPositiveIntensity);
    maxValue = max(maxValue, twoStepsNegativeIntensity);
    
    return half4(half3(maxValue), 1.0h);
}

////////////////////////////////////////////////////////////////////////////////////////////

vertex VertexDilationRadius3 vertex_DilationFilterRadius3(constant float4         *pPosition   [[ buffer(0) ]],
                                                          constant packed_float2  *pTexCoords  [[ buffer(1) ]],
                                                          constant packed_float2  &texelOffset [[ buffer(2) ]],
                                                          uint                     vid         [[ vertex_id ]])
{
    float2 inputTextureCoordinate = pTexCoords[vid];
    float2 offset = float2(texelOffset);
    
    VertexDilationRadius3 outVertices;
    outVertices.position = pPosition[vid];
    outVertices.centerTextureCoordinate = inputTextureCoordinate;
    outVertices.oneStepNegativeTextureCoordinate = inputTextureCoordinate - offset;
    outVertices.oneStepPositiveTextureCoordinate = inputTextureCoordinate + offset;
    outVertices.twoStepsNegativeTextureCoordinate = inputTextureCoordinate - (offset * 2.0);
    outVertices.twoStepsPositiveTextureCoordinate = inputTextureCoordinate + (offset * 2.0);
    outVertices.threeStepsNegativeTextureCoordinate = inputTextureCoordinate - (offset * 3.0);
    outVertices.threeStepsPositiveTextureCoordinate = inputTextureCoordinate + (offset * 3.0);
    
    return outVertices;
}

fragment half4 fragment_DilationFilterRadius3(VertexDilationRadius3 inFrag[[ stage_in ]],
                                              texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half centerIntensity = texture2D.sample(qsampler, inFrag.centerTextureCoordinate).r;
    half oneStepPositiveIntensity = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate).r;
    half oneStepNegativeIntensity = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate).r;
    half twoStepsPositiveIntensity = texture2D.sample(qsampler, inFrag.twoStepsPositiveTextureCoordinate).r;
    half twoStepsNegativeIntensity = texture2D.sample(qsampler, inFrag.twoStepsNegativeTextureCoordinate).r;
    half threeStepsPositiveIntensity = texture2D.sample(qsampler, inFrag.threeStepsPositiveTextureCoordinate).r;
    half threeStepsNegativeIntensity = texture2D.sample(qsampler, inFrag.threeStepsNegativeTextureCoordinate).r;
    
    half maxValue = max(centerIntensity, oneStepPositiveIntensity);
    maxValue = max(maxValue, oneStepNegativeIntensity);
    maxValue = max(maxValue, twoStepsPositiveIntensity);
    maxValue = max(maxValue, twoStepsNegativeIntensity);
    maxValue = max(maxValue, threeStepsPositiveIntensity);
    maxValue = max(maxValue, threeStepsNegativeIntensity);
    
    return half4(half3(maxValue), 1.0h);
}

////////////////////////////////////////////////////////////////////////////////////////////

vertex VertexDilationRadius4 vertex_DilationFilterRadius4(constant float4         *pPosition   [[ buffer(0) ]],
                                                          constant packed_float2  *pTexCoords  [[ buffer(1) ]],
                                                          constant packed_float2  &texelOffset [[ buffer(2) ]],
                                                          uint                     vid         [[ vertex_id ]])
{
    float2 inputTextureCoordinate = pTexCoords[vid];
    float2 offset = float2(texelOffset);
    
    VertexDilationRadius4 outVertices;
    outVertices.position = pPosition[vid];
    outVertices.centerTextureCoordinate = inputTextureCoordinate;
    outVertices.oneStepNegativeTextureCoordinate = inputTextureCoordinate - offset;
    outVertices.oneStepPositiveTextureCoordinate = inputTextureCoordinate + offset;
    outVertices.twoStepsNegativeTextureCoordinate = inputTextureCoordinate - (offset * 2.0);
    outVertices.twoStepsPositiveTextureCoordinate = inputTextureCoordinate + (offset * 2.0);
    outVertices.threeStepsNegativeTextureCoordinate = inputTextureCoordinate - (offset * 3.0);
    outVertices.threeStepsPositiveTextureCoordinate = inputTextureCoordinate + (offset * 3.0);
    outVertices.fourStepsNegativeTextureCoordinate = inputTextureCoordinate - (offset * 4.0);
    outVertices.fourStepsPositiveTextureCoordinate = inputTextureCoordinate + (offset * 4.0);
    
    return outVertices;
}

fragment half4 fragment_DilationFilterRadius4(VertexDilationRadius4 inFrag[[ stage_in ]],
                                              texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half centerIntensity = texture2D.sample(qsampler, inFrag.centerTextureCoordinate).r;
    half oneStepPositiveIntensity = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate).r;
    half oneStepNegativeIntensity = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate).r;
    half twoStepsPositiveIntensity = texture2D.sample(qsampler, inFrag.twoStepsPositiveTextureCoordinate).r;
    half twoStepsNegativeIntensity = texture2D.sample(qsampler, inFrag.twoStepsNegativeTextureCoordinate).r;
    half threeStepsPositiveIntensity = texture2D.sample(qsampler, inFrag.threeStepsPositiveTextureCoordinate).r;
    half threeStepsNegativeIntensity = texture2D.sample(qsampler, inFrag.threeStepsNegativeTextureCoordinate).r;
    half fourStepsPositiveIntensity = texture2D.sample(qsampler, inFrag.fourStepsPositiveTextureCoordinate).r;
    half fourStepsNegativeIntensity = texture2D.sample(qsampler, inFrag.fourStepsNegativeTextureCoordinate).r;
    
    half maxValue = max(centerIntensity, oneStepPositiveIntensity);
    maxValue = max(maxValue, oneStepNegativeIntensity);
    maxValue = max(maxValue, twoStepsPositiveIntensity);
    maxValue = max(maxValue, twoStepsNegativeIntensity);
    maxValue = max(maxValue, threeStepsPositiveIntensity);
    maxValue = max(maxValue, threeStepsNegativeIntensity);
    maxValue = max(maxValue, fourStepsPositiveIntensity);
    maxValue = max(maxValue, fourStepsNegativeIntensity);
    
    return half4(half3(maxValue), 1.0h);
}
