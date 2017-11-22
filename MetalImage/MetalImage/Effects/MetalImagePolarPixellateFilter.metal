//
//  MetalImagePolarPixellateFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    float2 pixelSize;
    float2 center;
}PolarPixellateParameters;

// @fattjake based on vid by toneburst

fragment half4 fragment_polarPixellate(VertexIO         inFrag  [[ stage_in ]],
                                    texture2d<half>  tex2D   [[ texture(0) ]],
                                    constant PolarPixellateParameters &parameters  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 normCoord = 2.0 * inFrag.textureCoordinate - 1.0;
    float2 normCenter = 2.0 * parameters.center - 1.0;
    
    normCoord -= normCenter;
    
    float r = length(normCoord); // to polar coords
    float phi = atan2(normCoord.y, normCoord.x); // to polar coords
    
    r = r - fmod(r, parameters.pixelSize.x) + 0.03;
    phi = phi - fmod(phi, parameters.pixelSize.y);
    
    normCoord.x = r * cos(phi);
    normCoord.y = r * sin(phi);
    
    normCoord += normCenter;
    
    float2 textureCoordinateToUse = normCoord / 2.0 + 0.5;
    
    return tex2D.sample(quadSampler, textureCoordinateToUse);
    
}
