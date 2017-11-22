//
//  MetalImageChromaKeyFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/8/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

// Shader code based on Apple's CIChromaKeyFilter example: https://developer.apple.com/library/mac/#samplecode/CIChromaKeyFilter/Introduction/Intro.html

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    packed_float3 colorToReplace;
    float smoothing;
    float thresholdSensitivity;
}ChromaKeyParameters;

fragment half4 fragment_chromaKey(VertexIO         inFrag  [[ stage_in ]],
                                  texture2d<half>  tex2D   [[ texture(0) ]],
                                  constant ChromaKeyParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 textureColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    float3 colorToReplace = parameters.colorToReplace;
    float smoothing = parameters.smoothing;
    float thresholdSensitivity = parameters.thresholdSensitivity;
    
    float maskY = 0.2989 * colorToReplace.r + 0.5866 * colorToReplace.g + 0.1145 * colorToReplace.b;
    float maskCr = 0.7132 * (colorToReplace.r - maskY);
    float maskCb = 0.5647 * (colorToReplace.b - maskY);
    
    float Y = 0.2989 * textureColor.r + 0.5866 * textureColor.g + 0.1145 * textureColor.b;
    float Cr = 0.7132 * (textureColor.r - Y);
    float Cb = 0.5647 * (textureColor.b - Y);
    
    //     float blendValue = 1.0 - smoothstep(thresholdSensitivity - smoothing, thresholdSensitivity , abs(Cr - maskCr) + abs(Cb - maskCb));
    float blendValue = smoothstep(thresholdSensitivity, thresholdSensitivity + smoothing, distance(float2(Cr, Cb), float2(maskCr, maskCb)));
    
    return half4(textureColor.rgb, textureColor.a * half(blendValue));
}



