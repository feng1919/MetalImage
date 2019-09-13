#import "UIImage+Texture.h"
@import Metal;

static void MTLReleaseDataCallback(void *info, const void *data, size_t size)
{
    free((void *)data);
}

@implementation UIImage (MTLTexture)

+ (UIImage *)imageWithMTLTexture:(id<MTLTexture>)texture orientation:(UIImageOrientation)orientation
{
    NSAssert([texture pixelFormat] == MTLPixelFormatBGRA8Unorm, @"Pixel format of texture must be MTLPixelFormatBGRA8Unorm to create UIImage");
    
    CGSize imageSize = CGSizeMake([texture width], [texture height]);
    size_t imageByteCount = imageSize.width * imageSize.height * 4;
    void *imageBytes = malloc(imageByteCount);
    NSUInteger bytesPerRow = imageSize.width * 4;
    MTLRegion region = MTLRegionMake2D(0, 0, imageSize.width, imageSize.height);
    [texture getBytes:imageBytes bytesPerRow:bytesPerRow fromRegion:region mipmapLevel:0];
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imageBytes, imageByteCount, MTLReleaseDataCallback);

    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(imageSize.width,
                                        imageSize.height,
                                        8,
                                        32,
                                        bytesPerRow,
                                        colorSpace,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        false,
                                        renderingIntent);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:orientation];
    
    CFRelease(provider);
    CFRelease(imageRef);
    
    return image;
}

@end

bool CGRectIsValid(CGRect rect) {

    if (CGRectIsNull(rect) || CGRectIsEmpty(rect)) {
        return false;
    }
    if (isnan(rect.origin.x) || isnan(rect.origin.y) ||
        isnan(rect.size.width) || isnan(rect.size.height)) {
        return false;
    }
    return true;
}

