//
//  ServiceManager.m
//  AFNetworking
//
//  Created by 万晓迪 on 2026/3/29.
//

#import "ServiceManager.h"

@interface ServiceManager ()

@property (nonatomic, strong) NSMutableDictionary *services;

@property (nonatomic, assign) int ttt;

@end

@implementation ServiceManager

+ (instancetype)shared {
    static id ins;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        ins = [[self alloc] init];
    });
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _services = [NSMutableDictionary new];
    }
    
    return self;
}


- (void)registerService:(Protocol *)proto imp:(id)imp {
    
    NSString *key = NSStringFromProtocol(proto);

    if (key && imp) {
        [self.services setValue:imp forKey:key];
    }
    
}

- (id)getService:(Protocol *)proto {
    return self.services[NSStringFromProtocol(proto)];
}

@end
