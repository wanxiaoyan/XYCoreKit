//
//  XYImageLoaderConfig.h
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//  全局配置（缓存路径、内存 / 磁盘成本、占位图 / 失败图、WebP 开关、日志）

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYImageLoaderConfig : NSObject

#pragma mark - 缓存配置
/// 内存缓存最大成本（单位：像素，默认 1000 万像素 ≈ 40MB）
@property (nonatomic, assign) NSUInteger maxMemoryCost;

/// 磁盘缓存最大成本（单位：字节，默认 100MB）
@property (nonatomic, assign) NSUInteger maxDiskCost;

/// 磁盘缓存路径（默认 ~/Library/Caches/XYImageLoader）
@property (nonatomic, copy) NSString *diskCachePath;


#pragma mark - 图片配置
/// 是否启用 WebP 支持（默认 YES）
@property (nonatomic, assign) BOOL enableWebP;

/// 默认占位图（全局通用，可单独覆盖）
@property (nonatomic, strong) UIImage *defaultPlaceholderImage;

/// 默认失败图（全局通用，可单独覆盖）
@property (nonatomic, strong, nullable) UIImage *defaultFailureImage;

#pragma mark - 其他配置
/// 是否启用日志（默认 DEBUG 开启，RELEASE 关闭）
@property (nonatomic, assign) BOOL enableLog;


+ (instancetype)shareConfig;


@end

NS_ASSUME_NONNULL_END
