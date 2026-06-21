//
//  CommonStruct.metal
//  MetalImage
//
//  Created by stonefeng on 2017/3/15.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include <metal_stdlib>
#include <metal_pack>
#include <metal_graphics>
#include <metal_matrix>
#include <metal_geometric>
#include <metal_math>
#include <metal_texture>

using namespace metal;

struct VertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

struct VertexIO2
{
    float4 position [[position]];
    float2 textureCoordinate [[attribute(0)]];
    float2 textureCoordinate2 [[attribute(1)]];
};

struct VertexIONearbyTexelSampling
{
    float4 position [[position]];
    
    float2 topLeftTextureCoordinate;
    float2 topTextureCoordinate;
    float2 topRightTextureCoordinate;
    
    float2 leftTextureCoordinate;
    float2 textureCoordinate [[user(texturecoord)]];
    float2 rightTextureCoordinate;
    
    float2 bottomLeftTextureCoordinate;
    float2 bottomTextureCoordinate;
    float2 bottomRightTextureCoordinate;
};

struct VertexIOWithSteps
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float2 texelSteps;
};
