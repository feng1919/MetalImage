//
//  MIRGBErosionFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "MIDilationAndErosion.metal"

fragment half4 fragment_RGBErosionFilterRadius1(VertexDilationRadius1 inFrag[[ stage_in ]],
                                                 texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 centerColor = texture2D.sample(qsampler, inFrag.centerTextureCoordinate);
    half4 oneStepPositiveColor = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate);
    half4 oneStepNegativeColor = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate);
    
    half4 minValue = min(centerColor, oneStepPositiveColor);
    minValue = min(minValue, oneStepNegativeColor);
    
    return minValue;
}

////////////////////////////////////////////////////////////////////////////////////////////

fragment half4 fragment_RGBErosionFilterRadius2(VertexDilationRadius2 inFrag[[ stage_in ]],
                                                 texture2d<half> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 centerColor = texture2D.sample(qsampler, inFrag.centerTextureCoordinate);
    half4 oneStepPositiveColor = texture2D.sample(qsampler, inFrag.oneStepPositiveTextureCoordinate);
    half4 oneStepNegativeColor = texture2D.sample(qsampler, inFrag.oneStepNegativeTextureCoordinate);
    half4 twoStepsPositiveColor = texture2D.sample(qsampler, inFrag.twoStepsPositiveTextureCoordinate);
    half4 twoStepsNegativeColor = texture2D.sample(qsampler, inFrag.twoStepsNegativeTextureCoordinate);
    
    half4 minValue = min(centerColor, oneStepPositiveColor);
    minValue = min(minValue, oneStepNegativeColor);
    minValue = min(minValue, twoStepsPositiveColor);
    minValue = min(minValue, twoStepsNegativeColor);
    
    return minValue;
}

////////////////////////////////////////////////////////////////////////////////////////////

fragment half4 fragment_RGBErosionFilterRadius3(VertexDilationRadius3 inFrag[[ stage_in ]],
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
    
    half4 minValue = min(centerColor, oneStepPositiveColor);
    minValue = min(minValue, oneStepNegativeColor);
    minValue = min(minValue, twoStepsPositiveColor);
    minValue = min(minValue, twoStepsNegativeColor);
    minValue = min(minValue, threeStepsPositiveColor);
    minValue = min(minValue, threeStepsNegativeColor);
    
    return minValue;
}

////////////////////////////////////////////////////////////////////////////////////////////

fragment half4 fragment_RGBErosionFilterRadius4(VertexDilationRadius4 inFrag[[ stage_in ]],
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
    
    half4 minValue = min(centerColor, oneStepPositiveColor);
    minValue = min(minValue, oneStepNegativeColor);
    minValue = min(minValue, twoStepsPositiveColor);
    minValue = min(minValue, twoStepsNegativeColor);
    minValue = min(minValue, threeStepsPositiveColor);
    minValue = min(minValue, threeStepsNegativeColor);
    minValue = min(minValue, fourStepsPositiveColor);
    minValue = min(minValue, fourStepsNegativeColor);
    
    return minValue;
}


