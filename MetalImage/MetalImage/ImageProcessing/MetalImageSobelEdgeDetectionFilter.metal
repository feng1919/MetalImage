//
//  MetalImageSobelEdgeDetectionFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

fragment half4 fragment_SobelEdgeDetectionFilter(VertexIONearbyTexelSampling         inFrag  [[ stage_in ]],
                                                 texture2d<half>                   texture2D  [[ texture(0) ]],
                                                 constant float                  &edgeStrength [[buffer(0)]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half bottomLeftIntensity = texture2D.sample(quadSampler,  inFrag.bottomLeftTextureCoordinate).r;
    half topRightIntensity = texture2D.sample(quadSampler,  inFrag.topRightTextureCoordinate).r;
    half topLeftIntensity = texture2D.sample(quadSampler,  inFrag.topLeftTextureCoordinate).r;
    half bottomRightIntensity = texture2D.sample(quadSampler,  inFrag.bottomRightTextureCoordinate).r;
    half leftIntensity = texture2D.sample(quadSampler,  inFrag.leftTextureCoordinate).r;
    half rightIntensity = texture2D.sample(quadSampler,  inFrag.rightTextureCoordinate).r;
    half bottomIntensity = texture2D.sample(quadSampler,  inFrag.bottomTextureCoordinate).r;
    half topIntensity = texture2D.sample(quadSampler,  inFrag.topTextureCoordinate).r;
    half h = -topLeftIntensity - 2.0h * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0h * bottomIntensity + bottomRightIntensity;
    half v = -bottomLeftIntensity - 2.0h * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0h * rightIntensity + topRightIntensity;
    
    half mag = length(half2(h, v)) * half(edgeStrength);
    
    return half4(half3(mag), 1.0h);
}

typedef struct {
    float edgeStrength;
    float threshold;
}ThresholdEdgeDetectionParameters;

fragment half4 fragment_ThresholdEdgeDetectionFilter(VertexIONearbyTexelSampling         inFrag  [[ stage_in ]],
                                                     texture2d<half>                   texture2D  [[ texture(0) ]],
                                                     constant ThresholdEdgeDetectionParameters &parameters [[buffer(0)]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
//    half bottomLeftIntensity = texture2D.sample(quadSampler,  inFrag.bottomLeftTextureCoordinate).r;
//    half topRightIntensity = texture2D.sample(quadSampler,  inFrag.topRightTextureCoordinate).r;
//    half topLeftIntensity = texture2D.sample(quadSampler,  inFrag.topLeftTextureCoordinate).r;
//    half bottomRightIntensity = texture2D.sample(quadSampler,  inFrag.bottomRightTextureCoordinate).r;
    half leftIntensity = texture2D.sample(quadSampler,  inFrag.leftTextureCoordinate).r;
    half rightIntensity = texture2D.sample(quadSampler,  inFrag.rightTextureCoordinate).r;
    half bottomIntensity = texture2D.sample(quadSampler,  inFrag.bottomTextureCoordinate).r;
    half topIntensity = texture2D.sample(quadSampler,  inFrag.topTextureCoordinate).r;
    half centerIntensity = texture2D.sample(quadSampler,  inFrag.textureCoordinate).r;
    
    half h = (centerIntensity - topIntensity) + (bottomIntensity - centerIntensity);
    half v = (centerIntensity - leftIntensity) + (rightIntensity - centerIntensity);
    
    half mag = length(half2(h, v)) * half(parameters.edgeStrength);
    mag = step(half(parameters.threshold), mag);
    
    return half4(half3(mag), 1.0h);
}
