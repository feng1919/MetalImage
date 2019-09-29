//
//  MetalImageTypes.h
//  MetalImage
//
//  Created by stonefeng on 2017/2/11.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#ifndef __MetalImageTypes__
#define __MetalImageTypes__
#include <stdbool.h>
#include <assert.h>

typedef float MTLFloat;
typedef int MTLInt;
typedef unsigned int MTLUInt;
typedef bool MTLBool;

typedef struct {
    float x;
    float y;
}MTLRenderingPoint;

MTLRenderingPoint MTLRenderingPointMake(float x, float y);

typedef struct {
    MTLRenderingPoint lowerLeft;
    MTLRenderingPoint lowerRight;
    MTLRenderingPoint upperRight;
    MTLRenderingPoint upperLeft;
}MTLRenderingCoordinate;

MTLRenderingCoordinate MTLRenderingCoordinateMake(MTLRenderingPoint lowerLeft, MTLRenderingPoint lowerRight, MTLRenderingPoint upperRight, MTLRenderingPoint upperLeft);

struct MTLFloat2 {MTLFloat x,y;};
typedef struct MTLFloat2 MTLFloat2;
MTLFloat2 MTLFloat2Make(MTLFloat x, MTLFloat y);

typedef struct MTLFloat2 MTLPoint;
MTLPoint MTLPointMake(MTLFloat x, MTLFloat y);

struct MTLVector {MTLFloat dx,dy;};
typedef struct MTLVector MTLVector;
MTLVector MTLVectorMake(MTLFloat dx, MTLFloat dy);
MTLFloat MTLVectorLength(MTLVector *v);

struct MTLFloat3 {MTLFloat x,y,z;};
typedef struct MTLFloat3 MTLFloat3;
MTLFloat3 MTLFloat3Make(MTLFloat x, MTLFloat y, MTLFloat z);

struct MTLFloat4 {MTLFloat x,y,z,w;};
typedef struct MTLFloat4 MTLFloat4;
MTLFloat4 MTLFloat4Make(MTLFloat x, MTLFloat y, MTLFloat z, MTLFloat w);

struct MTLFloat2x2 {MTLFloat2 v1,v2;};
typedef struct MTLFloat2x2 MTLFloat2x2;
MTLFloat2x2 MTLFloat2x2Make(MTLFloat2 v1,MTLFloat2 v2);

struct MTLFloat3x3 {MTLFloat3 v1,v2,v3;};
typedef struct MTLFloat3x3 MTLFloat3x3;
MTLFloat3x3 MTLFloat3x3Make(MTLFloat3 v1,MTLFloat3 v2,MTLFloat3 v3);

struct MTLFloat4x4 {MTLFloat4 v1,v2,v3,v4;};
typedef struct MTLFloat4x4 MTLFloat4x4;
MTLFloat4x4 MTLFloat4x4Make(MTLFloat4 v1,MTLFloat4 v2,MTLFloat4 v3,MTLFloat4 v4);

struct MTLInt2 {MTLInt x,y;};
typedef struct MTLInt2 MTLInt2;
MTLInt2 MTLInt2Make(MTLInt x, MTLInt y);
MTLBool MTLInt2Equal(MTLInt2 m1, MTLInt2 m2);
MTLBool MTLInt2IsZero(MTLInt2 m);
void MTLInt2Swap(MTLInt2 *m);
extern MTLInt2 MTLInt2Zero;// = {0,0};

struct MTLUInt2 {MTLUInt x,y;};
typedef struct MTLUInt2 MTLUInt2;
MTLUInt2 MTLUInt2Make(MTLUInt x, MTLUInt y);
MTLBool MTLUInt2Equal(MTLUInt2 m1, MTLUInt2 m2);
MTLBool MTLUInt2IsZero(MTLUInt2 m);
void MTLUInt2Swap(MTLUInt2 *m);
extern MTLUInt2 MTLUInt2Zero;// = {0,0};

#endif

