//
//  MILanczosResamplingFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/12/5.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexLanczosResampling
{
    float4 position [[position]];
    float2 centerTextureCoordinate [[user(texturecoord)]];
    float2 oneStepLeftTextureCoordinate;
    float2 twoStepsLeftTextureCoordinate;
    float2 threeStepsLeftTextureCoordinate;
    float2 fourStepsLeftTextureCoordinate;
    float2 oneStepRightTextureCoordinate;
    float2 twoStepsRightTextureCoordinate;
    float2 threeStepsRightTextureCoordinate;
    float2 fourStepsRightTextureCoordinate;
};

vertex VertexLanczosResampling vertex_LanczosResamplingFilter(constant float4         *pPosition   [[ buffer(0) ]],
                                                              constant packed_float2  *pTexCoords  [[ buffer(1) ]],
                                                              constant packed_float2  &texelOffset [[ buffer(2) ]],
                                                              uint                     vid         [[ vertex_id ]])
{
    float2 inputTextureCoordinate = pTexCoords[vid];
    float2 firstOffset = float2(texelOffset);
    float2 secondOffset = firstOffset * 2.0f;
    float2 thirdOffset = firstOffset * 3.0f;
    float2 fourthOffset = firstOffset * 4.0f;
    
    VertexLanczosResampling outVertices;
    outVertices.position = pPosition[vid];
    outVertices.centerTextureCoordinate = inputTextureCoordinate;
    outVertices.oneStepLeftTextureCoordinate = inputTextureCoordinate - firstOffset;
    outVertices.twoStepsLeftTextureCoordinate = inputTextureCoordinate - secondOffset;
    outVertices.threeStepsLeftTextureCoordinate = inputTextureCoordinate - thirdOffset;
    outVertices.fourStepsLeftTextureCoordinate = inputTextureCoordinate - fourthOffset;
    outVertices.oneStepRightTextureCoordinate = inputTextureCoordinate + firstOffset;
    outVertices.twoStepsRightTextureCoordinate = inputTextureCoordinate + secondOffset;
    outVertices.threeStepsRightTextureCoordinate = inputTextureCoordinate + thirdOffset;
    outVertices.fourStepsRightTextureCoordinate = inputTextureCoordinate + fourthOffset;
    
    return outVertices;
}

fragment half4 fragment_LanczosResamplingFilter(VertexLanczosResampling inFrag[[ stage_in ]],
                                                texture2d<float> texture2D[[ texture(0) ]])
{
    constexpr sampler qsampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    // sinc(x) * sinc(x/a) = (a * sin(pi * x) * sin(pi * x / a)) / (pi^2 * x^2)
    // Assuming a Lanczos constant of 2.0, and scaling values to max out at x = +/- 1.5
    
    float4 fragmentColor = texture2D.sample(qsampler, inFrag.centerTextureCoordinate) * 0.38026;
    
    fragmentColor += texture2D.sample(qsampler, inFrag.oneStepLeftTextureCoordinate) * 0.27667;
    fragmentColor += texture2D.sample(qsampler, inFrag.oneStepRightTextureCoordinate) * 0.27667;
    
    fragmentColor += texture2D.sample(qsampler, inFrag.twoStepsLeftTextureCoordinate) * 0.08074;
    fragmentColor += texture2D.sample(qsampler, inFrag.twoStepsRightTextureCoordinate) * 0.08074;
    
    fragmentColor += texture2D.sample(qsampler, inFrag.threeStepsLeftTextureCoordinate) * -0.02612;
    fragmentColor += texture2D.sample(qsampler, inFrag.threeStepsRightTextureCoordinate) * -0.02612;
    
    fragmentColor += texture2D.sample(qsampler, inFrag.fourStepsLeftTextureCoordinate) * -0.02143;
    fragmentColor += texture2D.sample(qsampler, inFrag.fourStepsRightTextureCoordinate) * -0.02143;
    
    return half4(fragmentColor);
}
