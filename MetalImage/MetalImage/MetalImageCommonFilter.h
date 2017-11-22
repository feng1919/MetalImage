//
//  MetalImageCommonFilter.h
//  MetalImage
//
//  Created by keyishen on 2017/7/25.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <MetalImage/MetalImage.h>

@interface MetalImageCommonFilter : MetalImageFilter

@property (nonatomic, strong) id <MTLTexture> lutTexture;

@end
