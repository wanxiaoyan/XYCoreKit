//
//  XYImageLoaderConfig.m
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import "XYImageLoaderConfig.h"

@implementation XYImageLoaderConfig

+ (instancetype)shareConfig {
    static XYImageLoaderConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc] init];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _maxMemoryCost = 1000 * 1000 * 10; // // 1000 万像素
        _maxDiskCost = 100 * 1024 * 1024;   // 100MB
        
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        _diskCachePath = [cachePath stringByAppendingString:@"XYImageLoader"];
        _enableWebP = YES;
        _enableLog = DEBUG;
    }
    
    return self;
}

@end
