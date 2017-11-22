//
//  MetalImageTypes.h
//  MetalImage
//
//  Created by stonefeng on 2017/2/11.
//  Copyright © 2017年 fengshi. All rights reserved.
//

typedef float MTLFloat;
typedef unsigned int MTLUInt;
typedef bool MTLBool;

typedef struct {
    float x;
    float y;
}MTLRenderingPoint;

MTL_INLINE MTLRenderingPoint MTLRenderingPointMake(float x, float y)
{
    MTLRenderingPoint point = {x, y};
    return point;
}

typedef struct {
    MTLRenderingPoint lowerLeft;
    MTLRenderingPoint lowerRight;
    MTLRenderingPoint upperRight;
    MTLRenderingPoint upperLeft;
}MTLRenderingCoordinate;

MTL_INLINE MTLRenderingCoordinate MTLRenderingCoordinateMake(MTLRenderingPoint lowerLeft, MTLRenderingPoint lowerRight, MTLRenderingPoint upperRight, MTLRenderingPoint upperLeft)
{
    MTLRenderingCoordinate coordinate;
    coordinate.lowerLeft = lowerLeft;
    coordinate.lowerRight = lowerRight;
    coordinate.upperLeft = upperLeft;
    coordinate.upperRight = upperRight;
    return coordinate;
}

struct MTLFloat2 {MTLFloat x,y;};
typedef struct MTLFloat2 MTLFloat2;
MTL_INLINE MTLFloat2
MTLFloat2Make(MTLFloat x, MTLFloat y)
{MTLFloat2 vector; vector.x = x; vector.y = y; return vector;}

struct MTLFloat3 {MTLFloat x,y,z;};
typedef struct MTLFloat3 MTLFloat3;
MTL_INLINE MTLFloat3
MTLFloat3Make(MTLFloat x, MTLFloat y, MTLFloat z)
{MTLFloat3 vector; vector.x = x; vector.y = y; vector.z = z; return vector;}

struct MTLFloat4 {MTLFloat x,y,z,w;};
typedef struct MTLFloat4 MTLFloat4;
MTL_INLINE MTLFloat4
MTLFloat4Make(MTLFloat x, MTLFloat y, MTLFloat z, MTLFloat w)
{MTLFloat4 vector; vector.x = x; vector.y = y; vector.z = z; vector.w = w; return vector;}

struct MTLFloat2x2 {MTLFloat2 v1,v2;};
typedef struct MTLFloat2x2 MTLFloat2x2;
MTL_INLINE MTLFloat2x2
MTLFloat2x2Make(MTLFloat2 v1,MTLFloat2 v2)
{MTLFloat2x2 m; m.v1 = v1;m.v2 = v2;return m;}

struct MTLFloat3x3 {MTLFloat3 v1,v2,v3;};
typedef struct MTLFloat3x3 MTLFloat3x3;
MTL_INLINE MTLFloat3x3
MTLFloat3x3Make(MTLFloat3 v1,MTLFloat3 v2,MTLFloat3 v3)
{MTLFloat3x3 m; m.v1 = v1;m.v2 = v2;m.v3 = v3;return m;}

struct MTLFloat4x4 {MTLFloat4 v1,v2,v3,v4;};
typedef struct MTLFloat4x4 MTLFloat4x4;
MTL_INLINE MTLFloat4x4
MTLFloat4x4Make(MTLFloat4 v1,MTLFloat4 v2,MTLFloat4 v3,MTLFloat4 v4)
{MTLFloat4x4 m; m.v1=v1;m.v2=v2;m.v3=v3;m.v4=v4;return m;}

struct MTLUInt2 {MTLUInt x,y;};
typedef struct MTLUInt2 MTLUInt2;
MTL_INLINE MTLUInt2
MTLUInt2Make(MTLUInt x, MTLUInt y)
{MTLUInt2 vector; vector.x = x; vector.y = y; return vector;}
MTL_INLINE MTLBool MTLUInt2Equal(MTLUInt2 m1, MTLUInt2 m2)
{return m1.x == m2.x && m1.y == m2.y;}
MTL_INLINE MTLBool MTLUInt2IsZero(MTLUInt2 m)
{return m.x == 0 || m.y == 0;}
MTL_INLINE void MTLUInt2Swap(MTLUInt2 *m)
{MTLUInt x1 = m->x; m->x = m->y; m->y = x1;}
extern const MTLUInt2 MTLUInt2Zero;// = {0,0};



