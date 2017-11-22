//
//  MetalImagePolkaDotFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImagePixellateFilter.h"

@interface MetalImagePolkaDotFilter : MetalImagePixellateFilter

@property(readwrite, nonatomic) MTLFloat dotScaling;

@end
