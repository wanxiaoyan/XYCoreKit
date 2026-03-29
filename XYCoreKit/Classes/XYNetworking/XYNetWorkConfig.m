//
//  XYNetWorkConfig.m
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import "XYNetWorkConfig.h"

@interface XYNetWorkConfig ()
@property (nonatomic, strong) NSMutableDictionary *mutableCommonParameters;
@property (nonatomic, strong) NSMutableDictionary *mutableCommonHeaders;
@end


@implementation XYNetWorkConfig

+ (instancetype)shareConfig {
    static XYNetWorkConfig *config;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        config = [[XYNetWorkConfig alloc] init];
    });
    
    return  config;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _env = XYNetworkEnvironmentDev;
        _timeOut = 30;
        
        // 初始化默认公共参数
        _mutableCommonParameters = [NSMutableDictionary dictionary];
        _mutableCommonParameters[@"device"] = @"iOS";
        _mutableCommonParameters[@"version"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        // 初始化默认公共 Header
        _mutableCommonHeaders = [NSMutableDictionary dictionary];
        _mutableCommonHeaders[@"Content-Type"] = @"application/json";
        
        // 初始化默认 BaseURL
        _devBaseUrl = @"https://dev-api.example.com";
        _stagingBaseUrl = @"https://staging-api.example.com";
        _releaseBaseUrl = @"https://api.example.com";
    }
    
    return self;
}

- (NSString *)currentBaseUrl {
    switch(self.env){
        case XYNetworkEnvironmentDev:
            return self.devBaseUrl;
        case XYNetworkEnvironmentStaging:
            return self.stagingBaseUrl;
        case XYNetworkEnvironmentRelease:
            return self.releaseBaseUrl;
    }
}

- (NSDictionary *)commonParams {
    return [self.mutableCommonParameters copy];
}

- (NSDictionary *)commonHeaders {
    return [self.mutableCommonHeaders copy];
}

- (void)addCommonParams:(id)value forKey:(NSString *)key {
    if (value && key) {
        [self.mutableCommonParameters setObject:value forKey:key];
    }
}

- (void)removeCommonParamsForKey:(NSString *)key {
    if (key) {
        [self.mutableCommonParameters removeObjectForKey:key];
    }
}

- (void)addCommonHeaders:(id)value forKey:(NSString *)key {
    if (value && key) {
        self.mutableCommonHeaders[key] = value;
    }
}

- (void)removeCommonHeaderForKey:(NSString *)key {
    if (key) {
        [self.mutableCommonHeaders removeObjectForKey:key];
    }
}


@end
