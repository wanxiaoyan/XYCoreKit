//
//  XYImageLoader.m
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import "XYImageLoader.h"


#define XYImageLoaderLog(format, ...) \
    if ([XYImageLoaderConfig shareConfig].enableLog) { \
        NSLog(@"[HYImageLoader] " format, ##__VA_ARGS__); \
    }


@interface XYImageLoader ()

@property (nonatomic, strong) SDWebImageManager *imageManager;
@property (nonatomic, strong) SDImageCache *imageCache;

@end

@implementation XYImageLoader

+ (instancetype)sharedLoader {
    static XYImageLoader *loader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[self alloc] init];
    });
    return loader;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupConfig];
        [self setupWebPCoder];
    }
    return self;
}

#pragma mark - 初始化配置
- (void)setupConfig {
    XYImageLoaderConfig *config = [XYImageLoaderConfig shareConfig];
    
    // 初始化自定义缓存
    _imageCache = [[SDImageCache alloc] initWithNamespace:@"HYImageLoader" diskCacheDirectory:config.diskCachePath];
    _imageCache.config.maxMemoryCost = config.maxMemoryCost;
    _imageCache.config.maxDiskSize = config.maxDiskCost;
    
    // 初始化 SDWebImageManager
    _imageManager = [[SDWebImageManager alloc] initWithCache:self.imageCache loader:[SDWebImageDownloader sharedDownloader]];
    
    // 配置下载器
//    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
//    downloader.maxConcurrentDownloads = 6; // 最大并发下载数
//    downloader.downloadTimeout = 30; // 下载超时时间
    
    XYImageLoaderLog(@"初始化完成：内存缓存最大成本 %lu 像素，磁盘缓存最大成本 %lu 字节",
                      (unsigned long)config.maxMemoryCost,
                      (unsigned long)config.maxDiskCost);
}

- (void)setupWebPCoder {
    if (![XYImageLoaderConfig shareConfig].enableWebP) {
        return;
    }
    
//    // 注册 WebP 编码器/解码器
//    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
//    [[SDImageCodersManager sharedManager] addCoder:webPCoder];
//    [[SDWebImageDownloader sharedDownloader] setValue:@"image/webp,image/*;q=0.8" forHTTPHeaderField:@"Accept"];
    
    XYImageLoaderLog(@"WebP 支持已启用");
}

#pragma mark - 核心加载实现
- (void)loadImageWithURL:(NSURL *)url
         placeholderImage:(UIImage *)placeholder
                completed:(XYImageLoaderCompletionBlock)completed {
    [self loadImageWithURL:url
          placeholderImage:placeholder
               targetSize:CGSizeZero
              cornerRadius:0
               borderWidth:0
               borderColor:nil
                   options:0
                  progress:nil
                 completed:completed];
}

- (void)loadImageWithURL:(NSURL *)url
         placeholderImage:(UIImage *)placeholder
              targetSize:(CGSize)targetSize
                completed:(XYImageLoaderCompletionBlock)completed {
    [self loadImageWithURL:url
          placeholderImage:placeholder
               targetSize:targetSize
              cornerRadius:0
               borderWidth:0
               borderColor:nil
                   options:0
                  progress:nil
                 completed:completed];
}

- (void)loadImageWithURL:(NSURL *)url
         placeholderImage:(UIImage *)placeholder
              targetSize:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRadius
                completed:(XYImageLoaderCompletionBlock)completed {
    [self loadImageWithURL:url
          placeholderImage:placeholder
               targetSize:targetSize
              cornerRadius:cornerRadius
               borderWidth:0
               borderColor:nil
                   options:0
                  progress:nil
                 completed:completed];
}

- (void)loadImageWithURL:(NSURL *)url
         placeholderImage:(UIImage *)placeholder
              targetSize:(CGSize)targetSize
             cornerRadius:(CGFloat)cornerRadius
              borderWidth:(CGFloat)borderWidth
              borderColor:(UIColor *)borderColor
                  options:(SDWebImageOptions)options
                 progress:(XYImageLoaderProgressBlock)progress
               completed:(XYImageLoaderCompletionBlock)completed {
    if (!url) {
        XYImageLoaderLog(@"URL 为空，直接返回");
        if (completed) {
            NSError *error = [NSError errorWithDomain:@"HYImageLoaderErrorDomain"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"URL 为空"}];
            completed(nil, error, SDImageCacheTypeNone, nil);
        }
        return;
    }
    
    // 处理默认占位图/失败图
    UIImage *finalPlaceholder = placeholder ?: [XYImageLoaderConfig shareConfig].defaultPlaceholderImage;
    
    
    // 构建变换器链（先降采样，再画圆角）
    NSMutableArray<id<SDImageTransformer>> *transformers = [NSMutableArray array];
    if (!CGSizeEqualToSize(targetSize, CGSizeZero)) {
        XYImageDownsamplingTransformer *downsampling = [XYImageDownsamplingTransformer transformerWithTargetSize:targetSize];
        [transformers addObject:downsampling];
    }
    
    if (cornerRadius > 0 && !CGSizeEqualToSize(targetSize, CGSizeZero)) {
        XYImageCornerTransformer *corner = [XYImageCornerTransformer transformerWithCornerRadius:cornerRadius
                                                                                      targetSize:targetSize
                                                                                     borderWidth:borderWidth
                                                                                     borderColor:borderColor];
        [transformers addObject:corner];
    }
    
    SDImagePipelineTransformer *transformer = nil;
    
    if (transformers.count > 0) {
        transformer = [SDImagePipelineTransformer transformerWithTransformers:transformers];
    }
    
    // 发起加载
    XYImageLoaderLog(@"开始加载图片：%@", url.absoluteString);
    [self.imageManager loadImageWithURL:url
                                options:options
                                context:transformer ? @{SDWebImageContextImageTransformer: transformer} : nil
                               progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (progress) {
            progress(receivedSize, expectedSize, targetURL);
        }
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (error) {
            XYImageLoaderLog(@"加载失败：%@，错误：%@", url.absoluteString, error.localizedDescription);
            // 加载失败时显示默认失败图
            UIImage *failureImage = [XYImageLoaderConfig shareConfig].defaultFailureImage;
            if (completed) {
                completed(failureImage, error, cacheType, imageURL);
            }
        } else {
            XYImageLoaderLog(@"加载成功：%@，缓存类型：%ld", url.absoluteString, (long)cacheType);
            if (completed) {
                completed(image, nil, cacheType, imageURL);
            }
        }
    }];
}

#pragma mark - 取消/清理实现
- (void)cancelLoadWithOperation:(SDWebImageCombinedOperation *)operation {
    if (!operation || operation.isCancelled) return;
    [operation cancel];
    XYImageLoaderLog(@"已取消指定加载操作");
}

- (void)cancelAllLoads {
    [self.imageManager cancelAll];
    XYImageLoaderLog(@"取消所有加载");
}

- (void)clearMemoryCache {
    [self.imageCache clearMemory];
    XYImageLoaderLog(@"清理内存缓存");
}

- (void)clearDiskCache {
    [self.imageCache clearDiskOnCompletion:^{
        XYImageLoaderLog(@"清理磁盘缓存完成");
    }];
}

- (void)clearAllCache {
    [self clearMemoryCache];
    [self clearDiskCache];
}

@end
