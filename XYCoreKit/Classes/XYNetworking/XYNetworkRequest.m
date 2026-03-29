//
//  XYNetworkRequest.m
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import "XYNetworkRequest.h"
#import "XYNetworkManager.h"

@implementation XYNetworkRequest

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _method = XYHTTPMethodGET;
        _cachePolicy = XYNetworkCachePolicyNetworkOnly;
        _needCommonParams = YES;
        _needToken = YES;
        _requestId = [[NSUUID UUID] UUIDString];
    }
    
    return self;
}

- (void)startWith:(XYNetworkSuccessBlock)success failure:(XYNetWorkFailureBlock)failure {
    [[XYNetworkManager shareManager] startRequest:self success:success failure:failure];
}

- (void)cancel {
    [[XYNetworkManager shareManager] cancelRequest:self];
}

@end
