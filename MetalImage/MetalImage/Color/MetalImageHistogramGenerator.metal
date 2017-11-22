//
//  MetalImageHistogramGenerator.metal
//  MetalImage
//
//  Created by fengshi on 2017/9/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float height;
};

vertex VertexIO vertex_histogramGenerator(constant float4         *pPosition[[ buffer(0) ]],
                                          constant packed_float2  *pTexCoords[[ buffer(1) ]],
                                          uint                     vid[[ vertex_id ]])
{
    VertexIO outVertices;
    
    float2 pointTexCoordinate = pTexCoords[vid];
    
    outVertices.position =  pPosition[vid];
    outVertices.textureCoordinate =  float2(pointTexCoordinate.x, 0.5);
    outVertices.height = 1.0 - pointTexCoordinate.y;
    
    return outVertices;
}

fragment half4 fragment_histogramGenerator(VertexIO         inFrag  [[ stage_in ]],
                                           texture2d<half>  tex2D   [[ texture(0) ]],
                                           constant float4 &backgroundColor [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 colorChannels = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    half4 heightTest = half4(step(half(inFrag.height), colorChannels.rgb), 1.0h);
    
    return mix(half4(backgroundColor), heightTest, heightTest.r + heightTest.g + heightTest.b);
}



