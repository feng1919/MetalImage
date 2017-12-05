//
//  MIDilationAndErosion.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include <metal_stdlib>
#include <metal_math>

using namespace metal;

struct VertexDilationRadius1
{
    float4 position [[position]];
    float2 centerTextureCoordinate [[user(texturecoord)]];
    float2 oneStepPositiveTextureCoordinate;
    float2 oneStepNegativeTextureCoordinate;
};

struct VertexDilationRadius2
{
    float4 position [[position]];
    float2 centerTextureCoordinate [[user(texturecoord)]];
    float2 oneStepPositiveTextureCoordinate;
    float2 oneStepNegativeTextureCoordinate;
    float2 twoStepsPositiveTextureCoordinate;
    float2 twoStepsNegativeTextureCoordinate;
};

struct VertexDilationRadius3
{
    float4 position [[position]];
    float2 centerTextureCoordinate [[user(texturecoord)]];
    float2 oneStepPositiveTextureCoordinate;
    float2 oneStepNegativeTextureCoordinate;
    float2 twoStepsPositiveTextureCoordinate;
    float2 twoStepsNegativeTextureCoordinate;
    float2 threeStepsPositiveTextureCoordinate;
    float2 threeStepsNegativeTextureCoordinate;
};

struct VertexDilationRadius4
{
    float4 position [[position]];
    float2 centerTextureCoordinate [[user(texturecoord)]];
    float2 oneStepPositiveTextureCoordinate;
    float2 oneStepNegativeTextureCoordinate;
    float2 twoStepsPositiveTextureCoordinate;
    float2 twoStepsNegativeTextureCoordinate;
    float2 threeStepsPositiveTextureCoordinate;
    float2 threeStepsNegativeTextureCoordinate;
    float2 fourStepsPositiveTextureCoordinate;
    float2 fourStepsNegativeTextureCoordinate;
};
