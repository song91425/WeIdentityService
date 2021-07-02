//
//  WIEvidenceService.h
//  HKard
//
//  Created by tank on 2020/9/1.
//  Copyright © 2020 tank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WICredential.h"
#import "WIEvidence.h"
NS_ASSUME_NONNULL_BEGIN

@interface WIHashInfo : NSObject

@property (nonatomic, copy) NSString *hash_;
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, copy) NSString *log;

- (NSDictionary *)toMap;

@end

@interface WIEvidenceService : NSObject

- (void)createEvidenceWithGroupId:(int)groupId
                         hashInfo:(WIHashInfo *)hashInfo
                         callback:(void(^)(int status,BOOL succeed,NSError *  error)) callback;

//- (void)createEvidenceWithCredential:(WICredential *)credential
//                                 log:(NSString *)log
//                            callback:(void(^)(int status,BOOL succeed,NSError *error)) callback;

/// 批量代理创建存证,作用： 批量创建存证，其他机构可以使用存证用于验证,目前上线后台控制最大50个，后续可配置
/// @param arr  参数数组
/// @param callback 回调
- (void)createEvidenceBatchWithGroupId:(int)groupId
                                  list:(NSArray<WIHashInfo *> *)arr
                              callback:(void(^)(int status,BOOL succeed,NSError *error)) callback;

/// 根据LiteCredential 的 hash 值，获取存证信息
/// @param hashValue  Credential 的 hash 值
/// @param callback     回调
- (void)getEvidenceWithGroupId:(int)groupId
                     hashValue:(NSString *)hashValue
                      callback:(void (^) (BOOL succeed,WIEvidence *evidence,NSError *error)) callback;

- (void)verifyWithWeId:(NSString *)issuerWeId
            credential:(WICredential *)credential
          evidenceInfo:(WIEvidence *)evidenceInfo
              callback:(void (^) (BOOL succeed,WIEvidence *evidence,NSError *error)) callback;

- (void)verifyWithWeId:(NSString *)issuerWeId
       issuerWeIdKeyId:(NSString *)issuerWeIdKeyId
            credential:(WICredential *)credential
          evidenceInfo:(WIEvidence *)evidenceInfo
              callback:(void (^) (BOOL succeed,WIEvidence *evidence,NSError *error)) callback;

- (void)verifyWithIssuerWeIdPublicKey:(WIPublicKey *)issuerWeIdPublicKey
                           credential:(WICredential *)credential
                         evidenceInfo:(WIEvidence *)evidenceInfo
                             callback:(void (^) (BOOL succeed,WIEvidence *evidence,NSError *error)) callback;

@end

NS_ASSUME_NONNULL_END
