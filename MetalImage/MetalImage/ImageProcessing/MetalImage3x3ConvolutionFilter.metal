//
//  MetalImage3x3ConvolutionFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/18.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

typedef struct{
    packed_float3 v0;
    packed_float3 v1;
    packed_float3 v2;
}Convolution3x3Kernel;

fragment half4 fragment_Convolution3x3Filter(VertexIONearbyTexelSampling         inFrag  [[ stage_in ]],
                                             texture2d<half>                   texture2D  [[ texture(0) ]],
                                             constant Convolution3x3Kernel &convolutionMatrix [[buffer(0)]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half3 bottomColor = texture2D.sample(quadSampler,  inFrag.bottomTextureCoordinate).rgb;
    half3 bottomLeftColor = texture2D.sample(quadSampler,  inFrag.bottomLeftTextureCoordinate).rgb;
    half3 bottomRightColor = texture2D.sample(quadSampler,  inFrag.bottomRightTextureCoordinate).rgb;
    half4 centerColor = texture2D.sample(quadSampler,  inFrag.textureCoordinate);
    half3 leftColor = texture2D.sample(quadSampler,  inFrag.leftTextureCoordinate).rgb;
    half3 rightColor = texture2D.sample(quadSampler,  inFrag.rightTextureCoordinate).rgb;
    half3 topColor = texture2D.sample(quadSampler,  inFrag.topTextureCoordinate).rgb;
    half3 topRightColor = texture2D.sample(quadSampler,  inFrag.topRightTextureCoordinate).rgb;
    half3 topLeftColor = texture2D.sample(quadSampler,  inFrag.topLeftTextureCoordinate).rgb;
    
    half3 resultColor = topLeftColor * convolutionMatrix.v0[0] + topColor * convolutionMatrix.v0[1] + topRightColor * convolutionMatrix.v0[2];
    resultColor += leftColor * convolutionMatrix.v1[0] + centerColor.rgb * convolutionMatrix.v1[1] + rightColor * convolutionMatrix.v1[2];
    resultColor += bottomLeftColor * convolutionMatrix.v2[0] + bottomColor * convolutionMatrix.v2[1] + bottomRightColor * convolutionMatrix.v2[2];
    
    return half4(resultColor, centerColor.a);
}

fragment half4 fragment_LaplacianFilter(VertexIONearbyTexelSampling         inFrag  [[ stage_in ]],
                                        texture2d<half>                   texture2D  [[ texture(0) ]],
                                        constant Convolution3x3Kernel &convolutionMatrix [[buffer(0)]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half3 bottomColor = texture2D.sample(quadSampler,  inFrag.bottomTextureCoordinate).rgb;
    half3 bottomLeftColor = texture2D.sample(quadSampler,  inFrag.bottomLeftTextureCoordinate).rgb;
    half3 bottomRightColor = texture2D.sample(quadSampler,  inFrag.bottomRightTextureCoordinate).rgb;
    half4 centerColor = texture2D.sample(quadSampler,  inFrag.textureCoordinate);
    half3 leftColor = texture2D.sample(quadSampler,  inFrag.leftTextureCoordinate).rgb;
    half3 rightColor = texture2D.sample(quadSampler,  inFrag.rightTextureCoordinate).rgb;
    half3 topColor = texture2D.sample(quadSampler,  inFrag.topTextureCoordinate).rgb;
    half3 topRightColor = texture2D.sample(quadSampler,  inFrag.topRightTextureCoordinate).rgb;
    half3 topLeftColor = texture2D.sample(quadSampler,  inFrag.topLeftTextureCoordinate).rgb;
    
    half3 resultColor = topLeftColor * convolutionMatrix.v0[0] + topColor * convolutionMatrix.v0[1] + topRightColor * convolutionMatrix.v0[2];
    resultColor += leftColor * convolutionMatrix.v1[0] + centerColor.rgb * convolutionMatrix.v1[1] + rightColor * convolutionMatrix.v1[2];
    resultColor += bottomLeftColor * convolutionMatrix.v2[0] + bottomColor * convolutionMatrix.v2[1] + bottomRightColor * convolutionMatrix.v2[2];
    
    // Normalize the results to allow for negative gradients in the 0.0-1.0 colorspace
    resultColor = resultColor + 0.5;
    
    return half4(resultColor, centerColor.a);
}


