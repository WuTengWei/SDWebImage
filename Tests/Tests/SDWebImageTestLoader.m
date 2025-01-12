/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Matt Galloway
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageTestLoader.h"
#import <KVOController/KVOController.h>

@interface NSURLSessionTask (SDWebImageOperation) <SDWebImageOperation>

@end

@implementation SDWebImageTestLoader

- (BOOL)canRequestImageForURL:(NSURL *)url {
    return YES;
}

// 下载图片
- (id<SDWebImageOperation>)requestImageWithURL:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDImageLoaderCompletedBlock)completedBlock {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *image = SDImageLoaderDecodeImageData(data, url, options, context);
                if (completedBlock) {
                    completedBlock(image, data, nil, YES);
                }
            });
        } else {
            if (completedBlock) {
                completedBlock(nil, nil, error, YES);
            }
        }
    }];
    // 监听下载进度
    [self.KVOController observe:task keyPath:NSStringFromSelector(@selector(countOfBytesReceived)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSURLSessionTask *sessionTask = object;
        NSInteger receivedSize = sessionTask.countOfBytesReceived;
        NSInteger expectedSize = sessionTask.countOfBytesExpectedToReceive;
        if (progressBlock) {
            progressBlock(receivedSize, expectedSize, url);
        }
    }];
    [task resume];
    
    return task;
}

- (BOOL)shouldBlockFailedURLWithURL:(NSURL *)url error:(NSError *)error {
    return NO;
}

@end
