//
//  XYNetworkManager.h
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import <Foundation/Foundation.h>

#import "XYNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYNetworkManager : NSObject

+ (instancetype)shareManager;

/// 发起请求，内部使用，外部通过XYNetworkRequest 调用
- (void)startRequest:(XYNetworkRequest *)request success:(XYNetworkSuccessBlock)success failure:(XYNetWorkFailureBlock) failure;

- (void)cancelRequest:(XYNetworkRequest *)request;

- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END
