//
//  MICrosshatchFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/9/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    float crossHatchSpacing;
    float lineWidth;
}CrosshatchParameters;

fragment half4 fragment_crosshatch(VertexIO         inFrag  [[ stage_in ]],
                                   texture2d<float>  tex2D   [[ texture(0) ]],
                                   constant CrosshatchParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float4 textureColor = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    
    const float3 W = float3(0.2125, 0.7154, 0.0721);
    
    float luminance = dot(textureColor.rgb, W);
    float crossHatchSpacing = parameters.crossHatchSpacing;
    float lineWidth = parameters.lineWidth;
    
    float2 textureCoordinate = inFrag.textureCoordinate;
    
    half4 colorToDisplay = half4(1.0);
    if (luminance < 1.00)
    {
        if (fmod(textureCoordinate.x + textureCoordinate.y, crossHatchSpacing) <= lineWidth)
        {
            colorToDisplay = half4(0.0h, 0.0h, 0.0h, 1.0h);
        }
    }
    if (luminance < 0.75)
    {
        if (fmod(textureCoordinate.x - textureCoordinate.y, crossHatchSpacing) <= lineWidth)
        {
            colorToDisplay = half4(0.0h, 0.0h, 0.0h, 1.0h);
        }
    }
    if (luminance < 0.50)
    {
        if (fmod(textureCoordinate.x + textureCoordinate.y - (crossHatchSpacing / 2.0), crossHatchSpacing) <= lineWidth)
        {
            colorToDisplay = half4(0.0h, 0.0h, 0.0h, 1.0h);
        }
    }
    if (luminance < 0.3)
    {
        if (fmod(textureCoordinate.x - textureCoordinate.y - (crossHatchSpacing / 2.0), crossHatchSpacing) <= lineWidth)
        {
            colorToDisplay = half4(0.0h, 0.0h, 0.0h, 1.0h);
        }
    }
    
    return colorToDisplay;
    
}
