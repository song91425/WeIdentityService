//
//  WICredentialService.m
//  AFNetworkActivityLogger
//
//  Created by tank on 2020/9/14.
//

#import "WICredentialService.h"
#import "WIWeIdentityService.h"
#import "CocoaSecurity.h"
#import "WICryptoUtils.h"
#import "WIConfig.h"
#import "WISortDictionaryByKeys.h"
#import "WIDBPersistence.h"
#import "WIKeychainPersistence.h"
#import "WCTDatabase.h"
#import "WICredential+WCTTableCoding.h"

#import "WIManager.h"
#import "WIHDWallet.h"
#import "WIHDWalletInternalService.h"
#import "WISDKLog.h"
API_AVAILABLE(ios(10.0))
@interface WICredentialService()

@end

@implementation WICredentialService


static WICredentialService *service = nil;

+ (instancetype) sharedService
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [WICredentialService new];
    });
    return service;
}

- (void)createCredentialWithCptId:(int)cptId
                   credentialType:(NSString*)credentialType
                       issuerWeId:(NSString*)weId
                            keyId:(NSString *)keyId
                         transPwd:(NSString *)transPwd
                     issuanceDate:(int)issuanceDate
                   expirationDate:(int)expirationDate
                            claim:(NSDictionary *)claim
                         callback:(void(^)(BOOL, WICredential *, NSString *))callback
{
    // 获取 keypair
    [[WIHDWalletInternalService sharedService] getWIKeyPairByWeId:weId keyId:keyId transPwd:transPwd callback:^(WIKeyPairModel * _Nonnull keyPair) {
        if (keyPair != nil) {
            // 获取 keypair 成功
            WICredential *credential = [WICredential new];
            credential.id = [[NSUUID UUID] UUIDString]; // 产生 uuid
            credential.cptId = cptId;
            credential.issuer = weId;
            credential.issuanceDate   = issuanceDate;
            credential.expirationDate = expirationDate;
            credential.claim = claim;
            credential.f = @"1";
            credential.type = @"lite1";
            //NSString *hash = [credential getHash];
            NSString *sign = [self __calculateProof:[keyPair privateKeyString] credential:credential];
            [credential settingSign:sign];

            callback(YES,credential,nil);
        }else{
            // 获取 keypair 失败
            callback(NO,nil,@"get WIKeyPair for specific publicKey failed");
        }
    }];
}

- (void)saveCredential:(WICredential *)credential callback:(void (^)(BOOL, NSString*))callback{
    [[[WIManager manager] credentialStore] saveCredential:credential callback:callback];
}

- (void)getCredentialById:(NSString *)credentialId callback:(void (^)(BOOL,WICredential*, NSString*))callback{
    [[[WIManager manager] credentialStore] loadByCredentialId:credentialId callback:callback];
}

- (BOOL)verify:(WICredential*)credential
issuerWeIdPublicKey:(NSString *)issuerWeIdPublicKey{
    NSString *hash = [credential getHash];
    NSString *sign = [credential getSignature];
    BOOL res = [WICryptoUtils wedprSecp256k1VerifySign:issuerWeIdPublicKey message:hash signature:sign];
    if (res) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"wedprSecp256k1VerifySign succeed!!!");
    }else{
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"wedprSecp256k1VerifySign failed!!!");
    }
    return res;
}

- (void)verifyWithIssuerWeId:(NSString *)issuerWeId credential:(WICredential *)credential callback:(void (^)(BOOL,NSString*))callback{
    [self __verifyWithIssuerWeId:issuerWeId issuerWeIdKeyId:nil credential:credential callback:callback];
}

- (void)__verifyWithIssuerWeId:(NSString *)issuerWeId issuerWeIdKeyId:(NSString *)keyId credential:(WICredential *)credential callback:(void (^)(BOOL,NSString*))callback{
    [[WIWeIdentityService sharedService] getWIDocumentByWeId:issuerWeId
                                                      callback:^(BOOL succeed, WIDocument * _Nonnull document, NSError * _Nonnull error) {
        NSError *err = [NSError errorWithDomain:@"weid"
                                           code:-1
                                       userInfo:@{
                                           NSLocalizedDescriptionKey:@"get document failed"}
                        ];
        if (!succeed)
            callback(NO,err.localizedDescription);
        else if(keyId != nil){
            WIDocumentPublicKey *pubKey = [document getPublicKeyByKeyId:keyId];
            [self __verifyByPublicKey:pubKey credential:credential publicKeyList:nil callback:callback];
        }else{
            NSDictionary *publicKeyList = [document getPublicKeyList];
            NSEnumerator<WIDocumentPublicKey *> *enumerator = [publicKeyList.allValues objectEnumerator];
            
            [self __verifyByPublicKeyList:enumerator credential:credential callback:callback];
        }
    }];
}

- (void)__verifyByPublicKey:(WIDocumentPublicKey *)pubKey
                 credential:(WICredential *)credential
              publicKeyList:(NSEnumerator<WIDocumentPublicKey *> *)publicKeyListEnumerator
                   callback:(void (^)(BOOL,NSString*))callback{
    if (pubKey != nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"verify by special publicKey");
        NSString *pubKeyHex = pubKey.publicKey;
        [self verifyWithPubKey:pubKeyHex credential:credential callback:^(BOOL success) {
            if (success) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"verify success");
                callback(YES,@"verify success");
            }else{
                [self __verifyByPublicKeyList:publicKeyListEnumerator credential:credential callback:callback];
            }
        }];
    }else{
        [self __verifyByPublicKeyList:publicKeyListEnumerator credential:credential callback:callback];
    }
}

- (void)__verifyByPublicKeyList:(NSEnumerator<WIDocumentPublicKey *> *)publicKeyListEnumerator
                     credential:(WICredential *)credential callback:(void (^)(BOOL,NSString*))callback{
    if (WIDocumentPublicKey *pubKey = [publicKeyListEnumerator nextObject]) {
        [self __verifyByPublicKey:pubKey credential:credential publicKeyList:publicKeyListEnumerator callback:callback];
    }else{
        callback(NO,@"verify failed.");
    }
}


- (NSDictionary *)__dictionaryWithJsonString:(NSString *)jsonString{
    NSAssert(jsonString != nil, @"JSON string is nil value!!!");
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        return nil;
    }
    NSAssert(err == nil, @"JSON string to dictionary failed!!!");
    return dic;
}

#pragma mark - Private Method
/**针对上述的Json结构
 删掉proof字段, 然后对json的数据按 key 进行字母序"升序"排序，并紧凑化处理（即json压缩）。
 然后对新生成的Json结构使用keccak 256 hash算法计算hash
 再使用ECDSA 签名算法进行签名（椭圆曲线的参数使用secp256k1）
 */
- (NSString *)__calculateProof:(NSString *)privateKey
                    credential:(WICredential *)credential{
    NSDictionary *modelDic = [credential dictionaryValue];
    NSString *keccak_256_hash = [self __hashFrom:modelDic];
    NSString *ecdsa = [WICryptoUtils wedprCryptoSecp256k1Sign:privateKey message:keccak_256_hash];
    return ecdsa;
}

- (NSString *)__dictionaryToJson:(NSDictionary *)dic{
    return [WISortDictionaryByKeys __jsonFromDic:dic];
}


- (NSString *)__hashFrom:(NSDictionary *)dic{
    NSString *orderJson = [self __dictionaryToJson:dic];
//    NSString *hexStr = [WICryptoUtils hexStringFromString:orderJson];
    NSString *keccak_256_hash = [WICryptoUtils wedpr_keccak256:orderJson isHex:NO];
    //     NSLog(@"==> in %@",dic);
    //     NSLog(@"==> out orderJson:%@",orderJson);
    //     NSLog(@"==> out keccak_256_hash:%@",keccak_256_hash);
    return keccak_256_hash;
}


#pragma mark - Core Data Saving support

- (NSString *)__hexStringFromBase64String:(NSString *)base64{
    CocoaSecurityDecoder *decoder = [CocoaSecurityDecoder new];
    NSData *myD = [decoder base64:base64];
    
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    //    NSLog(@"base 64:%@",base64);
    //    NSLog(@"hex    :%@",hexStr);
    return hexStr;
    
}

- (NSDictionary *)dictionaryValue{
    NSArray *propertyKeys = [self __properties:self];
    NSDictionary *originDic = [self dictionaryWithValuesForKeys:propertyKeys];
    NSMutableDictionary *tmp = [NSMutableDictionary new];
    
    // Dictionary de duplication
    for (NSString *key in propertyKeys) {
        if (![originDic[key] isKindOfClass:[NSNull class]]) {
            if ([originDic[key] isKindOfClass:[WIBaseModel class]]) {
                tmp[key] = [(WIBaseModel *)originDic[key] dictionaryValue];
            }else if([originDic[key] isKindOfClass:[NSNumber class]] || [originDic[key] isKindOfClass:[NSString class]]|| [originDic[key] isKindOfClass:[NSDictionary class]]){
                //TODO: 重构======>>>>
                tmp[key] = originDic[key];
            }else{
                NSAssert(YES, @"HKBaseModel Parse Error");
            }
        }else{
            NSAssert(YES, @"HKBaseModel Parse Error, Empty Key.");
        }
    }
    return [NSDictionary dictionaryWithDictionary:tmp];
}

//TODO: Class object OK?
-(NSArray *)__properties:(id)obj{
    Class cls = [obj class];
    NSMutableArray *propertyKeys = [NSMutableArray array];
    while ([cls superclass]) {
        uint outCount ,i;
        objc_property_t *properties = class_copyPropertyList(cls, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char* propertyName = property_getName(property);
            if (propertyName) {
                [propertyKeys addObject:[NSString stringWithUTF8String:propertyName]];
            }
        }
        free(properties);
        cls = [cls superclass];
    }
    return [NSArray arrayWithArray:propertyKeys];
}

- (void)getCredential:(void (^)(BOOL,WICredential*, NSString*))callback{
    
}

@end
