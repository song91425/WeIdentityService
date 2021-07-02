//
//  WIBAC005AssetService.h
//  WeIdentityService
//
//  Created by lssong on 2021/2/23.
//

#import <Foundation/Foundation.h>
#import <WeIdentityService/WIQueryOwnedAssetModel.h>
#import <WeIdentityService/WIBAC005SendArgsModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface WIBAC005AssetService : NSObject


/// 用户查看某个资产当前持有资产列表
/// @param assetAddress 资产地址
/// @param assetHolder 用户Weid
/// @param index 分页查询起始位置
/// @param num 分页大小
/// @param callback code = 0 查询成功，非0查询失败
-(void) queryOwnedAssetList:(NSString *) assetAddress
                assetHolder:(NSString *)assetHolder
                      index:(int) index
                        num:(int)num
                   callback:(void (^)(NSInteger code, NSArray<WIQueryOwnedAssetModel *> *result, NSError *error)) callback;

/// 用户发送资产给其他用户
/// @param assetAddress 资产地址
/// @param sendAssetArgs 接收资产配置
/// @param callback 发送结果
- (void)send:(NSString *)assetAddress
sendAssetArgs:(WIBAC005SendArgsModel *)sendAssetArgs
    callback:(void (^) (BOOL succeed, NSError *error))callback;

///// 批量发送Bac005资产
///// @param assetAddress 资产地址
///// @param sendAssetArgList 接收资产配置集合
///// @param callback 发送结果
- (void)batchSend:(NSString *)assetAddress
      invokerWeid:(NSString *)invokerWeid
    sendAssetArgs:(NSArray<WIBAC005SendArgsModel *>*)sendAssetArgList
         callback:(void (^) (BOOL succeed, NSError *error))callback;
@end

NS_ASSUME_NONNULL_END
