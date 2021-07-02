//
//  WIConfig.h
//  WeIdentityService-WeIdentityService
//
//  Created by tank on 2020/9/21.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface WIConfig : NSObject

typedef NS_ENUM(NSUInteger, WISDKRequestWeIDType) {
    WISDKRequestWeIDBySDK,
    WISDKRequestWeIDByAPP,
};

+ (instancetype) SDKConfig;

// === weid 相关设置
@property (nonatomic, assign) WISDKRequestWeIDType requestType;  // defaule BySDK

@property (nonatomic, copy) NSString *weIdURL; // 设置请求的url
@property (nonatomic, copy) NSString *bac004URL;  // 设置请求的url
@property (nonatomic, copy) NSString *bac005URL;  // 设置bac005请求的url

@property (nonatomic, copy) NSString *invokerWeId; //  default "admin"
@property (nonatomic, copy) NSString *v;           //  default "1.0.0"

/// 存取私钥和 weid 的对应关系
/// @param weid  weid
/// @param privateKey private key
- (void)_saveWeid:(NSString *)weid privateKey:(NSString *)privateKey;

/// 通过 weid 获取私钥
/// @param weid weid
- (NSString *)_getPrivateKeyBy:(NSString *)weid;



@end

NS_ASSUME_NONNULL_END
