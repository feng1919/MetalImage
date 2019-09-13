//
//  MIMosaicFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetalImageTwoInputFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIMosaicFilter : MetalImageTwoInputFilter

//  This filter takes an input tileset, the tiles must ascend in luminance
//  It looks at the input image and replaces each display tile with an input tile
//  according to the luminance of that tile.  The idea was to replicate the ASCII
//  video filters seen in other apps, but the tileset can be anything.
@property(readwrite, nonatomic) MTLFloat2 inputTileSize;
@property(readwrite, nonatomic) MTLFloat2 displayTileSize;
@property(readwrite, nonatomic) float numTiles;
@property(readwrite, nonatomic) BOOL colorOn;

- (void)setTileSetImage:(UIImage *)tileSetImage;

@end

NS_ASSUME_NONNULL_END
