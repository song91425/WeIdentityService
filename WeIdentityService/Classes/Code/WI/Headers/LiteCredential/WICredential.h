//
//  WICredential.h
//  HKard
//
//  Created by Junqi on 2020/9/8.
//  Copyright © 2020 tank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WIBaseModel.h"
#import "WIKeyPairModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 注意:
 1. WICredential 中,id / credentialId 都是一个东西,唯一标识的字符串 uuid
 2. context 字段写死, 构造的时候不需要外部传递
 3. $f 字段写死, @"1"
 4. type 字段写死
 
 */
@interface WICredential : WIBaseModel

/// 目前为空，toJson不需要传这个
@property (nonatomic, copy) NSString *context;

/// Required: The credential ID.
@property (nonatomic, copy) NSString *id;

/// Required: The CPT type in standard integer format.
@property (nonatomic, assign)  int cptId;

/// Required: The issuer WeIdentity DID.
@property (nonatomic, copy) NSString *issuer;

/// Required: The create date.
@property (nonatomic, assign)  int issuanceDate;

/// Required: The expire date.
@property (nonatomic, assign)  int expirationDate;

/// Required: The claim data.
@property (nonatomic, copy) NSDictionary *claim;

/// 默认值为 "1"
@property (nonatomic, copy) NSString *f;

/// Required: the signature of Credential
@property (nonatomic, copy) NSDictionary<NSString *,NSString *> *proof;

/// 用来存储一些临时数据的map，比如hash，sign等
//@property (nonatomic, copy) NSDictionary *proof;

/// The credential type default is VerifiableCredential.
/// todo 暂时没有用
/// 0. VerifiableCredential
/// 1. CredentialType
/// warning: iOS 使用字符串
@property (nonatomic, copy) NSString *type;

+ (instancetype)fromJson:(NSString *)json;

// hash 值不含 proof
-(NSString*) getHash;

// json 值含 proof (proof 值就是 signature 值)
-(NSString*) toJson;

- (void)settingSign:(NSString *)sign;

// Credential 的 proof 字段
-(NSString*) getSignature;

-(NSString*) getProofType;

@end

NS_ASSUME_NONNULL_END
