/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageCacheConfig.h"
#import "SDMemoryCache.h"
#import "SDDiskCache.h"

static SDImageCacheConfig *_defaultCacheConfig;
static const NSInteger kDefaultCacheMaxDiskAge = 60 * 60 * 24 * 7; // 1 week   // 磁盘默认缓存时间是一周 60 * 60 * 24 * 7

@implementation SDImageCacheConfig

+ (SDImageCacheConfig *)defaultCacheConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultCacheConfig = [SDImageCacheConfig new];
    });
    return _defaultCacheConfig;
}

- (instancetype)init {
    if (self = [super init]) {
        _shouldDisableiCloud = YES;   // 默认不使用 iCloud
        _shouldCacheImagesInMemory = YES;  // 默认使用内存缓存
        _shouldUseWeakMemoryCache = YES;   // 默认弱引用内存缓存
        _shouldRemoveExpiredDataWhenEnterBackground = YES;  // APP进入后台的时候，默认删除过期的数据
        _diskCacheReadingOptions = 0;  // NSDataReadingMappedIfSafe 
        _diskCacheWritingOptions = NSDataWritingAtomic;  // 磁盘写入选项
        _maxDiskAge = kDefaultCacheMaxDiskAge;   // 最大磁盘缓存周期 一周  60 * 60 * 24 * 7
        _maxDiskSize = 0;  // 磁盘缓存的大小没有限制
        _diskCacheExpireType = SDImageCacheConfigExpireTypeModificationDate;   // 默认根据修改日期清除磁盘缓存
        _memoryCacheClass = [SDMemoryCache class];    
        _diskCacheClass = [SDDiskCache class];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SDImageCacheConfig *config = [[[self class] allocWithZone:zone] init];
    config.shouldDisableiCloud = self.shouldDisableiCloud;
    config.shouldCacheImagesInMemory = self.shouldCacheImagesInMemory;
    config.shouldUseWeakMemoryCache = self.shouldUseWeakMemoryCache;
    config.shouldRemoveExpiredDataWhenEnterBackground = self.shouldRemoveExpiredDataWhenEnterBackground;
    config.diskCacheReadingOptions = self.diskCacheReadingOptions;
    config.diskCacheWritingOptions = self.diskCacheWritingOptions;
    config.maxDiskAge = self.maxDiskAge;
    config.maxDiskSize = self.maxDiskSize;
    config.maxMemoryCost = self.maxMemoryCost;
    config.maxMemoryCount = self.maxMemoryCount;
    config.diskCacheExpireType = self.diskCacheExpireType;
    config.fileManager = self.fileManager; // NSFileManager does not conform to NSCopying, just pass the reference
    config.memoryCacheClass = self.memoryCacheClass;
    config.diskCacheClass = self.diskCacheClass;
    
    return config;
}

@end
