//
//  XYNetWorkConfig.h
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XYNetworkEnvironment) {
    XYNetworkEnvironmentDev,        //开发环境
    XYNetworkEnvironmentStaging,    //预发环境
    XYNetworkEnvironmentRelease     // 线上
};

@interface XYNetWorkConfig : NSObject

@property (nonatomic, assign) XYNetworkEnvironment env;

@property (nonatomic, assign) NSTimeInterval timeOut;

@property (nonatomic, strong) NSDictionary *commonParams;

@property (nonatomic, strong) NSDictionary *commonHeaders;

@property (nonatomic, copy) NSString *devBaseUrl;

@property (nonatomic, copy) NSString *stagingBaseUrl;

@property (nonatomic, copy) NSString *releaseBaseUrl;


+ (instancetype)shareConfig;

- (NSString *)currentBaseUrl;

- (void)addCommonParams:(id)value forKey:(NSString *)key;

- (void)removeCommonParamsForKey:(NSString *)key;

- (void)addCommonHeaders:(id)vakue forKey:(NSString *)key;

- (void)removeCommonHeaderForKey:(NSString *)key;






@end

NS_ASSUME_NONNULL_END
