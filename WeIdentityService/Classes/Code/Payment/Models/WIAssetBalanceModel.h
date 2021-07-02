//
//  WIAssetBalanceModel.h
//  WeIdentityService
//
//  Created by tank on 2020/10/26.
//

#import "WIBaseModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface WIAssetBalanceModel : WIBaseModel

@property(nonatomic, copy) NSString *assetAddress;
@property(nonatomic, copy) NSDecimalNumber *balance;
@end

NS_ASSUME_NONNULL_END
