//
//  MetalImageCGAColorspaceFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_cgaColorspace(VertexIO         inFrag  [[ stage_in ]],
                                      texture2d<half>  tex2D   [[ texture(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 sampleDivisor = float2(1.0 / 200.0, 1.0 / 320.0);
    //highp vec4 colorDivisor = vec4(colorDepth);
    
    float2 samplePos = inFrag.textureCoordinate - fmod(inFrag.textureCoordinate, sampleDivisor);
    half4 color = tex2D.sample(quadSampler, samplePos);
    
    half4 colorCyan = half4(85.0 / 255.0, 1.0, 1.0, 1.0);
    half4 colorMagenta = half4(1.0, 85.0 / 255.0, 1.0, 1.0);
    half4 colorWhite = half4(1.0, 1.0, 1.0, 1.0);
    half4 colorBlack = half4(0.0, 0.0, 0.0, 1.0);
    
    float blackDistance = distance(color, colorBlack);
    float whiteDistance = distance(color, colorWhite);
    float magentaDistance = distance(color, colorMagenta);
    float cyanDistance = distance(color, colorCyan);
    
    half4 finalColor;
    
    float colorDistance = min(magentaDistance, cyanDistance);
    colorDistance = min(colorDistance, whiteDistance);
    colorDistance = min(colorDistance, blackDistance);
    
    if (colorDistance == blackDistance) {
        finalColor = colorBlack;
    } else if (colorDistance == whiteDistance) {
        finalColor = colorWhite;
    } else if (colorDistance == cyanDistance) {
        finalColor = colorCyan;
    } else {
        finalColor = colorMagenta;
    }
    
    return finalColor;
}
