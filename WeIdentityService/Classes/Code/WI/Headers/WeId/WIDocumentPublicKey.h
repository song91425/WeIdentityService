//
//  WIDocumentPublicKey.h
//  WeIdentityService
//
//  Created by tank on 2020/9/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 注意: publicKey 返回的是 base64 编码的 public key
@interface WIDocumentPublicKey : NSObject

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *owner;
@property (nonatomic, copy) NSString *publicKey;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) BOOL revoked;

- (NSString *)getKeyId;

@end

NS_ASSUME_NONNULL_END
