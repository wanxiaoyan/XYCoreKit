//
//  XYImageLoader.h
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImage.h>
#import "XYImageLoaderConfig.h"
#import "XYImageTransformer.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^XYImageLoaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);
typedef void(^XYImageLoaderCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL);


@interface XYImageLoader : NSObject


+ (instancetype)sharedLoader;

#pragma mark - 核心加载 API
/// 加载网络图片（基础版）
- (void)loadImageWithURL:(NSURL *)url
         placeholderImage:(UIImage * _Nullable)placeholder
                completed:(XYImageLoaderCompletionBlock _Nullable)completed;

/// 加载网络图片（支持降采样，防 OOM）
- (void)loadImageWithURL:(NSURL *)url
         placeholderImage:(UIImage * _Nullable)placeholder
              targetSize:(CGSize)targetSize
                completed:(XYImageLoaderCompletionBlock _Nullable)completed;

/// 加载网络图片（支持降采样+圆角，避免离屏渲染）
- (void)loadImageWithURL:(NSURL *)url
         placeholderImage:(UIImage * _Nullable)placeholder
              targetSize:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRadius
                completed:(XYImageLoaderCompletionBlock _Nullable)completed;

/// 加载网络图片（完整版，支持所有参数）
- (void)loadImageWithURL:(NSURL *)url
         placeholderImage:(UIImage * _Nullable)placeholder
              targetSize:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRadius
              borderWidth:(CGFloat)borderWidth
              borderColor:(UIColor * _Nullable)borderColor
                  options:(SDWebImageOptions)options
                 progress:(XYImageLoaderProgressBlock _Nullable)progress
                completed:(XYImageLoaderCompletionBlock _Nullable)completed;

#pragma mark - 取消/清理 API
/// 取消指定 URL 的图片加载
- (void)cancelLoadWithOperation:(SDWebImageCombinedOperation *)operation;
/// 取消所有图片加载
- (void)cancelAllLoads;

/// 清理内存缓存
- (void)clearMemoryCache;
/// 清理磁盘缓存
- (void)clearDiskCache;
/// 清理所有缓存（内存+磁盘）
- (void)clearAllCache;


@end

NS_ASSUME_NONNULL_END
