//
//  MetalImageView.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/3.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetalImageInput.h"
#import "MetalImageTexture.h"

typedef NS_ENUM(NSUInteger, MetalImageFillModeType) {
    kMetalImageFillModeStretch,                       // Stretch to fill the full view, which may distort the image outside of its normal aspect ratio
    kMetalImageFillModePreserveAspectRatio,           // Maintains the aspect ratio of the source image, adding bars of the specified background color
    kMetalImageFillModePreserveAspectRatioAndFill     // Maintains the aspect ratio of the source image, zooming in on its center to fill the view
};

NS_ASSUME_NONNULL_BEGIN

@interface MetalImageView : UIView <MetalImageInput> {
    
@protected
    MetalImageTexture *firstInputTexture;
    MetalImageRotationMode inputRotationMode;
}


/** The fill mode dictates how images are fit in the view, with the default being kGPUImageFillModePreserveAspectRatio
 */
@property (nonatomic,assign) MetalImageFillModeType fillMode;


@property (nonatomic,assign) MTLClearColor bgClearColor;

@end

NS_ASSUME_NONNULL_END
