//
//  MetalImageTypes.h
//  MetalImage
//
//  Created by stonefeng on 2017/2/11.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#include "MetalImageTypes.h"
#include <math.h>

MTLRenderingPoint MTLRenderingPointMake(float x, float y)
{
    MTLRenderingPoint point = {x, y};
    return point;
}

MTLRenderingCoordinate MTLRenderingCoordinateMake(MTLRenderingPoint lowerLeft, MTLRenderingPoint lowerRight, MTLRenderingPoint upperRight, MTLRenderingPoint upperLeft)
{
    MTLRenderingCoordinate coordinate;
    coordinate.lowerLeft = lowerLeft;
    coordinate.lowerRight = lowerRight;
    coordinate.upperLeft = upperLeft;
    coordinate.upperRight = upperRight;
    return coordinate;
}

MTLFloat2
MTLFloat2Make(MTLFloat x, MTLFloat y)
{MTLFloat2 vector; vector.x = x; vector.y = y; return vector;}

MTLPoint
MTLPointMake(MTLFloat x, MTLFloat y)
{MTLPoint p; p.x = x; p.y = y; return p;}

MTLVector
MTLVectorMake(MTLFloat dx, MTLFloat dy)
{MTLVector vector; vector.dx = dx; vector.dy = dy; return vector;}

MTLFloat
MTLVectorLength(MTLVector *v)
{return sqrtf(v->dx*v->dx+v->dy*v->dy);}

MTLFloat3
MTLFloat3Make(MTLFloat x, MTLFloat y, MTLFloat z)
{MTLFloat3 vector; vector.x = x; vector.y = y; vector.z = z; return vector;}

MTLFloat4
MTLFloat4Make(MTLFloat x, MTLFloat y, MTLFloat z, MTLFloat w)
{MTLFloat4 vector; vector.x = x; vector.y = y; vector.z = z; vector.w = w; return vector;}

MTLFloat2x2
MTLFloat2x2Make(MTLFloat2 v1,MTLFloat2 v2)
{MTLFloat2x2 m; m.v1 = v1;m.v2 = v2;return m;}

MTLFloat3x3
MTLFloat3x3Make(MTLFloat3 v1,MTLFloat3 v2,MTLFloat3 v3)
{MTLFloat3x3 m; m.v1 = v1;m.v2 = v2;m.v3 = v3;return m;}

MTLFloat4x4
MTLFloat4x4Make(MTLFloat4 v1,MTLFloat4 v2,MTLFloat4 v3,MTLFloat4 v4)
{MTLFloat4x4 m; m.v1=v1;m.v2=v2;m.v3=v3;m.v4=v4;return m;}

MTLInt2
MTLInt2Make(MTLInt x, MTLInt y)
{MTLInt2 vector; vector.x = x; vector.y = y; return vector;}

MTLBool
MTLInt2Equal(MTLInt2 m1, MTLInt2 m2)
{return m1.x == m2.x && m1.y == m2.y;}

MTLBool
MTLInt2IsZero(MTLInt2 m)
{return m.x == 0 || m.y == 0;}

void
MTLInt2Swap(MTLInt2 *m)
{MTLInt x1 = m->x; m->x = m->y; m->y = x1;}

MTLInt2 MTLInt2Zero = {0, 0};

MTLUInt2
MTLUInt2Make(MTLUInt x, MTLUInt y)
{MTLUInt2 vector; vector.x = x; vector.y = y; return vector;}

MTLBool
MTLUInt2Equal(MTLUInt2 m1, MTLUInt2 m2)
{return m1.x == m2.x && m1.y == m2.y;}

MTLBool
MTLUInt2IsZero(MTLUInt2 m)
{return m.x == 0 || m.y == 0;}

void
MTLUInt2Swap(MTLUInt2 *m)
{MTLUInt x1 = m->x; m->x = m->y; m->y = x1;}

MTLUInt2 MTLUInt2Zero = {0, 0};



