//
//  XYNetworkRespose.m
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import "XYNetworkRespose.h"
#import <YYModel/YYModel.h>


@implementation XYNetworkRespose

- (instancetype)initWithJsonObject:(id)jsonObject modelClass:(Class)modelClass {
    self = [super init];
    
    if (self) {
        _rawJsonObject = jsonObject;
        
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = jsonObject;
            _code = [dict[@"code"] integerValue];
            _message = dict[@"msg"] ?: dict[@"message"];
            id rawData = dict[@"data"];
            
            if (jsonObject && modelClass) {
                if ([rawData isKindOfClass:[NSArray class]]) {
                    _data = [NSArray yy_modelArrayWithClass:modelClass json:rawData];
                } else if ([rawData isKindOfClass:[NSDictionary class]]) {
                    _data = [modelClass yy_modelWithJSON:rawData];
                }
            } else {
                _data = rawData;
            }
        }
        
        _isSuccess = (_code == 0);
        
    }
    
    return self;
}

@end
