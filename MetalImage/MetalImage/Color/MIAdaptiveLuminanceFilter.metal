//
//  MIAdaptiveLuminanceFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2021/2/19.
//  Copyright © 2021 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    float k;
    float b;
}LineParameters;

fragment half4 fragment_adaptiveLuminance(VertexIO         inFrag  [[ stage_in ]],
                                          texture2d<float>  tex2D   [[ texture(0) ]],
                                          constant LineParameters &linePara  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    const float3 luminanceWeight = float3(0.2627f, 0.6780f, 0.0593f);
    
    const float3 uWeight = float3(-0.1396f, -0.3604f, 0.5f);
    const float3 vWeight = float3(0.5f, -0.4598f, -0.0402f);
    float4 source = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    float luminance = dot(source.rgb, luminanceWeight);
    float u = dot(source.rgb, uWeight);
    float v = dot(source.rgb, vWeight);
    luminance = clamp(luminance * linePara.k + linePara.b, 0.0f, 1.0f);
    
    float3 result = float3(luminance, u, v);
    
    const float3x3 kColorConversion601FullRangeDefault = {
        {1.0,    1.0,    1.0},
        {0.0,    -0.343, 1.765},
        {1.4,    -0.711, 0.0},
    };
    
    return half4(half3(kColorConversion601FullRangeDefault * result), 1.0h);
}



