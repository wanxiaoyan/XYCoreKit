//
//  XYNetworkRespose.h
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYNetworkRespose : NSObject

@property (nonatomic, strong) id rawJsonObject;

@property (nonatomic, assign) NSInteger code;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, strong) id data;

@property (nonatomic, assign) BOOL isSuccess;

- (instancetype)initWithJsonObject:(id)jsonObject modelClass:(Class) modelClass;

@end

NS_ASSUME_NONNULL_END
