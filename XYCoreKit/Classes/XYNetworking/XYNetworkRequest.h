//
//  XYNetworkRequest.h
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import <Foundation/Foundation.h>
@class XYNetworkRespose;

NS_ASSUME_NONNULL_BEGIN

// 请求方法
typedef enum : NSUInteger {
    XYHTTPMethodGET,
    XYHTTPMethodPOST,
    XYHTTPMethodPUT,
    XYHTTPMethodDELETE
} XYHTTPMethod;

typedef enum : NSUInteger {
    XYNetworkCachePolicyIngoreCache,        // 忽略缓存，之请求网络
    XYNetworkCachePolicyCacheThenNetwork,   // 先返回缓存，在请求接口更新缓存
    XYNetworkCachePolicyCacheOnly,          // 只使用缓存，无缓存则失败
    XYNetworkCachePolicyNetworkOnly         // 只请求网络，不使用缓存（默认）
} XYNetworkCachePolicy;

// 请求回调Block
typedef void(^XYNetworkSuccessBlock)(XYNetworkRespose *response);
typedef void(^XYNetWorkFailureBlock)(NSError *error);


@interface XYNetworkRequest : NSObject

/// 请求路径（如 /user/login，会自动拼接 BaseURL）
@property (nonatomic, copy) NSString *requestPath;

/// 请求方法
@property (nonatomic, assign) XYHTTPMethod method;

/// 请求参数，不包含公参，公参会自动拼接
@property (nonatomic, strong) NSDictionary *params; //!< 请求参数，不包含公参，公参会自动拼接

/// 缓存策略， NetworkOnly
@property (nonatomic, assign) XYNetworkCachePolicy cachePolicy;

/// 缓存有效时间
@property (nonatomic, assign) NSTimeInterval cacheValidTime;

/// 是否需要公参
@property (nonatomic, assign) BOOL needCommonParams;

/// 是否需要token
@property (nonatomic, assign) BOOL needToken;

/// 请求唯一标识，自动生成，用于取消请求
@property (nonatomic, copy) NSString *requestId;

/// 响应 Model 类（可选，若设置会自动将 JSON 转为该类实例）
@property (nonatomic, assign, nullable) Class responseModelClass;

/// 开始请求
- (void)startWith:(XYNetworkSuccessBlock)success failure:(XYNetWorkFailureBlock)failure;

/// 取消请求
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
