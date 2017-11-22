//
//  MetalImageTransformFilter.metal
//  MetalImage
//
//  Created by fengshi on 2017/10/14.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "../Metal/CommonStruct.metal"
using namespace metal;

typedef struct {
    float4x4 transformMatrix;
    float4x4 orthographicMatrix;
}TransformParameters;

vertex VertexIO vertex_transform(constant float4         *pPosition        [[ buffer(0) ]],
                                 constant packed_float2  *pTexCoords       [[ buffer(1) ]],
                                 constant TransformParameters &parameters  [[ buffer(2) ]],
                                 uint                     vid              [[ vertex_id ]])
{
    VertexIO outVertices;
    outVertices.position = parameters.transformMatrix * float4(pPosition[vid].xyz, 1.0) * parameters.orthographicMatrix;
    outVertices.textureCoordinate = pTexCoords[vid];
    
    return outVertices;
}




