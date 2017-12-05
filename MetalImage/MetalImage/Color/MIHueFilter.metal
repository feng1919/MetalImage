//
//  MIHueFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/7/22.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_math>

using namespace metal;

fragment half4 fragment_hue(VertexIO         inFrag  [[ stage_in ]],
                            texture2d<float>  tex2D   [[ texture(0) ]],
                            constant float &hueAdjust  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    const float4  kRGBToYPrime = float4(0.299, 0.587, 0.114, 0.0);
    const float4  kRGBToI      = float4(0.595716, -0.274453, -0.321263, 0.0);
    const float4  kRGBToQ      = float4(0.211456, -0.522591, 0.31135, 0.0);
    
    const float4  kYIQToR      = float4(1.0, 0.9563, 0.6210, 0.0);
    const float4  kYIQToG      = float4(1.0, -0.2721, -0.6474, 0.0);
    const float4  kYIQToB      = float4(1.0, -1.1070, 1.7046, 0.0);
    
    // Sample the input pixel
    float4 color = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    // Convert to YIQ
    float   YPrime  = dot (color, kRGBToYPrime);
    float   I       = dot (color, kRGBToI);
    float   Q       = dot (color, kRGBToQ);
    
    // Calculate the hue and chroma
    float   hue     = atan2 (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);
    
    // Make the user's adjustments
    hue += (-hueAdjust); //why negative rotation?
    
    // Convert back to YIQ
    Q = chroma * sin (hue);
    I = chroma * cos (hue);
    
    // Convert back to RGB
    float4 yIQ = float4(YPrime, I, Q, 0.0);
    color.r = dot (yIQ, kYIQToR);
    color.g = dot (yIQ, kYIQToG);
    color.b = dot (yIQ, kYIQToB);
    
    // Save the result
    return half4(color);
}






