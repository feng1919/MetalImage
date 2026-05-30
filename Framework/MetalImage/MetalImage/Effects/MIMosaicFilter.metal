//
//  MIMosaicFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    packed_float2 inputTileSize;
    packed_float2 displayTileSize;
    float numTiles;
    float colorOn;
}MosaicParameters;

fragment half4 fragment_MosaicFilter(VertexIO         inFrag  [[ stage_in ]],
                                     texture2d<half>  texture1   [[ texture(0) ]],
                                     texture2d<half>  texture2   [[ texture(1) ]],
                                     constant MosaicParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 xy = inFrag.textureCoordinate;
    xy = xy - fmod(xy, (float2)parameters.displayTileSize);
    
    half4 lumcoeff = half4(0.299h, 0.587h, 0.114h, 0.0h);
    
    half4 inputColor = texture2.sample(quadSampler, xy);
    half lum = dot(inputColor, lumcoeff);
    lum = 1.0 - lum;
    
    half stepsize = 1.0 / parameters.numTiles;
    float lumStep = (lum - fmod(lum, stepsize)) / stepsize;
    
    float2 inputTileSize = parameters.inputTileSize;
    float rowStep = 1.0 / inputTileSize.x;
    float x = fmod(lumStep, rowStep);
    float y = floor(lumStep / rowStep);
    
    float2 startCoord = float2(float(x) * inputTileSize.x, float(y) * inputTileSize.y);
    float2 finalCoord = startCoord + ((inFrag.textureCoordinate - xy) * (parameters.inputTileSize / parameters.displayTileSize));
    
    half4 color = texture1.sample(quadSampler, finalCoord);
    if (parameters.colorOn > 0.5) {
        color = color * inputColor;
    }
    return color;
}



