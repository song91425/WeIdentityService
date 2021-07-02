//
//  WIQueryOwnedAssetModel.h
//  WeIdentityService
//
//  Created by lssong on 2021/2/23.
//

#import "WIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WIQueryOwnedAssetModel : WIBaseModel
@property (nonatomic, copy)NSString *userAddress;
@property (nonatomic, assign)long assetId;
@property (nonatomic, copy)NSString *assetUri;
@property (nonatomic, copy)NSString *data;

@end

NS_ASSUME_NONNULL_END
