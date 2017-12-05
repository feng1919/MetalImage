//
//  MIWhiteBalanceFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/7/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    float temperature;
    float tint;
}WhiteBalanceParameters;

fragment half4 fragment_whiteBalance(VertexIO         inFrag  [[ stage_in ]],
                                     texture2d<half>  tex2D   [[ texture(0) ]],
                                     constant WhiteBalanceParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    half4 source = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    const half3 warmFilter = half3(0.93h, 0.54h, 0.0h);
    
    const half3x3 RGBtoYIQ = {{0.299h, 0.587h, 0.114h}, {0.596h, -0.274h, -0.322h}, {0.212h, -0.523h, 0.311h}};
    const half3x3 YIQtoRGB = {{1.0h, 0.956h, 0.621h}, {1.0h, -0.272h, -0.647h}, {1.0h, -1.105h, 1.702h}};
    
    const half3 yiq = RGBtoYIQ * source.rgb; //adjusting tint
    yiq.b = clamp(yiq.b + half(parameters.tint)*0.5226h*0.1h, -0.5226h, 0.5226h);
    half3 rgb = YIQtoRGB * yiq;
    
    half3 processed = half3((rgb.r < 0.5h ? (2.0h * rgb.r * warmFilter.r) : (1.0h - 2.0h * (1.0h - rgb.r) * (1.0h - warmFilter.r))), //adjusting temperature
                            (rgb.g < 0.5h ? (2.0h * rgb.g * warmFilter.g) : (1.0h - 2.0h * (1.0h - rgb.g) * (1.0h - warmFilter.g))),
                            (rgb.b < 0.5h ? (2.0h * rgb.b * warmFilter.b) : (1.0h - 2.0h * (1.0h - rgb.b) * (1.0h - warmFilter.b))));
    
    return half4(mix(rgb, processed, half(parameters.temperature)), source.a);
}


