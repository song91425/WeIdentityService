//
//  WISendAssetArgsModel.h
//  WeIdentityService
//
//  Created by tank on 2020/10/26.
//

#import "WIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WISendAssetArgsModel : WIBaseModel

/// 资产接收用户weId
@property (nonatomic, copy) NSString *recipient;
/// 发送资产数量
@property (nonatomic, assign) int amount;
/// 交易描述
@property (nonatomic, copy) NSString *remark;
@end

NS_ASSUME_NONNULL_END
