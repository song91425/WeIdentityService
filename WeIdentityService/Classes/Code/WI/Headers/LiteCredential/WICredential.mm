//
//  WICredential.m
//  HKard
//
//  Created by Junqi on 2020/9/8.
//  Copyright © 2020 tank. All rights reserved.
//

#import "WICredential.h"
#import "WIConfig.h"
#import "WICryptoUtils.h"
#import "YYModel.h"
#import "WISortDictionaryByKeys.h"
#import <WCDB/WCDB.h>
#import "WIDBPersistence.h"
#import "WISDKLog.h"
//static NSString* const WI_PROOF_HASH_SIGN = @"hash";
//static NSString* const WI_PROOF_KEY_SIGN = @"sign";


static NSString* const WI_PROOF_TAG = @"WICredential";
static NSString* const WI_PROOF_SIGN = @"sign";
@implementation WICredential

WCDB_IMPLEMENTATION(WICredential)

WCDB_SYNTHESIZE(WICredential, issuer)
WCDB_SYNTHESIZE(WICredential, id)
WCDB_SYNTHESIZE(WICredential, claim)
WCDB_SYNTHESIZE(WICredential, cptId)
WCDB_SYNTHESIZE(WICredential, issuanceDate)
WCDB_SYNTHESIZE(WICredential, expirationDate)
WCDB_SYNTHESIZE(WICredential, proof)

/// WCDB_SYNTHESIZE_DEFAULT(className, propertyName, defaultValue)支持自定义字段的默认值
///默认值可以是任意的C类型或NSString、NSData、NSNumber、NSNull
//WCDB_SYNTHESIZE_DEFAULT(WICredential, context, [NSNull null])
WCDB_SYNTHESIZE_DEFAULT(WICredential,f,@"1");
WCDB_SYNTHESIZE_DEFAULT(WICredential, type, @"lite1")

//WCDB_SYNTHESIZE(WICredential, type)
WCDB_PRIMARY(WICredential, id) // id 为主键


#pragma mark - Public Method
-(NSString*) getHash
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    NSDictionary *modelDic = [self __toMap];
    NSString *keccak_256_hash = [self __hashFrom:modelDic];
    return keccak_256_hash;
}

-(NSString*) getSignature
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    return self.proof[WI_PROOF_SIGN];
}

- (void)settingSign:(NSString *)sign{
    if (sign != nil) {
        self.proof = @{
            WI_PROOF_SIGN:sign
        };
    }else{
        self.proof = nil;
    }
    
}

/// 计算 signature
/// @param wiKeyPair 在 wallet 中取出 keypair
-(NSString*)__calcSign:(WIKeyPairModel *)wiKeyPair
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    NSString *hash = [self getHash];
    return [WICryptoUtils wedprCryptoSecp256k1Sign:wiKeyPair.privateKey.privateKey message:hash];
}

/// JSON 中含有 proof 字段
-(NSString*) toJson
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:[self __toMap]];
    mutableDic[@"proof"] = self.proof[WI_PROOF_SIGN];
    // 有序 JSON
    NSString *json = [WISortDictionaryByKeys __jsonFromDic:mutableDic];
    return json;
}

- (NSDictionary *)toDictionary
{
    return [self dictionaryValue];
}

-(NSString*) getProofType
{
    return @"Secp256k1";
}

/// @param json  json string
+ (instancetype)fromJson:(NSString *)json
{
    WICredential *credential = [WICredential yy_modelWithJSON:json];
    if (credential.id == nil) {
        credential.id = [[NSUUID UUID] UUIDString];
    }
    NSDictionary *dic = [self __dictionaryWithJSON:json];
    NSString *proof = dic[@"proof"];
    [credential settingSign:proof];
    return credential;
    
}

+ (NSDictionary *)__dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

#pragma mark - Private Method
- (NSString *)__hashFrom:(NSDictionary *)dic
{
    // key 升序的 json
    NSString *orderJson = [WISortDictionaryByKeys __jsonFromDic:dic];

    NSString *keccak_256_hash = [WICryptoUtils wedpr_keccak256:orderJson isHex:NO];

    return keccak_256_hash;
}

/// 筛选出来,现阶段需要使用的字段,保证 iOS && Android Credential 结构的一致性
/// 没有 proof 的 map
- (NSDictionary *)__toMap{
    NSMutableDictionary *jsonMap = [NSMutableDictionary dictionary];
    
    jsonMap[@"$f"] = self.f;
    jsonMap[@"claim"] = self.claim;
    jsonMap[@"cptId"] = @(self.cptId);
    jsonMap[@"expirationDate"] = @(self.expirationDate);
    jsonMap[@"id"] = self.id;
    jsonMap[@"issuanceDate"] = @(self.issuanceDate);
    jsonMap[@"issuer"] = self.issuer;
    jsonMap[@"type"] = self.type;
    return [NSDictionary dictionaryWithDictionary:jsonMap];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@:%@",self.id,self.issuer];
}

@end
