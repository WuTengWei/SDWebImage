/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDefine.h"
#import "UIImage+Metadata.h"
#import "NSImage+Compatibility.h"

#pragma mark - Image scale

static inline NSArray<NSNumber *> * _Nonnull SDImageScaleFactors() {
    return @[@2, @3];
}

inline CGFloat SDImageScaleFactorForKey(NSString * _Nullable key) {
    CGFloat scale = 1;
    if (!key) {
        return scale;
    }
    // Check if target OS support scale
#if SD_WATCH
    if ([[WKInterfaceDevice currentDevice] respondsToSelector:@selector(screenScale)])
#elif SD_UIKIT
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
#elif SD_MAC
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)])
#endif
    {
        // a@2x.png -> 8
        if (key.length >= 8) {
            // Fast check
            BOOL isURL = [key hasPrefix:@"http://"] || [key hasPrefix:@"https://"];
            for (NSNumber *scaleFactor in SDImageScaleFactors()) {
                // @2x. for file name and normal url
                NSString *fileScale = [NSString stringWithFormat:@"@%@x.", scaleFactor];
                if ([key containsString:fileScale]) {
                    scale = scaleFactor.doubleValue;
                    return scale;
                }
                if (isURL) {
                    // %402x. for url encode
                    NSString *urlScale = [NSString stringWithFormat:@"%%40%@x.", scaleFactor];
                    if ([key containsString:urlScale]) {
                        scale = scaleFactor.doubleValue;
                        return scale;
                    }
                }
            }
        }
    }
    return scale;
}

inline UIImage * _Nullable SDScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    CGFloat scale = SDImageScaleFactorForKey(key);
    return SDScaledImageForScaleFactor(scale, image);
}

inline UIImage * _Nullable SDScaledImageForScaleFactor(CGFloat scale, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    if (scale <= 1) {
        return image;
    }
    if (scale == image.scale) {
        return image;
    }
    UIImage *scaledImage;
    if (image.sd_isAnimated) {
        UIImage *animatedImage;
#if SD_UIKIT || SD_WATCH
        // `UIAnimatedImage` images share the same size and scale.
        NSMutableArray<UIImage *> *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images) {
            UIImage *tempScaledImage = [[UIImage alloc] initWithCGImage:tempImage.CGImage scale:scale orientation:tempImage.imageOrientation];
            [scaledImages addObject:tempScaledImage];
        }
        
        animatedImage = [UIImage animatedImageWithImages:scaledImages duration:image.duration];
        animatedImage.sd_imageLoopCount = image.sd_imageLoopCount;
#else
        // Animated GIF for `NSImage` need to grab `NSBitmapImageRep`;
        NSRect imageRect = NSMakeRect(0, 0, image.size.width, image.size.height);
        NSImageRep *imageRep = [image bestRepresentationForRect:imageRect context:nil hints:nil];
        NSBitmapImageRep *bitmapImageRep;
        if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
            bitmapImageRep = (NSBitmapImageRep *)imageRep;
        }
        if (bitmapImageRep) {
            NSSize size = NSMakeSize(image.size.width / scale, image.size.height / scale);
            animatedImage = [[NSImage alloc] initWithSize:size];
            bitmapImageRep.size = size;
            [animatedImage addRepresentation:bitmapImageRep];
        }
#endif
        scaledImage = animatedImage;
    } else {
#if SD_UIKIT || SD_WATCH
        scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
#else
        scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:kCGImagePropertyOrientationUp];
#endif
    }
    scaledImage.sd_isIncremental = image.sd_isIncremental;
    scaledImage.sd_imageFormat = image.sd_imageFormat;
    
    return scaledImage;
}

#pragma mark - Context option

/*
  一个可扩展的 String 枚举类型
 typedef NSString * SDWebImageContextOption NS_EXTENSIBLE_STRING_ENUM;
 */

//作为view类别的 operation key使用，用来存储图像下载的operation，用于支持不同图像加载过程的视图实例。如果为nil，则使用类名作为操作键
SDWebImageContextOption const SDWebImageContextSetImageOperationKey = @"setImageOperationKey";
//可以传入一个自定义的SDWebImageManager，默认使用[SDWebImageManager sharedManager]
SDWebImageContextOption const SDWebImageContextCustomManager = @"customManager";
//可以传入一个SDImageTransformer类型，用于转换处理加载出来的图片，并将变换后的图像存储到缓存中。如果设置了，则会忽略manager中的transformer
SDWebImageContextOption const SDWebImageContextImageTransformer = @"imageTransformer";
//CGFloat原始值，为用于指定图像比例且这个数值应大于等于1.0
SDWebImageContextOption const SDWebImageContextImageScaleFactor = @"imageScaleFactor";
//SDImageCacheType原始值，用于刚刚下载图像时指定缓存类型，并将其存储到缓存中。
//指定SDImageCacheTypeNone：禁用缓存存储; SDImageCacheTypeDisk：仅存储在磁盘缓存中;
//SDImageCacheTypeMemory：只存储在内存中；SDImageCacheTypeAll：存储在内存缓存和磁盘缓存中。如果没有提供或值无效，则使用SDImageCacheTypeAll
SDWebImageContextOption const SDWebImageContextStoreCacheType = @"storeCacheType";
//用于使用SDAnimatedImageView来改善动画图像渲染性能（尤其是大动画图像上的内存使用）
SDWebImageContextOption const SDWebImageContextOriginalStoreCacheType = @"originalStoreCacheType";
//用于在加载图片前修改NSURLRequest
SDWebImageContextOption const SDWebImageContextAnimatedImageClass = @"animatedImageClass";
SDWebImageContextOption const SDWebImageContextDownloadRequestModifier = @"downloadRequestModifier";
SDWebImageContextOption const SDWebImageContextDownloadResponseModifier = @"downloadResponseModifier";
SDWebImageContextOption const SDWebImageContextDownloadDecryptor = @"downloadDecryptor";
//指定图片的缓存key
SDWebImageContextOption const SDWebImageContextCacheKeyFilter = @"cacheKeyFilter";
//转换需要缓存的图片格式，通常用于需要缓存的图片格式与下载的图片格式不相符的时候，如：下载的时候为了节约流量、减少下载时间使用了WebP格式，但是如果缓存也用WebP，每次从缓存中取图片都需要经过一次解压缩，这样是比较影响性能的，就可以使用id
SDWebImageContextOption const SDWebImageContextCacheSerializer = @"cacheSerializer";
