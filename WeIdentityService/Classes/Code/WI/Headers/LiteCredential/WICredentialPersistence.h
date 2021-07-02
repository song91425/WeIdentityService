//
//  WICredentialPersistence.h
//  WeIdentityService
//
//  Created by tank on 2021/1/4.
//

#import <Foundation/Foundation.h>
#import "WICredential.h"

NS_ASSUME_NONNULL_BEGIN

@interface WICredentialPersistence : NSObject

// TODO: 优化一下命名.
+ (void)initWithDomain:(NSString *)domain encryptDB:(BOOL)encryptDB callback:(void(^)(WICredentialPersistence *, NSError *)) callback;

- (void)saveCredential:(WICredential *)credential
              callback:(void(^)(BOOL,NSString*))callback;

- (void) loadByCredentialId:(NSString *)credentialId
                   callback:(void(^)(BOOL,WICredential*,NSString*))callback;

- (void)deleteCredentialBy:(NSString *)credentialID callback:(void(^)(BOOL))callback;

// debug
- (void) loadByCredentials:(void(^)(BOOL,NSArray*,NSString*))callback;

- (void) __deleteDB;

@end

NS_ASSUME_NONNULL_END
