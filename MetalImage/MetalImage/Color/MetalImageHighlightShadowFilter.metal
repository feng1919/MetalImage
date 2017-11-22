//
//  MetalImageHighlightShadowFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/7/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    float shadows;
    float highlights;
}HighlightShadowParameters;

fragment half4 fragment_highlightShadow(VertexIO         inFrag  [[ stage_in ]],
                                        texture2d<half>  tex2D   [[ texture(0) ]],
                                        constant HighlightShadowParameters &highlightShadow  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    const half3 luminanceWeighting = half3(0.3h, 0.3h, 0.3h);
    half4 source = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    half luminance = dot(source.rgb, luminanceWeighting);
    float shadows = highlightShadow.shadows;
    float shadow = clamp((pow(float(luminance), 1.0/(shadows+1.0)) + (-0.76)*pow(float(luminance), 2.0/(shadows+1.0))) - luminance, 0.0, 1.0);
    float highlights = highlightShadow.highlights;
    float highlight = clamp((1.0 - (pow(1.0-luminance, 1.0/(2.0-highlights)) + (-0.8)*pow(1.0-luminance, 2.0/(2.0-highlights)))) - luminance, -1.0, 0.0);
    half3 result = half3(0.0) + ((luminance + shadow + highlight) - 0.0) * ((source.rgb - half3(0.0))/(luminance - 0.0));
    
    return half4(result, source.a);
}

