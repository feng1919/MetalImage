//
//  MetalImageDirectionalSobelEdgeDetectionFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

fragment half4 fragment_DirectionalSobelEdgeDetectionFilter(VertexIONearbyTexelSampling         inFrag  [[ stage_in ]],
                                                            texture2d<half>                   texture2D  [[ texture(0) ]])
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
    
    half2 gradientDirection;
    gradientDirection.x = -bottomLeftIntensity - 2.0h * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0h * rightIntensity + topRightIntensity;
    gradientDirection.y = -topLeftIntensity - 2.0h * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0h * bottomIntensity + bottomRightIntensity;
    
    half gradientMagnitude = length(gradientDirection);
    half2 normalizedDirection = normalize(gradientDirection);
    normalizedDirection = sign(normalizedDirection) * floor(abs(normalizedDirection) + 0.617316h); // Offset by 1-sin(pi/8) to set to 0 if near axis, 1 if away
    normalizedDirection = (normalizedDirection + 1.0h) * 0.5h; // Place -1.0 - 1.0 within 0 - 1.0
    
    return half4(gradientMagnitude, normalizedDirection.x, normalizedDirection.y, 1.0h);
}



