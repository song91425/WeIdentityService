//
//  WIBAC004AssetService.h
//  WeIdentityService
//
//  Created by tank on 2020/10/26.
//

#import <Foundation/Foundation.h>
#import "WIAssetBalanceModel.h"
#import "WISendAssetArgsModel.h"
#import "WIBAC004AssetModel.h"
#import "WISendAssetResponseModel.h"
#import "WIKeyPairModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WIBAC004AssetService : NSObject

/// 部署 BAC004 合约并构建
/// @param userWeId 传执行的weid，或者传"admin"
/// @param WIKeyPair 秘钥对
/// @param shortName 资产简称
/// @param description 资产描述
/// @param result 成功则返回合约地址
-(void) construct:(NSString *)userWeId
            keyId:(NSString*)keyId
         transPwd:(NSString *)transPwd
        shortName:(NSString *)shortName
      description:(NSString *)description
         callback:(void (^) (BOOL succeed,NSString *assetAddress, NSError *error))result;


/// 发行特定数量的 BAC004 资产
/// @param userWeId 传执行的weid，或者传"admin"
/// @param WIKeyPair 秘钥对
/// @param assetAddress BAC004 智能合约的地址
/// @param recipient 将指定数量的资产发行到这个字段指定的WeID账户
/// @param amount 资产数量
/// @param data 资产数据
/// @param result 成功返回YES
-(void) issue:(NSString *) userWeId
        keyId:(NSString*)keyId
     transPwd:(NSString *)transPwd
 assetAddress:(NSString *)assetAddress
    recipient:(NSString *)recipient
       amount:(NSInteger)amount
         data:(NSString *)data
     callback:(void (^) (BOOL succeed, NSError *error))result;


/// 部署 BAC004 合约，同时发行特定数量的 BAC004 资产
/// @param userWeId 传执行的weid，或者传"admin"
/// @param WIKeyPair 秘钥对
/// @param shortName 资产简称
/// @param description 资产描述
/// @param recipient 将指定数量的资产发行到这个字段指定的WeID账户
/// @param amount 资产数量
/// @param data 资产数据
/// @param result 结果返回 YES 部署成功的合约地址
-(void)constructAndIssue:(NSString *)userWeId
                   keyId:(NSString*)keyId
                transPwd:(NSString *)transPwd
               shortName:(NSString *)shortName
             description:(NSString *)description
               recipient:(NSString *)recipient
                  amount:(NSInteger)amount
                    data:(NSString *)data
                callback:(void (^) (BOOL succeed,NSString *assetAddress, NSError *error))result;


/// 查询BAC004资产余额
/// @param assetAddress 资产地址
/// @param userWeId 用户地址
/// @param result 查找结果
- (void)getBalance:(NSString *)assetAddress
          userWeId:(NSString *)userWeId
          callback:(void (^) (BOOL succeed,WIAssetBalanceModel *model, NSError *error))result;


/// 批量查询用户的BAC004资产余额
/// @param assetAddressList 资产地址集合
/// @param userWeId 用户地址
/// @param result 查询结果
- (void)getBatchBalance:(NSArray<NSString *> *)assetAddressList
               userWeId:(NSString *)userWeId
               callback:(void (^) (BOOL succeed,NSArray<WIAssetBalanceModel *> *models, NSError *error))result;


/// 分页查询用户所有的BAC004资产余额
/// @param userWeId  用户地址
/// @param index  分页查询起始位置
/// @param pageSize 页面大小
/// @param result 查询结果
- (void)getBalanceByWeId:(NSString *)userWeId
                   index:(int)index
                pageSize:(int)pageSize
                callback:(void (^) (BOOL succeed,NSArray<WIAssetBalanceModel *> *models, NSError *error))result;


/// 用户发送资产给其他用户
/// @param assetAddress 资产地址
/// @param userWeId 资产持有者的weid
/// @param WIKeyPair 资产持有者的密钥信息
/// @param invokerWeId 传执行的weid,直接传"admin"
/// @param sendAssetArgs 接收资产配置
/// @param result 发送结果
- (void)send:(NSString *)assetAddress
    userWeId:(NSString *)userWeId
       keyId:(NSString*)keyId
    transPwd:(NSString *)transPwd
 invokerWeId:(NSString *) invokerWeId
sendAssetArgs:(WISendAssetArgsModel *)sendAssetArgs
    callback:(void (^) (BOOL succeed, NSError *error))result;


/// 批量发送Bac004资产
/// @param assetAddress 资产地址
/// @param userWeId 资产持有者的weid
/// @param WIKeyPair 资产持有者的密钥信息
/// @param invokerWeId 传执行的weid,直接传"admin"
/// @param sendAssetArgList 接收资产配置集合
/// @param result 发送结果
- (void)batchSend:(NSString *)assetAddress
         userWeId:(NSString *)userWeId
            keyId:(NSString*)keyId
         transPwd:(NSString *)transPwd
      invokerWeId:(NSString *) invokerWeId
    sendAssetArgs:(NSArray<WISendAssetArgsModel *>*)sendAssetArgList
         callback:(void (^) (BOOL succeed,NSArray<WISendAssetResponseModel *> *models, NSError *error))result;


/// 用户根据资产地址查询基础信息
/// @param assetAddressList 资产地址集合
/// @param result  查询结果
- (void)getBaseInfo:(NSArray <NSString *>*)assetAddressList
           callback:(void (^) (BOOL succeed,NSArray<WIBAC004AssetModel *> *models, NSError *error))result;


/// 用户分页查询其名下资产集成信息
/// @param userWeId 用户weId
/// @param index  分页查询起始位置
/// @param pageSize 页面大小
/// @param result  查询结果
- (void)getBaseInfoByWeId:(NSString *)userWeId
                    index:(int)index
                 pageSize:(int)pageSize
                 callback:(void (^) (BOOL succeed,NSArray<WIBAC004AssetModel *> *models, NSError *error))result;
@end
NS_ASSUME_NONNULL_END

