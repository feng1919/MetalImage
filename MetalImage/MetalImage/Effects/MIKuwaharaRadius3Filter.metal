//
//  MIKuwaharaRadius3Filter.metal
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

// Sourced from Kyprianidis, J. E., Kang, H., and Doellner, J. "Anisotropic Kuwahara Filtering on the GPU," GPU Pro p.247 (2010).
//
// Original header:
//
// Anisotropic Kuwahara Filtering on the GPU
// by Jan Eric Kyprianidis <www.kyprianidis.com>

#include "../Metal/CommonStruct.metal"
using namespace metal;

fragment half4 fragment_KuwaharaRadius3Filter(VertexIOWithSteps inFrag  [[ stage_in ]],
                                              texture2d<half>   tex2D   [[ texture(0) ]])
{
    constexpr sampler quadSampler(coord::normalized, filter::linear, address::clamp_to_edge);
    
    const float2 src_size = inFrag.texelSteps;
    
    float2 uv = inFrag.textureCoordinate;
    float n = float(16); // radius is assumed to be 3
    half3 m0 = half3(0.0); half3 m1 = half3(0.0); half3 m2 = half3(0.0); half3 m3 = half3(0.0);
    half3 s0 = half3(0.0); half3 s1 = half3(0.0); half3 s2 = half3(0.0); half3 s3 = half3(0.0);
    half3 c, cSq;
    
    c = tex2D.sample(quadSampler, uv + float2(-3,-3) * src_size).rgb;
    m0 += c;
    s0 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-3,-2) * src_size).rgb;
    m0 += c;
    s0 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-3,-1) * src_size).rgb;
    m0 += c;
    s0 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-3,0) * src_size).rgb;
    cSq = c * c;
    m0 += c;
    s0 += cSq;
    m1 += c;
    s1 += cSq;
    
    c = tex2D.sample(quadSampler, uv + float2(-2,-3) * src_size).rgb;
    m0 += c;
    s0 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-2,-2) * src_size).rgb;
    m0 += c;
    s0 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-2,-1) * src_size).rgb;
    m0 += c;
    s0 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-2,0) * src_size).rgb;
    cSq = c * c;
    m0 += c;
    s0 += cSq;
    m1 += c;
    s1 += cSq;
    
    c = tex2D.sample(quadSampler, uv + float2(-1,-3) * src_size).rgb;
    m0 += c;
    s0 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-1,-2) * src_size).rgb;
    m0 += c;
    s0 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-1,-1) * src_size).rgb;
    m0 += c;
    s0 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-1,0) * src_size).rgb;
    cSq = c * c;
    m0 += c;
    s0 += cSq;
    m1 += c;
    s1 += cSq;
    
    c = tex2D.sample(quadSampler, uv + float2(0,-3) * src_size).rgb;
    cSq = c * c;
    m0 += c;
    s0 += cSq;
    m3 += c;
    s3 += cSq;
    c = tex2D.sample(quadSampler, uv + float2(0,-2) * src_size).rgb;
    cSq = c * c;
    m0 += c;
    s0 += cSq;
    m3 += c;
    s3 += cSq;
    c = tex2D.sample(quadSampler, uv + float2(0,-1) * src_size).rgb;
    cSq = c * c;
    m0 += c;
    s0 += cSq;
    m3 += c;
    s3 += cSq;
    c = tex2D.sample(quadSampler, uv + float2(0,0) * src_size).rgb;
    cSq = c * c;
    m0 += c;
    s0 += cSq;
    m1 += c;
    s1 += cSq;
    m2 += c;
    s2 += cSq;
    m3 += c;
    s3 += cSq;
    
    c = tex2D.sample(quadSampler, uv + float2(-3,3) * src_size).rgb;
    m1 += c;
    s1 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-3,2) * src_size).rgb;
    m1 += c;
    s1 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-3,1) * src_size).rgb;
    m1 += c;
    s1 += c * c;
    
    c = tex2D.sample(quadSampler, uv + float2(-2,3) * src_size).rgb;
    m1 += c;
    s1 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-2,2) * src_size).rgb;
    m1 += c;
    s1 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-2,1) * src_size).rgb;
    m1 += c;
    s1 += c * c;
    
    c = tex2D.sample(quadSampler, uv + float2(-1,3) * src_size).rgb;
    m1 += c;
    s1 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-1,2) * src_size).rgb;
    m1 += c;
    s1 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(-1,1) * src_size).rgb;
    m1 += c;
    s1 += c * c;
    
    c = tex2D.sample(quadSampler, uv + float2(0,3) * src_size).rgb;
    cSq = c * c;
    m1 += c;
    s1 += cSq;
    m2 += c;
    s2 += cSq;
    c = tex2D.sample(quadSampler, uv + float2(0,2) * src_size).rgb;
    cSq = c * c;
    m1 += c;
    s1 += cSq;
    m2 += c;
    s2 += cSq;
    c = tex2D.sample(quadSampler, uv + float2(0,1) * src_size).rgb;
    cSq = c * c;
    m1 += c;
    s1 += cSq;
    m2 += c;
    s2 += cSq;
    
    c = tex2D.sample(quadSampler, uv + float2(3,3) * src_size).rgb;
    m2 += c;
    s2 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(3,2) * src_size).rgb;
    m2 += c;
    s2 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(3,1) * src_size).rgb;
    m2 += c;
    s2 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(3,0) * src_size).rgb;
    cSq = c * c;
    m2 += c;
    s2 += cSq;
    m3 += c;
    s3 += cSq;
    
    c = tex2D.sample(quadSampler, uv + float2(2,3) * src_size).rgb;
    m2 += c;
    s2 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(2,2) * src_size).rgb;
    m2 += c;
    s2 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(2,1) * src_size).rgb;
    m2 += c;
    s2 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(2,0) * src_size).rgb;
    cSq = c * c;
    m2 += c;
    s2 += cSq;
    m3 += c;
    s3 += cSq;
    
    c = tex2D.sample(quadSampler, uv + float2(1,3) * src_size).rgb;
    m2 += c;
    s2 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(1,2) * src_size).rgb;
    m2 += c;
    s2 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(1,1) * src_size).rgb;
    m2 += c;
    s2 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(1,0) * src_size).rgb;
    cSq = c * c;
    m2 += c;
    s2 += cSq;
    m3 += c;
    s3 += cSq;
    
    c = tex2D.sample(quadSampler, uv + float2(3,-3) * src_size).rgb;
    m3 += c;
    s3 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(3,-2) * src_size).rgb;
    m3 += c;
    s3 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(3,-1) * src_size).rgb;
    m3 += c;
    s3 += c * c;
    
    c = tex2D.sample(quadSampler, uv + float2(2,-3) * src_size).rgb;
    m3 += c;
    s3 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(2,-2) * src_size).rgb;
    m3 += c;
    s3 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(2,-1) * src_size).rgb;
    m3 += c;
    s3 += c * c;
    
    c = tex2D.sample(quadSampler, uv + float2(1,-3) * src_size).rgb;
    m3 += c;
    s3 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(1,-2) * src_size).rgb;
    m3 += c;
    s3 += c * c;
    c = tex2D.sample(quadSampler, uv + float2(1,-1) * src_size).rgb;
    m3 += c;
    s3 += c * c;
    
    half4 resultColor;
    float min_sigma2 = 1e+2;
    m0 /= n;
    s0 = abs(s0 / n - m0 * m0);
    
    float sigma2 = s0.r + s0.g + s0.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        resultColor = half4(m0, 1.0h);
    }
    
    m1 /= n;
    s1 = abs(s1 / n - m1 * m1);
    
    sigma2 = s1.r + s1.g + s1.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        resultColor = half4(m1, 1.0h);
    }
    
    m2 /= n;
    s2 = abs(s2 / n - m2 * m2);
    
    sigma2 = s2.r + s2.g + s2.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        resultColor = half4(m2, 1.0h);
    }
    
    m3 /= n;
    s3 = abs(s3 / n - m3 * m3);
    
    sigma2 = s3.r + s3.g + s3.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        resultColor = half4(m3, 1.0h);
    }
    
    return resultColor;
}


