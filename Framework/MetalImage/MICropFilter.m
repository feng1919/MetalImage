//
//  MICropFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MICropFilter.h"
#import "MetalDevice.h"

@implementation MICropFilter

- (id)initWithCropRegion:(CGRect)newCropRegion;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    self.cropRegion = newCropRegion;
    
    return self;
}

- (id)init {
    return [self initWithCropRegion:CGRectMake(0, 0, 1, 1)];
}


- (void)setTextureCropCoordinates:(MTLFloat2[4])coordinates {
    for (int i = 0; i < 4; i++) {
        cropTextureCoordinates[i] = coordinates[i];
    }
}

- (void)calculateCropTextureCoordinates;
{
    CGFloat minX = _cropRegion.origin.x;
    CGFloat minY = _cropRegion.origin.y;
    CGFloat maxX = CGRectGetMaxX(_cropRegion);
    CGFloat maxY = CGRectGetMaxY(_cropRegion);
    
    switch(firstInputParameter.rotationMode)
    {
        case kMetalImageNoRotation:
        {//{A,B,C,D}
            cropTextureCoordinates[0] = MTLFloat2Make(minX, maxY);
            cropTextureCoordinates[1] = MTLFloat2Make(maxX, maxY);
            cropTextureCoordinates[2] = MTLFloat2Make(minX, minY);
            cropTextureCoordinates[3] = MTLFloat2Make(maxX, minY);
        }; break;
        case kMetalImageRotateLeft:
        {//{C,A,D,B}
            cropTextureCoordinates[0] = MTLFloat2Make(minY, 1.0-maxX);
            cropTextureCoordinates[1] = MTLFloat2Make(minY, 1.0-minX);
            cropTextureCoordinates[2] = MTLFloat2Make(maxY, 1.0-maxX);
            cropTextureCoordinates[3] = MTLFloat2Make(maxY, 1.0-minX);
        }; break;
        case kMetalImageRotateRight:
        {//{B,D,A,C}
            cropTextureCoordinates[0] = MTLFloat2Make(maxY, 1.0-minX);
            cropTextureCoordinates[1] = MTLFloat2Make(maxY, 1.0-maxX);
            cropTextureCoordinates[2] = MTLFloat2Make(minY, 1.0-minX);
            cropTextureCoordinates[3] = MTLFloat2Make(minY, 1.0-maxX);
        }; break;
        case kMetalImageFlipVertical:
        {//{C,D,A,B}
            cropTextureCoordinates[0] = MTLFloat2Make(minX, minY);
            cropTextureCoordinates[1] = MTLFloat2Make(maxX, minY);
            cropTextureCoordinates[2] = MTLFloat2Make(minX, maxY);
            cropTextureCoordinates[3] = MTLFloat2Make(maxX, maxY);
        }; break;
        case kMetalImageFlipHorizonal:
        {//{B,A,D,C}
            cropTextureCoordinates[0] = MTLFloat2Make(maxX, maxY);
            cropTextureCoordinates[1] = MTLFloat2Make(minX, maxY);
            cropTextureCoordinates[2] = MTLFloat2Make(maxX, minY);
            cropTextureCoordinates[3] = MTLFloat2Make(minX, minY);
        }; break;
        case kMetalImageRotate180:
        {//{D,C,B,A}
            cropTextureCoordinates[0] = MTLFloat2Make(maxX, minY);
            cropTextureCoordinates[1] = MTLFloat2Make(minX, minY);
            cropTextureCoordinates[2] = MTLFloat2Make(maxX, maxY);
            cropTextureCoordinates[3] = MTLFloat2Make(minX, maxY);
        }; break;
        case kMetalImageRotateRightFlipVertical:
        {//{D,B,C,A}
            cropTextureCoordinates[0] = MTLFloat2Make(maxY, 1.0-maxX);
            cropTextureCoordinates[1] = MTLFloat2Make(maxY, 1.0-minX);
            cropTextureCoordinates[2] = MTLFloat2Make(minY, 1.0-maxX);
            cropTextureCoordinates[3] = MTLFloat2Make(minY, 1.0-minX);
        }; break;
        case kMetalImageRotateRightFlipHorizontal:
        {//{A,C,B,D}
            cropTextureCoordinates[0] = MTLFloat2Make(minY, 1.0-minX);
            cropTextureCoordinates[1] = MTLFloat2Make(minY, 1.0-maxX);
            cropTextureCoordinates[2] = MTLFloat2Make(maxY, 1.0-minX);
            cropTextureCoordinates[3] = MTLFloat2Make(maxY, 1.0-maxX);
        }; break;
    }
}

MTLFloat Distance(MTLFloat2 *p0, MTLFloat2 *p1)
{
    MTLFloat x = p1->x-p0->x;
    MTLFloat y = p1->y-p0->y;
    return sqrt(x*x+y*y);
}

- (MTLUInt2)textureSizeForOutput {
    MTLUInt2 textureSize = [super textureSizeForOutput];
    MTLFloat tx, ty;
    if (MetalImageRotationSwapsWidthAndHeight(firstInputParameter.rotationMode)) {
        tx = textureSize.y;
        ty = textureSize.x;
    }
    else {
        tx = textureSize.x;
        ty = textureSize.y;
    }
    MTLFloat2 A, B, C;
    A.x = cropTextureCoordinates[0].x * tx;
    A.y = cropTextureCoordinates[0].y * ty;
    B.x = cropTextureCoordinates[1].x * tx;
    B.y = cropTextureCoordinates[1].y * ty;
    C.x = cropTextureCoordinates[2].x * tx;
    C.y = cropTextureCoordinates[2].y * ty;
    MTLFloat width = Distance(&A, &B);
    MTLFloat height = Distance(&C, &A);
    return MTLUInt2Make(roundf(width), roundf(height));
}

#pragma mark -
#pragma mark Accessors

- (void)setCropRegion:(CGRect)newValue;
{
    //    NSParameterAssert(newValue.origin.x >= 0 && newValue.origin.x <= 1 &&
    //                      newValue.origin.y >= 0 && newValue.origin.y <= 1 &&
    //                      newValue.size.width >= 0 && newValue.size.width <= 1 &&
    //                      newValue.size.height >= 0 && newValue.size.height <= 1);
    
    _cropRegion = newValue;
    [self calculateCropTextureCoordinates];
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    BOOL needCalculateCropRegion = newInputRotation != firstInputParameter.rotationMode;
    
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    
    if (needCalculateCropRegion) {
        [self calculateCropTextureCoordinates];
    }
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    [self renderToTextureWithVertices:MetalImageDefaultRenderVetics
                   textureCoordinates:(MTLFloat2 *)cropTextureCoordinates];
    
    [self notifyTargetsAboutNewTextureAtTime:frameTime];
}

@end
