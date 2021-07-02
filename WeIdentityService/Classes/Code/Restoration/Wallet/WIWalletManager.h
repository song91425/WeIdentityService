//
//  WIWalletManager.h
//  WeIdentityService
//
//  Created by tank on 2021/1/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIWalletManager : NSObject

+ (instancetype)manager;

- (BOOL)hasWallet;

- (NSString *)getCurrentWallet;

/// 设置当前钱包
/// @param newWalletName new wallet name
- (void)setCurrentWallet:(NSString *)newWalletName;

/// 获取新钱包名字
-(NSString *)getNextWalletName;

/// 空钱包配置
- (void)cleanWallet;


/// 注册业务数据库名字到当前钱包
/// @param dbDomain DB name
- (void)registerDatabase:(NSString *)dbDomain;

/// 将当前用户的domain关联上钱包名字返回数据库名字
/// @param domain domain name
-(NSString *)getWalletDBName:(NSString *)domain;

/// 返回之前钱包的名字
- (NSString *)getPreviousWallet;

/// 重置当前钱包配置
- (void)resetCurrentWallet;

/// 删除当前钱包
- (void)deleteCurrentWallet;

- (void)deletePreviousWallet;


/// 删除特定的钱包
/// @param name 钱包 name
- (void)deleteWallet:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
