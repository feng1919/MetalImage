//
//  Convolution.metal
//  MetalImage
//
//  Created by Feng Stone on 2019/5/11.
//  Copyright © 2019 fengshi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//typedef struct {
//    packed_float3 v0;
//    packed_float3 v1;
//    packed_float3 v2;
//}Convolution3x3Kernel;

typedef struct {
    int row;
    int column;
    int depth;
}ImageSize;

// VGG Convolution
// stride = 1, kernel = 3x3
// Input matrix data layout: [column][row][depth]
// Input kernel data layout: [column][row][depth][featureCount]
// Output matrix data layout: [column][row][featureCount]
kernel void Convolution3x3(constant float *hwchBuffer                       [[buffer(0)]],
                           constant ImageSize &imageSize                    [[buffer(1)]],
                           constant float *convWeight                       [[buffer(2)]],
                           constant float *convBias                         [[buffer(3)]],
                           constant int &numOfFeature                       [[buffer(4)]],
                           device float *outputBuffer                       [[buffer(5)]],
                           uint2 gid                                        [[thread_position_in_grid ]])
{
    const int x = gid.x;
    const int y = gid.y;
    int index = y*imageSize.column+x;
    
//    for (int k = 0; k < numOfFeature; k++) {
//        float sum = 0.0f;
//        int ik_feature_offset = 3*3*imageSize.depth*k;
//        for (int d = 0; d < imageSize.depth; d++) {
//            int im_depth_offset = imageSize.column*imageSize.row*d;
//            int ik_depth_offset = ik_feature_offset+3*3*d;
//            for (int i = -1; i < 2; i++) {
//                if (y+i<0 || y+i>=imageSize.row) {
//                    continue;
//                }
//                int im_row_offset = im_depth_offset+imageSize.column*(y+i);
//                int ik_row_offset = ik_depth_offset+3*(i+1);
//                for (int j = -1; j < 2; j++) {
//                    if (x+j<0 || x+j>=imageSize.column) {
//                        continue;
//                    }
//                    sum += hwchBuffer[im_row_offset+x+j] * convWeight[ik_row_offset+j+1];
//                }
//            }
//        }
//        outputBuffer[index*numOfFeature+k] = sum+convBias[k];
//    }
    
    for (int k = 0; k < numOfFeature; k++) {
        float sum = 0.0f;
        for (int i = -1; i < 2; i++) {
            if (y+i<0 || y+i>=imageSize.row) {
                continue;
            }
            for (int j = -1; j < 2; j++) {
                if (x+j<0 || x+j>=imageSize.column) {
                    continue;
                }
                int index1 = (index+i*imageSize.column+j)*imageSize.depth;//((y+i)*imageSize.column+x+j)*imageSize.depth;
                for (int d = 0; d < imageSize.depth; d++) {
                    float coh = convWeight[(((i+1)*3+j+1)*imageSize.depth+d)*numOfFeature+k];
                    sum += coh * hwchBuffer[index1+d];
                }
            }
        }
        outputBuffer[index*numOfFeature+k] = sum+convBias[k];
    }
}

kernel void PoolingMax2x2(device float *outputBuffer [[buffer(0)]],
                          constant float *hwchBuffer [[buffer(1)]],
                          constant ImageSize &outImageSize [[buffer(2)]],
                          uint2 gid [[thread_position_in_grid]])
{
    const int col = gid.x;
    const int row = gid.y;
    
    int index = (row*outImageSize.column+col)*outImageSize.depth;
    
    int p0 = index<<1;
    int p1 = p0+outImageSize.depth;
    int p2 = ((row+1)*outImageSize.column+col)*outImageSize.depth<<1;
    int p3 = p2+outImageSize.depth;
    
    for (int d=0;d<outImageSize.depth;d++) {
        float v0 = hwchBuffer[p0+d];
        float v1 = hwchBuffer[p1+d];
        float v2 = hwchBuffer[p2+d];
        float v3 = hwchBuffer[p3+d];
        outputBuffer[index+d] = max(max(max(v0, v1), v2), v3);
    }
}

kernel void ActivationReLu(constant float *inputBuffer [[buffer(0)]],
                           device float *outputBuffer  [[buffer(1)]],
                           constant ImageSize &imageSize [[buffer(2)]],
                           uint2 gid [[thread_position_in_grid]])
{
    int index = (gid.y*imageSize.column+gid.x)*imageSize.depth;
    for (int d=0;d<imageSize.depth;d++) {
        float v = inputBuffer[index+d];
        outputBuffer[index+d] = v>0.0f?:0.0f;
    }
}
