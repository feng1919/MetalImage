@import UIKit;

@protocol MTLTexture;

@interface UIImage (MTLTexture)

+ (UIImage *)imageWithMTLTexture:(id<MTLTexture>)texture orientation:(UIImageOrientation)orientation;

@end

bool CGRectIsValid(CGRect rect);
