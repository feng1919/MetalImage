//
//  MetalImagePreprocess.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/6.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetalImageTexture.h"
#import "MetalImageOutput.h"

@interface MetalImagePreprocess : MetalImageOutput <MetalImageInput>

@property (nonatomic,assign) uint32_t borderSize;

@end
