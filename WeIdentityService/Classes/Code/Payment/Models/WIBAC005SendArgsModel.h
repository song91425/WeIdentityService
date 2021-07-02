//
//  WIBAC005SendArgsModel.h
//  WeIdentityService
//
//  Created by lssong on 2021/2/23.
//

#import "WIBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WIBAC005SendArgsModel :  WIBaseModel

/// 发送资产id
@property (nonatomic, assign)long assetId;

/// 资产接收用户weId
@property (nonatomic, copy)NSString *recipient;

/// 资产的地址
@property (nonatomic, copy)NSString *assetUri;
/// 交易描述
@property (nonatomic, copy)NSString *data;

/// 交易描述
@property (nonatomic, copy)NSString *remark;
@end

NS_ASSUME_NONNULL_END
