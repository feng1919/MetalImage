//
//  MetalImageGlobal.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/6.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#ifndef __MetalImageGlobal__
#define __MetalImageGlobal__

#define MetalImageRotationSwapsWidthAndHeight(rotation) (\
(rotation) == kMetalImageRotateLeft || \
(rotation) == kMetalImageRotateRight || \
(rotation) == kMetalImageRotateRightFlipVertical || \
(rotation) == kMetalImageRotateRightFlipHorizontal)

typedef NS_ENUM(NSUInteger, MetalImageRotationMode) {
    kMetalImageNoRotation,//0
    kMetalImageRotateLeft,//1
    kMetalImageRotateRight,//2
    kMetalImageFlipVertical,//3
    kMetalImageFlipHorizonal,//4
    kMetalImageRotateRightFlipVertical,//5
    kMetalImageRotateRightFlipHorizontal,//6
    kMetalImageRotate180//7
};

#endif
