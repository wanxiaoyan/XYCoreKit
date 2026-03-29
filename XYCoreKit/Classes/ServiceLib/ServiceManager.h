//
//  ServiceManager.h
//  AFNetworking
//
//  Created by 万晓迪 on 2026/3/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceManager : NSObject

+ (instancetype)shared;

- (void)registerService:(Protocol *)proto imp:(id)imp;

- (id)getService:(Protocol *)proto;

@end

NS_ASSUME_NONNULL_END
