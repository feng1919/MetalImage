//
//  MILookupFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/8/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_lookup(VertexIO         inFrag  [[ stage_in ]],
                               texture2d<half>  texture1   [[ texture(0) ]],
                               texture2d<half>  texture2   [[ texture(1) ]],
                               constant float &intensity  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 textureColor = texture1.sample(quadSampler, inFrag.textureCoordinate);
    float blueColor = textureColor.b * 63.0;
    
    float2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0);
    quad1.x = floor(blueColor) - (quad1.y * 8.0);
    
    float2 quad2;
    quad2.y = floor(ceil(blueColor) / 8.0);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0);
    
    float2 texPos1;
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
    
    float2 texPos2;
    texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
    texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
    
    half4 newColor1 = texture2.sample(quadSampler, texPos1);
    half4 newColor2 = texture2.sample(quadSampler, texPos2);
    
    half4 newColor = mix(newColor1, newColor2, half(fract(blueColor)));
    
    return mix(textureColor, half4(newColor.rgb, textureColor.w), half(intensity));
}


