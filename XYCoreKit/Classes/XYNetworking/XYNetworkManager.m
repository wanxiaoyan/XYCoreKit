//
//  XYNetworkManager.m
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import "XYNetworkManager.h"
#import "XYNetWorkConfig.h"
#import "XYNetworkRespose.h"
#import <AFNetworking/AFNetworking.h>

@interface XYNetworkManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong) NSMutableDictionary *requestTasks; // 管理正在进行的请求

@property (nonatomic, strong) dispatch_queue_t taskQueue; // 线程安全队列

@end

@implementation XYNetworkManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)shareManager {
    static XYNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[XYNetWorkConfig shareConfig].currentBaseUrl]];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        _requestTasks = [NSMutableDictionary dictionary];
        _taskQueue = dispatch_queue_create("com.xynetworking.taskQueue", DISPATCH_QUEUE_SERIAL);
        
        // 监听环境变化，更新 BaseURL
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(environmentDidChange)
                                                     name:@"XYNetworkEnvironmentDidChangeNotification"
                                                   object:nil];
        
    }
    
    return self;
}


- (void)startRequest:(XYNetworkRequest *)request success:(XYNetworkSuccessBlock)success failure:(XYNetWorkFailureBlock)failure {
    
    // 1.拼接完整的url
    NSString *fullUrl = [[XYNetWorkConfig shareConfig].currentBaseUrl stringByAppendingString:request.requestPath];
    
    //2. 拼接公参
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:request.params];
    if (request.needCommonParams) {
        [allParams addEntriesFromDictionary:[XYNetWorkConfig shareConfig].commonParams];
    }
    
    // 3.添加token
    if (request.needToken) {
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUserToken"];
        if (token) {
            allParams[@"token"] = token;
        }
    }
    
    // 4.添加header
    [[XYNetWorkConfig shareConfig].commonHeaders enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL * _Nonnull stop) {
        [self.sessionManager.requestSerializer setValue:value forKey:key];
    }];
    
    // 5.缓存策略处理，仅 GET 请求支持缓存，这里简化实现，可扩展
    
    if (request.cachePolicy == XYNetworkCachePolicyCacheThenNetwork && request.method == XYHTTPMethodGET) {
        [self loadCacheForRequest:request completion:^(XYNetworkRespose * _Nullable cacheResponse) {
            if (cacheResponse) {
                // 先返回缓存
                if (success) success(cacheResponse);
            }
            // 再请求网络并更新缓存
            [self performNetworkRequest:request fullUrl:fullUrl params:allParams success:success failure:failure];
        }];
        return;
    }
    
    // 6. 默认：直接请求网络
    [self performNetworkRequest:request fullUrl:fullUrl params:allParams success:success failure:failure];
    
}


- (void)performNetworkRequest:(XYNetworkRequest *)request fullUrl:(NSString *)fullUrl params:(NSDictionary *)params success:(XYNetworkSuccessBlock)success failure:(XYNetWorkFailureBlock)failure {
    
    // 1.定义请求完成后的统一处理
    void(^handleSuccessResponse)(NSURLSessionDataTask * _Nonnull, _Nullable id) = ^(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject) {
        // 移除请求任务
        [self removeRequestTaskForIdentifier:request.requestId];
        
        // 解析响应
        XYNetworkRespose *response = [[XYNetworkRespose alloc] initWithJsonObject:responseObject modelClass:request.responseModelClass];
        
        if (response.isSuccess) {
            // 业务成功：保存缓存（如果是 GET 请求）
            if (request.method == XYHTTPMethodGET && request.cachePolicy != XYNetworkCachePolicyIngoreCache) {
                [self saveCache:responseObject forRequest:request];
            }
            if (success) success(response);
        } else {
            // 业务错误处理
            [self handleBusinessError:response failure:failure];
        }
    };
    
    void(^handleFailureResponse)(NSURLSessionDataTask * _Nonnull,  NSError* _Nullable) = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        // 移除请求任务
        [self removeRequestTaskForIdentifier:request.requestId];
        
        if (error) {
            // 网络错误处理
            [self handleNetworkError:error failure:failure];
            return;
        }
    };
    
    // 根据 HTTP 方法发起请求
    NSURLSessionDataTask *task = nil;
    switch (request.method) {
        case XYHTTPMethodGET:
            task = [self.sessionManager GET:fullUrl parameters:params headers:nil progress:nil success:handleSuccessResponse failure:handleFailureResponse];
            break;
        case XYHTTPMethodPOST:
            task = [self.sessionManager POST:fullUrl parameters:params headers:nil progress:nil success:handleSuccessResponse failure:handleFailureResponse];
            break;
        case XYHTTPMethodPUT:
            task = [self.sessionManager PUT:fullUrl parameters:params headers:nil success:handleSuccessResponse failure:handleFailureResponse];
            break;
        case XYHTTPMethodDELETE:
            task = [self.sessionManager DELETE:fullUrl parameters:params headers:nil success:handleSuccessResponse failure:handleFailureResponse];
            break;
    }
    
    // 保存请求任务
    if (task) {
        [self addRequestTask:task forIdentifier:request.requestId];
    }
}


#pragma mark - 错误统一处理
- (void)handleNetworkError:(NSError *)error failure:(XYNetWorkFailureBlock)failure {
    
    // 可以在这里做统一的网络错误提示，如弹窗
    NSLog(@"[HYNetworking] 网络错误: %@", error.localizedDescription);
    
    // 区分错误类型，给用户更友好的提示
    NSString *errorMsg = @"网络连接失败，请检查网络";
    if (error.code == NSURLErrorTimedOut) {
        errorMsg = @"请求超时，请稍后重试";
    } else if (error.code == NSURLErrorNotConnectedToInternet) {
        errorMsg = @"无网络连接，请检查网络设置";
    }
    NSError *customError = [NSError errorWithDomain:@"HYNetworkErrorDomain"
                                               code:error.code
                                           userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
    
    if (failure) {
        failure(customError);
    }
}

- (void)handleBusinessError:(XYNetworkRespose *)response failure:(XYNetWorkFailureBlock)failure {
    // 可以在这里做统一的业务错误处理，如 Token 失效跳登录
    if (response.code == 401) { // 假设 401 是 Token 失效
        NSLog(@"[HYNetworking] Token 失效，跳转到登录页");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XYUserTokenInvalidNotification" object:nil];
    }
    
    // 构造业务错误
    NSError *businessError = [NSError errorWithDomain:@"HYBusinessErrorDomain"
                                                   code:response.code
                                               userInfo:@{NSLocalizedDescriptionKey: response.message ?: @"请求失败"}];
    if (failure) failure(businessError);
}

#pragma mark - 缓存管理（简化实现，可扩展为 YYCache 等）
- (void)saveCache:(id)responseObject forRequest:(XYNetworkRequest *)request {
    // 这里用 NSUserDefaults 简化实现，实际项目建议用 YYCache/SDWebImage 等专业缓存库
    NSString *cacheKey = [self cacheKeyForRequest:request];
    if (cacheKey && responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:cacheKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)loadCacheForRequest:(XYNetworkRequest *)request completion:(void(^)(XYNetworkRespose * _Nullable))completion {
    NSString *cacheKey = [self cacheKeyForRequest:request];
    id cacheObject = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
    
    if (cacheObject) {
        // 检查缓存是否过期
        if (request.cacheValidTime > 0) {
            // 这里简化实现，实际需要记录缓存时间
        }
        XYNetworkRespose *cacheResponse = [[XYNetworkRespose alloc] initWithJsonObject:cacheObject modelClass:request.responseModelClass];
        if (completion) completion(cacheResponse);
    } else {
        if (completion) completion(nil);
    }
}


- (NSString *)cacheKeyForRequest:(XYNetworkRequest *)request {
    // 生成缓存 Key：URL + 参数
    NSString *fullURL = [[XYNetWorkConfig shareConfig].currentBaseUrl stringByAppendingString:request.requestPath];
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:request.params];
    if (request.needCommonParams) {
        [allParams addEntriesFromDictionary:[XYNetWorkConfig shareConfig].commonParams];
    }
    // 将参数排序后拼接成字符串，保证 Key 稳定
    NSArray *sortedKeys = [allParams.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString *paramString = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [paramString appendFormat:@"%@=%@", key, allParams[key]];
    }
    return [NSString stringWithFormat:@"XYNetworkCache_%@_%@", fullURL, paramString];
}

#pragma mark - 请求任务管理（线程安全）
- (void)addRequestTask:(NSURLSessionDataTask *)task forIdentifier:(NSString *)identifier {
    dispatch_sync(self.taskQueue, ^{
        self.requestTasks[identifier] = task;
    });
}

- (void)removeRequestTaskForIdentifier:(NSString *)identifier {

    dispatch_sync(self.taskQueue, ^{
        [self.requestTasks removeObjectForKey:identifier];
    });
}

- (void)cancelRequest:(XYNetworkRequest *)request {
    dispatch_sync(self.taskQueue, ^{
        NSURLSessionDataTask *task = self.requestTasks[request.requestId];
        if (task) {
            [task cancel];
            [self.requestTasks removeObjectForKey:request.requestId];
        }
    });
}

- (void)cancelAllRequests {
    dispatch_sync(self.taskQueue, ^{
        [self.requestTasks.allValues makeObjectsPerformSelector:@selector(cancel)];
        [self.requestTasks removeAllObjects];
    });
}


#pragma mark - 环境变化处理
- (void)environmentDidChange {
    // 更新 BaseURL
//    self.sessionManager.baseURL = [NSURL URLWithString:[XYNetWorkConfig shareConfig].currentBaseUrl];
}


@end
