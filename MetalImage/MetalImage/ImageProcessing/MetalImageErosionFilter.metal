//
//  MetalImageErosionFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "MetalImageDilationAndErosion.metal"

fragment half4 fragment_ErosionFilterRadius1(VertexDilationRadius1 inFrag[[ stage_in ]],
                                              texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half centerIntensity = texture2D.sample(qsampler, inFrag.centerTextureCoordinate).r;
    half oneStepPositiveIntensity = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate).r;
    half oneStepNegativeIntensity = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate).r;
    
    half minValue = min(centerIntensity, oneStepPositiveIntensity);
    minValue = min(minValue, oneStepNegativeIntensity);
    
    return half4(half3(minValue), 1.0h);
}

////////////////////////////////////////////////////////////////////////////////////////////

fragment half4 fragment_ErosionFilterRadius2(VertexDilationRadius2 inFrag[[ stage_in ]],
                                              texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half centerIntensity = texture2D.sample(qsampler, inFrag.centerTextureCoordinate).r;
    half oneStepPositiveIntensity = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate).r;
    half oneStepNegativeIntensity = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate).r;
    half twoStepsPositiveIntensity = texture2D.sample(qsampler, inFrag.twoStepsPositiveTextureCoordinate).r;
    half twoStepsNegativeIntensity = texture2D.sample(qsampler, inFrag.twoStepsNegativeTextureCoordinate).r;
    
    half minValue = min(centerIntensity, oneStepPositiveIntensity);
    minValue = min(minValue, oneStepNegativeIntensity);
    minValue = min(minValue, twoStepsPositiveIntensity);
    minValue = min(minValue, twoStepsNegativeIntensity);
    
    return half4(half3(minValue), 1.0h);
}

////////////////////////////////////////////////////////////////////////////////////////////

fragment half4 fragment_ErosionFilterRadius3(VertexDilationRadius3 inFrag[[ stage_in ]],
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
    
    half minValue = min(centerIntensity, oneStepPositiveIntensity);
    minValue = min(minValue, oneStepNegativeIntensity);
    minValue = min(minValue, twoStepsPositiveIntensity);
    minValue = min(minValue, twoStepsNegativeIntensity);
    minValue = min(minValue, threeStepsPositiveIntensity);
    minValue = min(minValue, threeStepsNegativeIntensity);
    
    return half4(half3(minValue), 1.0h);
}

////////////////////////////////////////////////////////////////////////////////////////////

fragment half4 fragment_ErosionFilterRadius4(VertexDilationRadius4 inFrag[[ stage_in ]],
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
    
    half minValue = min(centerIntensity, oneStepPositiveIntensity);
    minValue = min(minValue, oneStepNegativeIntensity);
    minValue = min(minValue, twoStepsPositiveIntensity);
    minValue = min(minValue, twoStepsNegativeIntensity);
    minValue = min(minValue, threeStepsPositiveIntensity);
    minValue = min(minValue, threeStepsNegativeIntensity);
    minValue = min(minValue, fourStepsPositiveIntensity);
    minValue = min(minValue, fourStepsNegativeIntensity);
    
    return half4(half3(minValue), 1.0h);
}
