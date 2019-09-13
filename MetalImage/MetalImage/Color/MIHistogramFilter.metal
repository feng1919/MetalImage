//
//  MIHistogramFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/11/3.
//  Copyright © 2017年 tencent. All rights reserved.
//

// Unlike other filters, this one uses a grid of GL_POINTs to sample the incoming image in a grid. A custom vertex shader reads the color in the texture at its position
// and outputs a bin position in the final histogram as the vertex position. That point is then written into the image of the histogram using translucent pixels.
// The degree of translucency is controlled by the scalingFactor, which lets you adjust the dynamic range of the histogram. The histogram can only be generated for one
// color channel or luminance value at a time.
//
// This is based on this implementation: http://www.shaderwrangler.com/publications/histogram/histogram_cameraready.pdf
//
// Or at least that's how it would work if iOS could read from textures in a vertex shader, which it can't. Therefore, I read the texture data down from the
// incoming frame and process the texture colors as vertices.


#include <metal_math>
#include <metal_stdlib>

using namespace metal;

struct VertexIO
{
    float4 m_Position  [[position]];
    float  m_pointSize [[point_size]];
    float3 m_colorFactor;
};

vertex VertexIO vertex_redHistogramSampling(constant uchar4         *pPosition[[ buffer(0) ]],
                                            uint                     vid[[ vertex_id ]])
{
    VertexIO outVertices;
    
    outVertices.m_colorFactor = float3(1.0, 0.0, 0.0);
    outVertices.m_Position = float4(-1.0 + (pPosition[vid].x * 0.0078125), 0.0, 0.0, 1.0);
    outVertices.m_pointSize = 1.0;
    
    return outVertices;
}

vertex VertexIO vertex_greenHistogramSampling(constant uchar4         *pPosition[[ buffer(0) ]],
                                              uint                     vid[[ vertex_id ]])
{
    VertexIO outVertices;
    
    outVertices.m_colorFactor = float3(0.0, 1.0, 0.0);
    outVertices.m_Position = float4(-1.0 + (pPosition[vid].y * 0.0078125), 0.0, 0.0, 1.0);
    outVertices.m_pointSize = 1.0;
    
    return outVertices;
}

vertex VertexIO vertex_blueHistogramSampling(constant uchar4         *pPosition[[ buffer(0) ]],
                                             uint                     vid[[ vertex_id ]])
{
    VertexIO outVertices;
    
    outVertices.m_colorFactor = float3(0.0, 0.0, 1.0);
    outVertices.m_Position = float4(-1.0 + (pPosition[vid].z * 0.0078125), 0.0, 0.0, 1.0);
    outVertices.m_pointSize = 1.0;
    
    return outVertices;
}

vertex VertexIO vertex_luminanceHistogramSampling(constant uchar4         *pPosition[[ buffer(0) ]],
                                                  uint                     vid[[ vertex_id ]])
{
    VertexIO outVertices;
    
    const float3 W = float3(0.2125, 0.7154, 0.0721);
    float luminance = dot((float3)pPosition[vid].xyz, W);
    
    outVertices.m_colorFactor = float3(1.0, 1.0, 1.0);
    outVertices.m_Position = float4(-1.0 + (luminance * 0.0078125), 0.0, 0.0, 1.0);
    outVertices.m_pointSize = 1.0;
    
    return outVertices;
}

fragment half4 fragment_histogramAccumulation(VertexIO         inFrag  [[ stage_in ]])
{
    const float scalingFactor = 1.0 / 256.0;
    return half4(half3(inFrag.m_colorFactor * scalingFactor), 1.0h);
}
