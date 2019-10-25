/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"

/// Image Cache Expire Type  图像缓存过期类型
typedef NS_ENUM(NSUInteger, SDImageCacheConfigExpireType) {
    /** 当图片被访问的时候 就更新这个值
     * When the image is accessed it will update this value
     */
    SDImageCacheConfigExpireTypeAccessDate,
    /** 默认从磁盘缓存中获取
     * The image was obtained from the disk cache (Default)
     */
    SDImageCacheConfigExpireTypeModificationDate
};

/**
 The class contains all the config for image cache
 @note This class conform to NSCopying, make sure to add the property in `copyWithZone:` as well.
 */
@interface SDImageCacheConfig : NSObject <NSCopying>

/**
 Gets the default cache config used for shared instance or initialization when it does not provide any cache config. Such as `SDImageCache.sharedImageCache`.
 @note You can modify the property on default cache config, which can be used for later created cache instance. The already created cache instance does not get affected.
 */
@property (nonatomic, class, readonly, nonnull) SDImageCacheConfig *defaultCacheConfig;

/**
 * Whether or not to disable iCloud backup
 * 是否禁用iCloud 备份 默认是禁用
 * Defaults to YES.
 */
@property (assign, nonatomic) BOOL shouldDisableiCloud;

/** 默认使用内存缓存 
 * Whether or not to use memory cache
 * @note When the memory cache is disabled, the weak memory cache will also be disabled.
 * Defaults to YES.
 */
@property (assign, nonatomic) BOOL shouldCacheImagesInMemory;

/* 是否弱引用内存缓存
 * The option to control weak memory cache for images. When enable, `SDImageCache`'s memory cache will use a weak maptable to store the image at the same time when it stored to memory, and get removed at the same time.
 * However when memory warning is triggered(触发), since the weak maptable does not hold a strong reference to image instance, even when the memory cache itself is purged, some images which are held strongly by UIImageViews or other live instances can be recovered again, to avoid later re-query from disk cache or network. This may be helpful for the case, for example, when app enter background and memory is purged, cause cell flashing after re-enter foreground.
 * Defautls to YES. You can change this option dynamically.
 */
@property (assign, nonatomic) BOOL shouldUseWeakMemoryCache;

/** APP进入后台的时候，默认删除过期的数据
 * Whether or not to remove the expired disk data when application entering the background. (Not works for macOS)
 * Defaults to YES.
 */
@property (assign, nonatomic) BOOL shouldRemoveExpiredDataWhenEnterBackground;

/** 从磁盘读取缓存的选项
 * The reading options while reading cache from disk.
 * Defaults to 0. You can set this to `NSDataReadingMappedIfSafe` to improve performance.
 */
@property (assign, nonatomic) NSDataReadingOptions diskCacheReadingOptions;

/** 写入磁盘的选项
 * The writing options while writing cache to disk.
 * Defaults to `NSDataWritingAtomic`. You can set this to `NSDataWritingWithoutOverwriting` to prevent overwriting an existing file.
 */
@property (assign, nonatomic) NSDataWritingOptions diskCacheWritingOptions;

/** 图像在磁盘保存的最长时间  默认为一周
 * The maximum length of time to keep an image in the disk cache, in seconds.
 * Setting this to a negative value means no expiring.  设置为负数表示没有过期时间
 * Setting this to zero means that all cached files would be removed when do expiration check.
 * Defaults to 1 week.
 */
@property (assign, nonatomic) NSTimeInterval maxDiskAge;

/** 磁盘缓存的最大值 字节为单位
 * The maximum size of the disk cache, in bytes.
 * Defaults to 0. Which means there is no cache size limit.  默认为 0 没有限制
 */
@property (assign, nonatomic) NSUInteger maxDiskSize;

/** 内存缓存的最大值
 * The maximum "total cost" of the in-memory image cache. The cost function is the bytes size held in memory.
 * @note The memory cost is bytes size in memory, but not simple pixels count. For common ARGB8888 image, one pixel is 4 bytes (32 bits).
 * Defaults to 0. Which means there is no memory cost limit.  默认为 0 没有大小限制
 */
@property (assign, nonatomic) NSUInteger maxMemoryCost;

/** 内存缓存的最大数量
 * The maximum number of objects in-memory image cache should hold.
 * Defaults to 0. Which means there is no memory count limit.  默认为0 没有限制
 */
@property (assign, nonatomic) NSUInteger maxMemoryCount;

/* 清除磁盘缓存时将根据其检查的属性
 * The attribute which the clear cache will be checked against when clearing the disk cache
 * Default is Modified Date  默认根据修改日期清除缓存
 */
@property (assign, nonatomic) SDImageCacheConfigExpireType diskCacheExpireType;

/** 磁盘缓存的自定义文件管理器  传递 nil 则用默认的管理器
 * The custom file manager for disk cache. Pass nil to let disk cache choose the proper file manager.
 * Defaults to nil.
 * @note This value does not support dynamic changes. Which means further modification on this value after cache initlized has no effect.
 * @note Since `NSFileManager` does not support `NSCopying`. We just pass this by reference during copying. So it's not recommend to set this value on `defaultCacheConfig`.
 */
@property (strong, nonatomic, nullable) NSFileManager *fileManager;

/** 自定义的内存缓存类  提供的类的实例必须遵守 SDMemoryCache 协议才允许使用
 * The custom memory cache class. Provided class instance must conform to `SDMemoryCache` protocol to allow usage.
 * Defaults to built-in `SDMemoryCache` class.
 * @note This value does not support dynamic changes. Which means further modification on this value after cache initlized has no effect.
 */
@property (assign, nonatomic, nonnull) Class memoryCacheClass;

/** 自定义的磁盘缓存类   提供 的类的实例必须遵守 SDDiskCache 协议才允许使用
 * The custom disk cache class. Provided class instance must conform to `SDDiskCache` protocol to allow usage.
 * Defaults to built-in `SDDiskCache` class.
 * @note This value does not support dynamic changes. Which means further modification on this value after cache initlized has no effect.
 */
@property (assign ,nonatomic, nonnull) Class diskCacheClass;

@end
