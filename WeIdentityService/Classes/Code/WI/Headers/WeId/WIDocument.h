//
//  WeIdDocument.h
//  HKard
//
//  Created by Junqi on 2020/9/8.
//  Copyright © 2020 tank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WIDocumentPublicKey.h"
#import "WIDocumentAuthentication.h"
#import "WIDocumentPublicKey.h"
NS_ASSUME_NONNULL_BEGIN

@interface WIDocument : NSObject

+ (instancetype) fromJson:(NSString*)weIdDocumentJson;

// TODO: 这个是 junqi 定义的和后台返回的字段不一致.
//这个id即weid字段
@property (nonatomic, copy) NSString *id;
//weid创建时间
@property (nonatomic, assign)  NSInteger created;
//weid属性更新时间
@property (nonatomic, assign)  NSInteger updated;
//这个array存放PublicKeyProperty
@property (nonatomic, copy)NSArray<WIDocumentPublicKey*>  *publicKey;
//这个array存放AuthenticationProperty
@property (nonatomic, copy)NSArray<WIDocumentAuthentication*>  *authentication;
//这个array存放ServiceProperty
@property (nonatomic, retain) NSMutableArray *servicePropertyList;

-(NSString *)getKeyId;

-(NSString*) toJson;

//TODO: 和Android 核对逻辑
/// 从 self.publicKey 中,获取指定的 weid
/// @param keyId  keyId
- (WIDocumentPublicKey *)getPublicKeyByKeyId:(NSString *)keyId;

- (NSDictionary<NSString *, WIDocumentPublicKey *> *)getPublicKeyList;


/// 通过 public key 获取 keyid
/// @param hexPubKey 创建 weid 用的公钥
/// @param isHex           document对象里面的数据格式, 当前后台返回的 document 数据是 B64 格式的
- (NSString *)getKeyIdByPublicKey:(NSString *)hexPubKey isHexDocument:(BOOL)isHex;
@end

NS_ASSUME_NONNULL_END


//(lldb) po response
//{
//    errorCode = 0;
//    errorMessage = success;
//    respBody =     {
//        "@context" = "https://github.com/WeBankFinTech/WeIdentity/blob/master/context/v1";
//        authentication =         (
//                        {
//                publicKey = "did:weid:298:0x2d7bbf655d91088e93d3cb3b3fa6f6a906d0304a#keys-0";
//                revoked = 0;
//                type = Secp256k1;
//            }
//        );
//        created = 1600512927;
//        id = "did:weid:298:0x2d7bbf655d91088e93d3cb3b3fa6f6a906d0304a";
//        publicKey =         (
//                        {
//                id = "did:weid:298:0x2d7bbf655d91088e93d3cb3b3fa6f6a906d0304a#keys-0";
//                owner = "did:weid:298:0x2d7bbf655d91088e93d3cb3b3fa6f6a906d0304a";
//                publicKey = "BGTwBLQdFOK3N4qYTZFu5dJkKhMOFkleRR968kbFnh5zEzzIz2W8ckehYMrIM7iMzkjkZp+OErLsrB3E9Cg1odQ=";
//                revoked = 0;
//                type = Secp256k1;
//            }
//        );
//        service =         (
//        );
//        updated = "<null>";
//    };
//}
