//
//  WIBAC004AssetModel.h
//  WeIdentityService
//
//  Created by tank on 2020/10/26.
//

#import "WIBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WIBAC004AssetModel : WIBaseModel

@property (nonatomic, copy) NSString *assetAddress;
@property (nonatomic, copy) NSString *shortName;

@property (nonatomic, copy) NSString *description;

// 资产总发行量
@property (nonatomic, assign) int totalSupply;

@end

NS_ASSUME_NONNULL_END


//{
//      "assetAddress": "0x60e0db3db412fb62fa418f792e7f728d3b098629",
//      "shortName": "RMB",
//      "description": "人民币",
//      "totalSupply": 2000
//  }
