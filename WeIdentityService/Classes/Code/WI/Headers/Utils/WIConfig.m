//
//  WIConfig.m
//  WeIdentityService-WeIdentityService
//
//  Created by tank on 2020/9/21.
//

#import "WIConfig.h"
#import "AFNetworking.h"
// 根据LiteCredential 的 hash 值，获取存证信息

static WIConfig *config = nil;

@interface WIConfig()

@end

@implementation WIConfig

+ (instancetype) SDKConfig{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [WIConfig new];
    });
    
    return config;
}

- (void)_saveWeid:(NSString *)weid privateKey:(NSString *)privateKey{
    [[NSUserDefaults standardUserDefaults] setObject:privateKey forKey:weid];
}

- (NSString *)_getPrivateKeyBy:(NSString *)weid{
    return [[NSUserDefaults standardUserDefaults] objectForKey:weid];
}

@end
