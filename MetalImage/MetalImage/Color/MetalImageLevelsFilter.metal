//
//  MetalImageLevelsFilter.metal
//  MetalImage
//
//  Created by Stone Feng on 2017/8/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"

//using namespace metal;

/*
 ** Gamma correction
 ** Details: http://blog.mouaif.org/2009/01/22/photoshop-gamma-correction-shader/
 */

#define GammaCorrection(color, gamma)								pow(color, 1.0h / gamma)

/*
 ** Levels control (input (+gamma), output)
 ** Details: http://blog.mouaif.org/2009/01/28/levels-control-shader/
 */

#define LevelsControlInputRange(color, minInput, maxInput)				min(max(color - minInput, half3(0.0)) / (maxInput - minInput), half3(1.0))
#define LevelsControlInput(color, minInput, gamma, maxInput)			GammaCorrection(LevelsControlInputRange(color, minInput, maxInput), gamma)
#define LevelsControlOutputRange(color, minOutput, maxOutput) 			mix(minOutput, maxOutput, color)
#define LevelsControl(color, minInput, gamma, maxInput, minOutput, maxOutput) 	LevelsControlOutputRange(LevelsControlInput(color, minInput, gamma, maxInput), minOutput, maxOutput)

struct LevelsParameters{
    packed_float3 levelMinimum;
    packed_float3 levelMiddle;
    packed_float3 levelMaximum;
    packed_float3 minOutput;
    packed_float3 maxOutput;
};

fragment half4 fragment_levels(VertexIO         inFrag   [[ stage_in ]],
                               texture2d<half>  tex2D   [[ texture(0) ]],
                               constant LevelsParameters &levelsParameters [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    half4 inColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    half3 levelMinimum = half3(levelsParameters.levelMinimum);
    half3 levelMiddle = half3(levelsParameters.levelMiddle);
    half3 levelMaximum = half3(levelsParameters.levelMaximum);
    half3 minOutput = half3(levelsParameters.minOutput);
    half3 maxOutput = half3(levelsParameters.maxOutput);
    
    return half4(LevelsControl(inColor.rgb, levelMinimum, levelMiddle, levelMaximum, minOutput, maxOutput), inColor.a);
}
