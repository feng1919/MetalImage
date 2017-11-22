//
//  MetalImageDebugView.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetalImageInput.h"
#import "MetalImageTexture.h"

@interface MetalImageDebugView : UIImageView <MetalImageInput> {
    
@protected
    MetalImageTexture *firstInputTexture;
    MetalImageRotationMode inputRotationMode;
}

@end
