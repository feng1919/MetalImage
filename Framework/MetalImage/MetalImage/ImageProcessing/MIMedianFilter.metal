//
//  MIMedianFilter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/18.
//  Copyright © 2017年 fengshi. All rights reserved.
//

/*
 3x3 median filter, adapted from "A Fast, Small-Radius GPU Median Filter" by Morgan McGuire in ShaderX6
 http://graphics.cs.williams.edu/papers/MedianShaderX6/
 
 Morgan McGuire and Kyle Whitson
 Williams College
 
 Register allocation tips by Victor Huang Xiaohuang
 University of Illinois at Urbana-Champaign
 
 http://graphics.cs.williams.edu
 
 
 Copyright (c) Morgan McGuire and Williams College, 2006
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "../Metal/CommonStruct.metal"
#include <metal_stdlib>
#include <metal_math>

using namespace metal;

fragment half4 fragment_MedianFilter(VertexIONearbyTexelSampling         inFrag  [[ stage_in ]],
                                     texture2d<half>                   texture2D  [[ texture(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
#define s2(a, b)                temp = a; a = min(a, b); b = max(temp, b);
#define mn3(a, b, c)            s2(a, b); s2(a, c);
#define mx3(a, b, c)            s2(b, c); s2(a, c);
    
#define mnmx3(a, b, c)            mx3(a, b, c); s2(a, b);                                   // 3 exchanges
#define mnmx4(a, b, c, d)        s2(a, b); s2(c, d); s2(a, c); s2(b, d);                   // 4 exchanges
#define mnmx5(a, b, c, d, e)    s2(a, b); s2(c, d); mn3(a, c, e); mx3(b, d, e);           // 6 exchanges
#define mnmx6(a, b, c, d, e, f) s2(a, d); s2(b, e); s2(c, f); mn3(a, b, c); mx3(d, e, f); // 7 exchanges
    
    half3 v0,v1,v2,v3,v4,v5;
    
    v0 = texture2D.sample(quadSampler, inFrag.bottomLeftTextureCoordinate).rgb;
    v1 = texture2D.sample(quadSampler, inFrag.topRightTextureCoordinate).rgb;
    v2 = texture2D.sample(quadSampler, inFrag.topLeftTextureCoordinate).rgb;
    v3 = texture2D.sample(quadSampler, inFrag.bottomRightTextureCoordinate).rgb;
    v4 = texture2D.sample(quadSampler, inFrag.leftTextureCoordinate).rgb;
    v5 = texture2D.sample(quadSampler, inFrag.rightTextureCoordinate).rgb;
    //     v[6] = texture2D.sample(quadSampler, inFrag.bottomTextureCoordinate).rgb;
    //     v[7] = texture2D.sample(quadSampler, inFrag.topTextureCoordinate).rgb;
    half3 temp;
    
    mnmx6(v0, v1, v2, v3, v4, v5);
    
    v5 = texture2D.sample(quadSampler, inFrag.bottomTextureCoordinate).rgb;
    
    mnmx5(v1, v2, v3, v4, v5);
    
    v5 = texture2D.sample(quadSampler, inFrag.topTextureCoordinate).rgb;
    
    mnmx4(v2, v3, v4, v5);
    
    v5 = texture2D.sample(quadSampler, inFrag.textureCoordinate).rgb;
    
    mnmx3(v3, v4, v5);
    
    return half4(v4, 1.0h);
}
