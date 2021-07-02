//
//  WIManager.h
//  WeIdentityService
//
//  Created by tank on 2020/12/31.
//

#import <Foundation/Foundation.h>
#import "WIWeIdentityService.h"
#import "WICredentialPersistence.h"

NS_ASSUME_NONNULL_BEGIN


@interface WIManager : NSObject

@property (nonatomic, strong) WICredentialPersistence *credentialStore;

/// 初始化的时候调用
/// @param name dbname
/// @param encryptDB 是否加密
+ (void)managerWithName:(NSString *)name encryptDB:(BOOL)encryptDB callback:(void (^)(WIManager *, NSError *))callback;

/// 初始化结束之后,在其它的地方调用
+(instancetype)manager;

//- (void)getPublicKeyByWeId:(NSString *)issuerWeId
//                     keyId:(NSString *)keyId
//                  callback:(void (^) (BOOL,NSString *))callback;

//- (void)addWeIdInfo:(WeIdInfo *)weIdInfo;
//
//- (void)addWeIdInfo:(NSString *)weiId keyId:(NSString *)keyId publicKeyHex:(NSString *)publicKeyHex;

- (void)reset;
@end

NS_ASSUME_NONNULL_END
