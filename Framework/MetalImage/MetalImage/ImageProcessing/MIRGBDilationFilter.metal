//
//  MIRGBDilationFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "MIDilationAndErosion.metal"

fragment half4 fragment_RGBDilationFilterRadius1(VertexDilationRadius1 inFrag[[ stage_in ]],
                                              texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 centerColor = texture2D.sample(qsampler, inFrag.centerTextureCoordinate);
    half4 oneStepPositiveColor = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate);
    half4 oneStepNegativeColor = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate);
    
    half4 maxValue = max(centerColor, oneStepPositiveColor);
    maxValue = max(maxValue, oneStepNegativeColor);
    
    return maxValue;
}

////////////////////////////////////////////////////////////////////////////////////////////

fragment half4 fragment_RGBDilationFilterRadius2(VertexDilationRadius2 inFrag[[ stage_in ]],
                                              texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 centerColor = texture2D.sample(qsampler, inFrag.centerTextureCoordinate);
    half4 oneStepPositiveColor = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate);
    half4 oneStepNegativeColor = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate);
    half4 twoStepsPositiveColor = texture2D.sample(qsampler, inFrag.twoStepsPositiveTextureCoordinate);
    half4 twoStepsNegativeColor = texture2D.sample(qsampler, inFrag.twoStepsNegativeTextureCoordinate);
    
    half4 maxValue = max(centerColor, oneStepPositiveColor);
    maxValue = max(maxValue, oneStepNegativeColor);
    maxValue = max(maxValue, twoStepsPositiveColor);
    maxValue = max(maxValue, twoStepsNegativeColor);
    
    return maxValue;
}

////////////////////////////////////////////////////////////////////////////////////////////

fragment half4 fragment_RGBDilationFilterRadius3(VertexDilationRadius3 inFrag[[ stage_in ]],
                                              texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 centerColor = texture2D.sample(qsampler, inFrag.centerTextureCoordinate);
    half4 oneStepPositiveColor = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate);
    half4 oneStepNegativeColor = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate);
    half4 twoStepsPositiveColor = texture2D.sample(qsampler, inFrag.twoStepsPositiveTextureCoordinate);
    half4 twoStepsNegativeColor = texture2D.sample(qsampler, inFrag.twoStepsNegativeTextureCoordinate);
    half4 threeStepsPositiveColor = texture2D.sample(qsampler, inFrag.threeStepsPositiveTextureCoordinate);
    half4 threeStepsNegativeColor = texture2D.sample(qsampler, inFrag.threeStepsNegativeTextureCoordinate);
    
    half4 maxValue = max(centerColor, oneStepPositiveColor);
    maxValue = max(maxValue, oneStepNegativeColor);
    maxValue = max(maxValue, twoStepsPositiveColor);
    maxValue = max(maxValue, twoStepsNegativeColor);
    maxValue = max(maxValue, threeStepsPositiveColor);
    maxValue = max(maxValue, threeStepsNegativeColor);
    
    return maxValue;
}

////////////////////////////////////////////////////////////////////////////////////////////

fragment half4 fragment_RGBDilationFilterRadius4(VertexDilationRadius4 inFrag[[ stage_in ]],
                                              texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 centerColor = texture2D.sample(qsampler, inFrag.centerTextureCoordinate);
    half4 oneStepPositiveColor = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate);
    half4 oneStepNegativeColor = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate);
    half4 twoStepsPositiveColor = texture2D.sample(qsampler, inFrag.twoStepsPositiveTextureCoordinate);
    half4 twoStepsNegativeColor = texture2D.sample(qsampler, inFrag.twoStepsNegativeTextureCoordinate);
    half4 threeStepsPositiveColor = texture2D.sample(qsampler, inFrag.threeStepsPositiveTextureCoordinate);
    half4 threeStepsNegativeColor = texture2D.sample(qsampler, inFrag.threeStepsNegativeTextureCoordinate);
    half4 fourStepsPositiveColor = texture2D.sample(qsampler, inFrag.fourStepsPositiveTextureCoordinate);
    half4 fourStepsNegativeColor = texture2D.sample(qsampler, inFrag.fourStepsNegativeTextureCoordinate);
    
    half4 maxValue = max(centerColor, oneStepPositiveColor);
    maxValue = max(maxValue, oneStepNegativeColor);
    maxValue = max(maxValue, twoStepsPositiveColor);
    maxValue = max(maxValue, twoStepsNegativeColor);
    maxValue = max(maxValue, threeStepsPositiveColor);
    maxValue = max(maxValue, threeStepsNegativeColor);
    maxValue = max(maxValue, fourStepsPositiveColor);
    maxValue = max(maxValue, fourStepsNegativeColor);
    
    return maxValue;
}


