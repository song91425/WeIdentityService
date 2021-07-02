//
//  WICredentialService.h
//  AFNetworkActivityLogger
//
//  Created by tank on 2020/9/14.
//

#import <Foundation/Foundation.h>

#import "WICredential.h"
#import "WIDBPersistence.h"

NS_ASSUME_NONNULL_BEGIN

@interface WICredentialService : NSObject
+ (instancetype) sharedService;

#pragma mark - Create WICredential

- (void)createCredentialWithCptId:(int)cptId
                   credentialType:(NSString*)credentialType
                       issuerWeId:(NSString*)weId
                            keyId:(NSString *)keyId
                         transPwd:(NSString *)transPwd
                     issuanceDate:(int)issuanceDate
                   expirationDate:(int)expirationDate
                            claim:(NSDictionary *)claim
                         callback:(void(^)(BOOL, WICredential *, NSString *))callback;

/**
 * 保存Credential
 */
- (void)saveCredential:(WICredential *)credential callback:(void (^)(BOOL, NSString*))callback;

/**
 * 通过credentialId获取Credential
 */
- (void)getCredentialById:(NSString *)credentialId callback:(void (^)(BOOL,WICredential*, NSString*))callback;

- (void)verifyWithIssuerWeId:(NSString *)issuerWeId credential:(WICredential *)credential callback:(void (^)(BOOL,NSString*))callback;

- (void)verify:(NSString *)issuerWeId issuerWeIdKeyId:(NSString *)issuerWeIdKeyId credential:(WICredential *)credential callback:(void (^)(BOOL))callback;

- (void)verifyWithPubKey:(NSString *)issuerWeIdPublicKey credential:(WICredential *)credential callback:(void (^)(BOOL))callback;

@end

NS_ASSUME_NONNULL_END
