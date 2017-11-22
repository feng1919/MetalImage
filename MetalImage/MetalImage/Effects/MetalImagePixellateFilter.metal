//
//  MetalImagePixellateFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    float fractionalWidthOfPixel;
    float aspectRatio;
}PixellateParameters;

fragment half4 fragment_PixellateFilter(VertexIO         inFrag  [[ stage_in ]],
                                             texture2d<half>  tex2D   [[ texture(0) ]],
                                             constant PixellateParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 sampleDivisor = float2(parameters.fractionalWidthOfPixel, parameters.fractionalWidthOfPixel / parameters.aspectRatio);
    
    float2 samplePos = inFrag.textureCoordinate - fmod(inFrag.textureCoordinate, sampleDivisor) + 0.5 * sampleDivisor;
    
    return tex2D.sample(quadSampler, samplePos);
}

typedef struct {
    float fractionalWidthOfPixel;
    float aspectRatio;
    float dotScaling;
}PolkaDotParameters;

fragment half4 fragment_PolkaDotFilter(VertexIO         inFrag  [[ stage_in ]],
                                       texture2d<half>  tex2D   [[ texture(0) ]],
                                       constant PolkaDotParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 sampleDivisor = float2(parameters.fractionalWidthOfPixel, parameters.fractionalWidthOfPixel / parameters.aspectRatio);
    
    float2 textureCoordinate = inFrag.textureCoordinate;
    float2 samplePos = textureCoordinate - fmod(textureCoordinate, sampleDivisor) + 0.5 * sampleDivisor;
    
    float2 textureCoordinateToUse = float2(textureCoordinate.x, (textureCoordinate.y * parameters.aspectRatio + 0.5 - 0.5 * parameters.aspectRatio));
    float2 adjustedSamplePos = float2(samplePos.x, (samplePos.y * parameters.aspectRatio + 0.5 - 0.5 * parameters.aspectRatio));
    
    float distanceFromSamplePoint = distance(adjustedSamplePos, textureCoordinateToUse);
    float checkForPresenceWithinDot = step(distanceFromSamplePoint, (parameters.fractionalWidthOfPixel * 0.5) * parameters.dotScaling);
    
    half4 inputColor = tex2D.sample(quadSampler, samplePos);
    
    return half4(inputColor.rgb * checkForPresenceWithinDot, inputColor.a);
}

fragment half4 fragment_HalftoneFilter(VertexIO         inFrag  [[ stage_in ]],
                                       texture2d<half>  tex2D   [[ texture(0) ]],
                                       constant PixellateParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    const half3 W = half3(0.2125, 0.7154, 0.0721);
    
    float2 sampleDivisor = float2(parameters.fractionalWidthOfPixel, parameters.fractionalWidthOfPixel / parameters.aspectRatio);
    
    float2 textureCoordinate = inFrag.textureCoordinate;
    float2 samplePos = textureCoordinate - fmod(textureCoordinate, sampleDivisor) + 0.5 * sampleDivisor;
    
    float2 textureCoordinateToUse = float2(textureCoordinate.x, (textureCoordinate.y * parameters.aspectRatio + 0.5 - 0.5 * parameters.aspectRatio));
    float2 adjustedSamplePos = float2(samplePos.x, (samplePos.y * parameters.aspectRatio + 0.5 - 0.5 * parameters.aspectRatio));
    
    float distanceFromSamplePoint = distance(adjustedSamplePos, textureCoordinateToUse);
    
    half3 sampledColor = tex2D.sample(quadSampler, samplePos).rgb;
    half dotScaling = 1.0h - dot(sampledColor, W);
    
    float checkForPresenceWithinDot = 1.0 - step(distanceFromSamplePoint, (parameters.fractionalWidthOfPixel * 0.5) * dotScaling);

    return half4(half3(checkForPresenceWithinDot), 1.0h);
}

