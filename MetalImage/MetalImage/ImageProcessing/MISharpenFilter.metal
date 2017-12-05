//
//  MISharpenFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/16.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

struct VertexSharpen
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float2 leftTextureCoordinate;
    float2 rightTextureCoordinate;
    float2 topTextureCoordinate;
    float2 bottomTextureCoordinate;
    float centerMultiplier;
    float edgeMultiplier;
};

typedef struct {
    float imageWidthFactor;
    float imageHeightFactor;
    float sharpness;
}SharpenParameters;

vertex VertexSharpen vertex_SharpenFilter(constant float4            *pPosition     [[ buffer(0) ]],
                                          constant packed_float2     *pTexCoords    [[ buffer(1) ]],
                                          constant SharpenParameters &parameters    [[ buffer(2) ]],
                                          uint                        vid           [[ vertex_id ]])
{
    VertexSharpen outVertices;
    
    outVertices.position =  pPosition[vid];
    
    float2 widthStep = float2(parameters.imageWidthFactor, 0.0);
    float2 heightStep = float2(0.0, parameters.imageHeightFactor);
    
    float2 inputTextureCoordinate = pTexCoords[vid];
    outVertices.textureCoordinate = inputTextureCoordinate;
    outVertices.leftTextureCoordinate = inputTextureCoordinate.xy - widthStep;
    outVertices.rightTextureCoordinate = inputTextureCoordinate.xy + widthStep;
    outVertices.topTextureCoordinate = inputTextureCoordinate.xy - heightStep;
    outVertices.bottomTextureCoordinate = inputTextureCoordinate.xy + heightStep;
    outVertices.centerMultiplier = 1.0 + 4.0 * parameters.sharpness;
    outVertices.edgeMultiplier = parameters.sharpness;
    
    return outVertices;
}

fragment half4 fragment_SharpenFilter(VertexSharpen         inFrag  [[ stage_in ]],
                                      texture2d<half>       tex2D   [[ texture(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half3 textureColor = tex2D.sample(quadSampler, inFrag.textureCoordinate).rgb;
    half3 leftTextureColor = tex2D.sample(quadSampler, inFrag.leftTextureCoordinate).rgb;
    half3 rightTextureColor = tex2D.sample(quadSampler, inFrag.rightTextureCoordinate).rgb;
    half3 topTextureColor = tex2D.sample(quadSampler, inFrag.topTextureCoordinate).rgb;
    half4 bottomTextureColor = tex2D.sample(quadSampler, inFrag.bottomTextureCoordinate);
    half centerMultiplier = half(inFrag.centerMultiplier);
    half edgeMultiplier = half(inFrag.edgeMultiplier);
    
    return half4((textureColor * centerMultiplier - (leftTextureColor * edgeMultiplier + rightTextureColor * edgeMultiplier + topTextureColor * edgeMultiplier + bottomTextureColor.rgb * edgeMultiplier)), bottomTextureColor.w);
}


