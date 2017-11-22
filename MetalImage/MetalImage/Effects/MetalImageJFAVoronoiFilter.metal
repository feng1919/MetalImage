//
//  MetalImageJFAVoronoiFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

//  adapted from unitzeroone - http://unitzeroone.com/labs/jfavoronoi/
//  The shaders are mostly taken from UnitZeroOne's WebGL example here:
//  http://unitzeroone.com/blog/2011/03/22/jump-flood-voronoi-for-webgl/

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

vertex VertexIONearbyTexelSampling vertex_JFAVoronoiFilter(constant float4       *pPosition[[ buffer(0) ]],
                                                           constant packed_float2  *pTexCoords[[ buffer(1) ]],
                                                           constant float          &sampleStep[[ buffer(2) ]],
                                                           uint                     vid[[ vertex_id ]])
{
    float2 widthStep = float2(sampleStep, 0.0);
    float2 heightStep = float2(0.0, sampleStep);
    float2 widthHeightStep = float2(sampleStep);
    float2 widthNegativeHeightStep = float2(sampleStep, -sampleStep);
    
    VertexIONearbyTexelSampling outVertices;
    
    outVertices.position =  pPosition[vid];
    float2 inputTextureCoordinate = pTexCoords[vid];
    outVertices.textureCoordinate = inputTextureCoordinate;
    outVertices.leftTextureCoordinate = inputTextureCoordinate.xy - widthStep;
    outVertices.rightTextureCoordinate = inputTextureCoordinate.xy + widthStep;
    
    outVertices.topTextureCoordinate = inputTextureCoordinate.xy - heightStep;
    outVertices.topLeftTextureCoordinate = inputTextureCoordinate.xy - widthHeightStep;
    outVertices.topRightTextureCoordinate = inputTextureCoordinate.xy + widthNegativeHeightStep;
    
    outVertices.bottomTextureCoordinate = inputTextureCoordinate.xy + heightStep;
    outVertices.bottomLeftTextureCoordinate = inputTextureCoordinate.xy - widthNegativeHeightStep;
    outVertices.bottomRightTextureCoordinate = inputTextureCoordinate.xy + widthHeightStep;
    
    return outVertices;
}

float2 getCoordFromColor(float4 color, float2 size)
{
    float z = color.z * 256.0;
    float yoff = floor(z / 8.0);
    float xoff = fmod(z, 8.0);
    float x = color.x*256.0 + xoff*256.0;
    float y = color.y*256.0 + yoff*256.0;
    return float2(x,y) / size;
}

fragment half4 fragment_JFAVoronoiFilter(VertexIONearbyTexelSampling inFrag  [[ stage_in ]],
                                         texture2d<float>       tex2D   [[ texture(0) ]],
                                         constant packed_float2 &size  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float2 sub;
    float4 dst;
    float4 local = tex2D.sample(quadSampler, inFrag.textureCoordinate);
    float4 sam;
    float l;
    float smallestDist;
    if(local.a == 0.0){
        smallestDist = 1.0;
    }else{
        sub = getCoordFromColor(local, size)-inFrag.textureCoordinate;
        smallestDist = dot(sub,sub);
    }
    dst = local;
    
    sam = tex2D.sample(quadSampler, inFrag.topRightTextureCoordinate);
    if(sam.a == 1.0){
        sub = (getCoordFromColor(sam, size)-inFrag.textureCoordinate);
        l = dot(sub,sub);
        if(l < smallestDist){
            smallestDist = l;
            dst = sam;
        }
    }
    
    sam = tex2D.sample(quadSampler, inFrag.topTextureCoordinate);
    if(sam.a == 1.0){
        sub = (getCoordFromColor(sam, size)-inFrag.textureCoordinate);
        l = dot(sub,sub);
        if(l < smallestDist){
            smallestDist = l;
            dst = sam;
        }
    }
    
    sam = tex2D.sample(quadSampler, inFrag.topLeftTextureCoordinate);
    if(sam.a == 1.0){
        sub = (getCoordFromColor(sam, size)-inFrag.textureCoordinate);
        l = dot(sub,sub);
        if(l < smallestDist){
            smallestDist = l;
            dst = sam;
        }
    }
    
    sam = tex2D.sample(quadSampler, inFrag.bottomRightTextureCoordinate);
    if(sam.a == 1.0){
        sub = (getCoordFromColor(sam, size)-inFrag.textureCoordinate);
        l = dot(sub,sub);
        if(l < smallestDist){
            smallestDist = l;
            dst = sam;
        }
    }
    
    sam = tex2D.sample(quadSampler, inFrag.bottomTextureCoordinate);
    if(sam.a == 1.0){
        sub = (getCoordFromColor(sam, size)-inFrag.textureCoordinate);
        l = dot(sub,sub);
        if(l < smallestDist){
            smallestDist = l;
            dst = sam;
        }
    }
    
    sam = tex2D.sample(quadSampler, inFrag.bottomLeftTextureCoordinate);
    if(sam.a == 1.0){
        sub = (getCoordFromColor(sam, size)-inFrag.textureCoordinate);
        l = dot(sub,sub);
        if(l < smallestDist){
            smallestDist = l;
            dst = sam;
        }
    }
    
    sam = tex2D.sample(quadSampler, inFrag.leftTextureCoordinate);
    if(sam.a == 1.0){
        sub = (getCoordFromColor(sam, size)-inFrag.textureCoordinate);
        l = dot(sub,sub);
        if(l < smallestDist){
            smallestDist = l;
            dst = sam;
        }
    }
    
    sam = tex2D.sample(quadSampler, inFrag.rightTextureCoordinate);
    if(sam.a == 1.0){
        sub = (getCoordFromColor(sam, size)-inFrag.textureCoordinate);
        l = dot(sub,sub);
        if(l < smallestDist){
            smallestDist = l;
            dst = sam;
        }
    }
    return half4(dst);
    
}

fragment half4 fragment_VoronoiConsumerFilter(VertexIO         inFrag  [[ stage_in ]],
                                              texture2d<half>  texture1   [[ texture(0) ]],
                                              texture2d<float>  texture2   [[ texture(1) ]],
                                              constant packed_float2 &size  [[ buffer(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    float4 colorLoc = texture2.sample(quadSampler, inFrag.textureCoordinate);
    return texture1.sample(quadSampler, getCoordFromColor(colorLoc, size));
}

