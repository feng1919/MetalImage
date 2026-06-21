//
//  MIXYDerivativeFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

fragment half4 fragment_MIXYDerivativeFilter(VertexIONearbyTexelSampling         inFrag  [[ stage_in ]],
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
    
    
    float verticalDerivative = -topLeftIntensity - topIntensity - topRightIntensity + bottomLeftIntensity + bottomIntensity + bottomRightIntensity;
    float horizontalDerivative = -bottomLeftIntensity - leftIntensity - topLeftIntensity + bottomRightIntensity + rightIntensity + topRightIntensity;
    verticalDerivative = verticalDerivative * edgeStrength;
    horizontalDerivative = horizontalDerivative * edgeStrength;
    
    // Scaling the X * Y operation so that negative numbers are not clipped in the 0..1 range.
    // This will be expanded in the corner detection filter
    return half4(horizontalDerivative * horizontalDerivative, verticalDerivative * verticalDerivative,
                 ((verticalDerivative * horizontalDerivative) + 1.0h) / 2.0h, 1.0h);
}



