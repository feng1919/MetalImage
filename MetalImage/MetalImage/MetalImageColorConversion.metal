//
//  MetalImageColorConversion.metal
//  MetalImage
//
//  Created by stonefeng on 2017/3/3.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "Metal/CommonStruct.metal"


constant float3 ColorOffsetFullRange = float3(0.0, -0.5, -0.5);
constant float3 ColorOffsetVideoRange = float3(-0.062745098, -0.5, -0.5);

//fragment half4 yuv_rgb2(VertexOut      inFrag    [[ stage_in ]],
//                       texture2d<float>  lumaTex     [[ texture(0) ]],
//                       texture2d<float>  chromaTex     [[ texture(1) ]],
//                       sampler bilinear [[ sampler(0) ]],
//                       constant ColorParameters *colorParameters [[ buffer(0) ]])
//{
//    float3 yuv;
//    yuv.x = lumaTex.sample(bilinear, inFrag.st).r;
//    yuv.yz = chromaTex.sample(bilinear,inFrag.st).rg - float2(0.5);
//    return half4(half3(colorParameters->yuvToRGB * yuv),yuv.x);
//}


kernel void yuv2rgb_601f(texture2d<float, access::read> y_tex      [[ texture(0) ]],
                         texture2d<float, access::read> uv_tex     [[ texture(1) ]],
                         texture2d<float, access::write> bgr_tex   [[ texture(2) ]],
                         uint2 gid [[thread_position_in_grid]])
{
    
    float3 yuv = float3(y_tex.read(gid).r, uv_tex.read(gid/2).rg) + ColorOffsetFullRange;
    
    const float3x3 kColorConversion601FullRangeDefault = {
        {1.0,    1.0,    1.0},
        {0.0,    -0.343, 1.765},
        {1.4,    -0.711, 0.0},
    };
    
    bgr_tex.write(float4(float3(kColorConversion601FullRangeDefault * yuv), 1.0), gid);
}

kernel void yuv2rgb_601v(texture2d<float, access::read> y_tex      [[ texture(0) ]],
                         texture2d<float, access::read> uv_tex     [[ texture(1) ]],
                         texture2d<float, access::write> bgr_tex   [[ texture(2) ]],
                         uint2 gid [[thread_position_in_grid]])
{
    float3 yuv = float3(y_tex.read(gid).r, uv_tex.read(gid/2).rg) + ColorOffsetVideoRange;
    
    const float3x3 kColorConversion601Default = {
        {1.164,  1.164,  1.164},
        {0.0,    -0.392, 2.017},
        {1.596,  -0.813, 0.0},
    };
    
    bgr_tex.write(float4(float3(kColorConversion601Default * yuv), 1.0), gid);
}

kernel void yuv2rgb_709v(texture2d<float, access::read> y_tex      [[ texture(0) ]],
                         texture2d<float, access::read> uv_tex     [[ texture(1) ]],
                         texture2d<float, access::write> bgr_tex   [[ texture(2) ]],
                         uint2 gid [[thread_position_in_grid]])
{
    float3 yuv = float3(y_tex.read(gid).r, uv_tex.read(gid/2).rg) + ColorOffsetVideoRange;
    
    const float3x3 kColorConversion709Default = {
        {1.164,  1.164,  1.164},
        {0.0,    -0.213, 2.112},
        {1.793,  -0.533, 0.0},
    };
    
    bgr_tex.write(float4(float3(kColorConversion709Default * yuv), 1.0), gid);
}




