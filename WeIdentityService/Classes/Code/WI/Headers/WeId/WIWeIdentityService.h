//
//  WIWeIdentityService.h
//  WeIdentityService
//
//  Created by tank on 2020/9/14.
//

#import <Foundation/Foundation.h>
#import "WIDocument.h"
#import "WIKeyPairModel.h"
#import "WIConfig.h"
#import "WINetworkProtocal.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeIdInfo : NSObject

@property (nonatomic, copy) NSString* weId;
@property (nonatomic, copy) NSString*keyId;

@property (nonatomic, strong) WIKeyPairModel*keyPair;
@property (nonatomic, strong) WIDocument*wiDocument;

+ (instancetype)infoWithWeId:(NSString *)weId keyId:(NSString *)keyId
                     keyPair:(WIKeyPairModel *)keyPair document:(WIDocument *)document;

- (NSString *)toJson;
@end


@interface WIWeIdentityService : NSObject

/// 单例类
+ (instancetype) sharedService;

///  当 requestType 设置为 WISDKRequestWeIDByAPP 的时候, APP 需要实现协议,代发网络请求
@property (nonatomic, weak) id<WINetworkProtocal> requestDelegate;


/// 通过交易密码创建 weid
/// @param transPwd 交易密码
/// @param result   回调结果
- (void)createWeIdWithTransPwd:(NSString *)transPwd callback:(void(^)(BOOL succeed, WeIdInfo *info, NSError *error))result;

/// 通过 weid 获取 keypair
/// @param weId weid
/// @param keyId keyid
/// @param result 请求结果回调
//- (void)getKeyPairByWeId:(NSString *)weId keyId:(NSString *)keyId callback:(void(^)(BOOL succeed, WIKeyPair *keyPair))result;


/// 通过 pubkey list 获取 weid list
/// @param publicKeyList pubkey list
/// @param callback 回调
-(void)getWeIdByPubKeyList:(NSArray *)publicKeyList callback:(void(^)(BOOL success,NSString *msg,NSArray *weIdList))callback;

/// 根据Authority Issuer机构名获取公钥等信息
/// @param weId WeIdentity DID，与SDK直接调用的方式入参要求一致
/// @param callback 请求结果回调
- (void)getWIDocumentByWeId:(NSString *)weId
                   callback:(void (^)(BOOL, WIDocument * , NSError * ))callback;
@end

NS_ASSUME_NONNULL_END
