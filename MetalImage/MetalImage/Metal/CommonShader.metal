//
//  CommonShader.metal
//  MetalImage
//
//  Created by stonefeng on 2017/3/15.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "CommonStruct.metal"

vertex VertexIO vertex_common(constant float4         *pPosition[[ buffer(0) ]],
                              constant packed_float2  *pTexCoords[[ buffer(1) ]],
                              uint                     vid[[ vertex_id ]])
{
    VertexIO outVertices;
    
    outVertices.position =  pPosition[vid];
    outVertices.textureCoordinate =  pTexCoords[vid];
    
    return outVertices;
}

fragment half4 fragment_common(VertexIO inFrag[[ stage_in ]],
                               texture2d<half> tex2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 color = tex2D.sample(qsampler, inFrag.textureCoordinate);
    return color;
}

vertex VertexIO2 vertex_common2(constant float4         *pPosition[[ buffer(0) ]],
                                constant packed_float2  *pTexCoords[[ buffer(1) ]],
                                constant packed_float2  *pTexCoords2[[ buffer(2) ]],
                                uint                     vid[[ vertex_id ]])
{
    VertexIO2 outVertices;
    
    outVertices.position =  pPosition[vid];
    outVertices.textureCoordinate =  pTexCoords[vid];
    outVertices.textureCoordinate2 = pTexCoords2[vid];
    
    return outVertices;
}

fragment half4 fragment_common2(VertexIO2 inFrag[[ stage_in ]], texture2d<half> tex2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 color = tex2D.sample(qsampler, inFrag.textureCoordinate);
    return color;
}


fragment half4 fragment_common2_test(VertexIO2 inFrag[[ stage_in ]],
                                     texture2d<half> tex2D[[ texture(0) ]],
                                     texture2d<half> tex2D2[[ texture(1) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 color = tex2D.sample(qsampler, inFrag.textureCoordinate);
    half4 color2 = tex2D2.sample(qsampler, inFrag.textureCoordinate2);
    return mix(color, color2, color2.r);
}


kernel void kernel_default(texture2d<float, access::read> inTexture  [[ texture(0) ]],
                           texture2d<float, access::write> outTexture  [[ texture(1) ]],
                           uint2 gid [[thread_position_in_grid ]]) {
    float4 value = inTexture.read(gid);
    outTexture.write(value, gid);
}

kernel void kernel_default2(texture2d<float, access::read> inTexture  [[ texture(0) ]],
                            texture2d<float, access::write> outTexture  [[ texture(1) ]],
                            texture2d<float, access::read> inTexture2  [[ texture(2) ]],
                            uint2 gid [[thread_position_in_grid ]]) {
    float4 value = inTexture.read(gid);
    float4 value2 = inTexture2.read(gid);
    outTexture.write(mix(value, value2, 0.5), gid);
}


vertex VertexIONearbyTexelSampling vertex_nearbyTexelSampling(constant float4         *pPosition[[ buffer(0) ]],
                                                              constant float2  *pTexCoords[[ buffer(1) ]],
                                                              constant float2         &texelSize [[buffer(2)]],
                                                              uint                     vid[[ vertex_id ]])
{
    
    float2 widthStep = float2(texelSize.x, 0.0);
    float2 heightStep = float2(0.0, texelSize.y);
    float2 widthHeightStep = float2(texelSize.x, texelSize.y);
    float2 widthNegativeHeightStep = float2(texelSize.x, -texelSize.y);
    float2 inputTextureCoordinate = pTexCoords[vid];
    
    VertexIONearbyTexelSampling outVertices;
    
    outVertices.position =  pPosition[vid];
    
    outVertices.textureCoordinate = inputTextureCoordinate.xy;
    outVertices.leftTextureCoordinate = inputTextureCoordinate.xy - widthStep;
    outVertices.rightTextureCoordinate = inputTextureCoordinate.xy + widthStep;
    
    outVertices.topTextureCoordinate = inputTextureCoordinate.xy - heightStep;
    outVertices.topLeftTextureCoordinate = inputTextureCoordinate.xy - widthHeightStep;
    outVertices.topRightTextureCoordinate = inputTextureCoordinate.xy + widthNegativeHeightStep;
    
    outVertices.bottomTextureCoordinate = inputTextureCoordinate.xy + heightStep;
    outVertices.bottomLeftTextureCoordinate = inputTextureCoordinate.xy - widthNegativeHeightStep;
    outVertices.bottomRightTextureCoordinate = inputTextureCoordinate.xy + widthHeightStep;
    
    return outVertices;
}


