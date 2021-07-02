//
//  WIWalletManager.m
//  WeIdentityService
//
//  Created by tank on 2021/1/11.
//

#import "WIWalletManager.h"
#import "WIKeychainPersistence.h"
#import "WIHDWallet.h"
#import "WIDBPersistence.h"
#import "WISDKLog.h"
//sp name
//private const val SP_NAME_CONFIG = "_wallet_config" //用来存储当前钱包的配置

//key
static NSString * const WI_WALLET_SP_KEY_CURRENT_WALLET = @"current_wallet"; // 用来存储当前是哪个钱包
static NSString * const WI_WALLET_SP_KEY_PREVIOUS_WALLET = @"previous_wallet"; // 用来存储前一个钱包的名字
static NSString * const WI_WALLET_DOMAIN_WALLET_PREFIX = @"_wi_wallet_";     // 钱包名字前缀,用来生成新钱包名字的值
static NSString * const WI_WALLET_SP_KEY_WALLET_INDEX = @"wallet_index";     // 记录一个钱包索引值,用来生成新钱包名字的值

static  NSString* const WI_HDWALLET_KEY_WALLET_DB_SET           = @"wallet_db_set";//当前钱包创建的所有domain数据库

//存储钱包的配置文件名字的后缀：非加密存储([钱包名]_config)
//private const val WALLET_CONFIG_NAME_SUFFIX: String = "_config"

WIWalletManager *manager = nil;

@interface WIWalletManager()

@property (nonatomic, strong) WIKeychainPersistence *walletConfigStore;

@end

@implementation WIWalletManager

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [WIWalletManager new];
    });
    
    return manager;
}

- (BOOL)hasWallet
{
    NSString *currentWallet = [[NSUserDefaults standardUserDefaults] objectForKey:WI_WALLET_SP_KEY_CURRENT_WALLET];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"WI_WALLET_SP_KEY_CURRENT_WALLET:%@",currentWallet);
    return (currentWallet != nil);
}

/**
 * 获取当前钱包,可能为null
 */
- (NSString *)getCurrentWallet
{
    NSString *currentWallet = [[NSUserDefaults standardUserDefaults] objectForKey:WI_WALLET_SP_KEY_CURRENT_WALLET]; // @"current_wallet"
    return currentWallet;
}


/// 设置当前钱包
/// @param newWalletName new wallet name
- (void)setCurrentWallet:(NSString *)newWalletName
{
    NSAssert(newWalletName != nil, @"invalid wallet name.");
    [[NSUserDefaults standardUserDefaults] setObject:[self getCurrentWallet]
                                              forKey:WI_WALLET_SP_KEY_PREVIOUS_WALLET];
    
    [[NSUserDefaults standardUserDefaults] setObject:newWalletName
                                              forKey:WI_WALLET_SP_KEY_CURRENT_WALLET];
}

/**
 * 返回之前钱包的名字
 */
-(NSString *)getPreviousWallet
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:WI_WALLET_SP_KEY_PREVIOUS_WALLET];
}

/**
 * 重置当前钱包配置
 */
- (void)resetCurrentWallet
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WI_WALLET_SP_KEY_CURRENT_WALLET];
}

- (void)deleteCurrentWallet
{
    if ([[WIHDWallet sharedInstance] isHDWalletCreated]) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"delete current wallet error. - current wallet is not created.");
        return;
    }
    NSString *currentWallet = [self getCurrentWallet];
    if (currentWallet != nil) {
        [self deleteWallet:currentWallet];
    }
    
    [self resetCurrentWallet];
    [[WIHDWallet sharedInstance] unInit];
}

/// 获取新钱包名字
-(NSString *)getNextWalletName
{
    NSInteger walletIndex = [self __getWalletIndex];
    ++walletIndex;
    
    [self __setWalletIndex:walletIndex];
    NSString *name = [NSString stringWithFormat:@"%@%ld",WI_WALLET_DOMAIN_WALLET_PREFIX,walletIndex];
    return name;
}

- (void)registerDatabase:(NSString *)dbDomain
{
    //必须保证当前钱包已经打开
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:WI_HDWALLET_KEY_WALLET_DB_SET];
    NSMutableArray *tmp = nil;
    if (tmp != nil) {
        tmp = [NSMutableArray arrayWithArray:arr];
        //TODO: 去重.
    }else{
        tmp = [NSMutableArray array];
    }
    [tmp addObject:dbDomain];
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:tmp] forKey:WI_HDWALLET_KEY_WALLET_DB_SET];
}

/**
 * 删除特定钱包
 */
- (void)deleteWallet:(NSString *)name
{
    if (name == nil) {
        return;
    }
    // 1. 删除钱包keychain 对应的 domain
    WIKeychainPersistence *per = [WIKeychainPersistence keyChainPersistenceWithDomain:name];
    BOOL res = [per deleteKeyChainPersistenceWithDomain:name];
    NSAssert(res, @"delete keychain domain failed.");
    
    // 2. 删除该钱包下的业务数据库
    NSArray *dbs = [[NSUserDefaults standardUserDefaults] objectForKey:WI_HDWALLET_KEY_WALLET_DB_SET];
    for (NSString *dbName in dbs) {
        // TODO: 删除 db
    }
    // 3. 删除钱包相关的配置文件
    NSString *key = [NSString stringWithFormat:@"%@_wallet_weid_list",name];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    
    // 4. 其它的 NSUserdefault 删除
}

/// 空钱包配置
//- (void)cleanWallet
//{
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WI_WALLET_SP_KEY_CURRENT_WALLET];
//}

/// 将当前用户的domain关联上钱包名字返回数据库名字
/// @param domain domain name
-(NSString *)getWalletDBName:(NSString *)domain
{
    NSString *currentWalletStr = [self getCurrentWallet];
    NSString *name = [NSString stringWithFormat:@"%@_%@",currentWalletStr,domain];
    return name;
}

/**
 * 删除之前的钱包
 */
- (void)deletePreviousWallet
{
    NSString *walletName = [self getPreviousWallet];
    [self deleteWallet:walletName];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"delete previous wallet, %@",walletName);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WI_WALLET_SP_KEY_PREVIOUS_WALLET];
}


- (NSInteger)__getWalletIndex{
    id index = [[NSUserDefaults standardUserDefaults] objectForKey:WI_WALLET_SP_KEY_WALLET_INDEX];
    if (index == nil) {
        return -1;
    }else{
        int indexValue = [index intValue];
        return indexValue;
    }
    
}

- (void)__setWalletIndex:(NSInteger)index{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:WI_WALLET_SP_KEY_WALLET_INDEX];
}

@end
