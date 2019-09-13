//
//  MetalImagePicture.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetalImageOutput.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalImagePicture : MetalImageOutput {
    
    CGSize pixelSizeOfImage;
    BOOL hasProcessedImage;
    BOOL shouldSmoothlyScaleOutput;
    
    dispatch_semaphore_t imageUpdateSemaphore;
}

- (instancetype)initWithImage:(UIImage *)newImageSource;
- (instancetype)initWithImage:(UIImage *)newImageSource smoothlyScaleOutput:(BOOL)smoothlyScaleOutput removePremultiplication:(BOOL)removePremultiplication;

- (void)processImage;
- (BOOL)processImageWithCompletionHandler:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
