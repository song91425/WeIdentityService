//
//  WIHDWallet.h
//  WeIdentityService
//
//  Created by tank on 2020/12/22.
//

#import <Foundation/Foundation.h>
#import <WeIdentityService/WIHDWalletKeyPair.h>
#import <WeIdentityService/WIMnemonicsInfo.h>


NS_ASSUME_NONNULL_BEGIN
@interface WIDomainInfo : NSObject

@property (nonatomic, copy)NSString *domain;
@property (nonatomic, assign)BOOL encrypted;
@property (nonatomic, copy)NSString *domainPwd;

+ (instancetype)domainInfo:(NSString *)domain encrypted:(BOOL)encrypted domainPwd:(NSString *)domainPwd;

@end


@interface WIHDWallet : NSObject

+ (instancetype)sharedInstance;

/// 当前是否已经创建钱包
- (BOOL)isHDWalletCreated;

/// 检查本地是否初始化过钱包，有则加载，无则创建
/// @param unlockPwd 用户解锁密码
- (void)initHDWallet:(NSString *)unlockPwd callback:(void (^)(BOOL result, NSError * error)) callback;

// 删除钱包以后,重置 init 状态
- (void) unInit;

/// 传入助记词，恢复masterKey
/// @param mnemonics 助记词
/// @param currentIndex 当前索引
/// @param unlockPwd 解锁密码
/// @param deletePreviousWallet 解锁密码
- (void)initHDWalletWithMnemonics:(NSString *)mnemonics
                     currentIndex:(int)currentIndex
                        unlockPwd:(NSString *)unlockPwd
             deletePreviousWallet:(BOOL)deletePreviousWallet
                         callback:(void (^)(BOOL, NSError *))callback;

/// 通过恢复文件恢复master key
/// @param restoreFilePath 恢复文件
/// @param restorePwd 恢复密码
/// @param unlockPwd 解锁密码，用来加密钱包
- (void)initHDWalletWithFile:(NSString *)restoreFilePath
                  restorePwd:(NSString *)restorePwd
                   unlockPwd:(NSString *)unlockPwd
                    callback:(void (^)(BOOL, NSError *))callback;

/// 创建公私钥
/// @param transPwd 交易密码
//- (WIKeyPair *)createKeyPair:(NSString *)transPwd;

/// 创建一个全新的公私钥, base64 格式的!!!!
//- (WIHDWalletKeyPair *)createKeyPair;

- (void) createKeyPairSuccess:(void (^)(WIKeyPairModel * keyPair,int index))success fail:(void (^)(NSError *)) fail;

///// 存储KeyPair（公钥做key），通过transPwd加密私钥
///// @param keyPair 密钥对
///// @param transPwd 交易密码
//- (BOOL)saveHDWalletKeyPair:(WIHDWalletKeyPair *)keyPair weId:(NSString *)weId keyId:(NSString *)keyId transPwd:(NSString *)transPwd;



/// 获取公私钥
/// @param weId weid
/// @param keyId keyid
/// @param transPwd 交易密码
-(WIKeyPairModel *) getWIKeyPair: (NSString *)weId keyId:(NSString *)keyId transPwd:(NSString*)transPwd;


/// 导出字符串格式的助记词
- (void)exportMnemonics:(void(^)(WIMnemonicsInfo *info))callback;


/// 修改交易密码接口
/// 有几种情况：
/// 1. 设置密码： 当前交易密码[currentPwd]为空，新交易密码[newPwd]不为空
/// 2. 删除密码： 当前交易密码[currentPwd]不为空，新的交易密码[newPwd]为空
/// 3. 修改密码： 当前交易密码[currentPwd]和新的交易密码都[newPwd]不为空
/// 如果[currentPwd]和[newPwd]都为空则不执行任何操作
/// 这里为空指的是没有有效的字符，null，空字符串，全是空格都为空
/// @param weId weId
/// @param keyId keyId
/// @param currentPwd currentPwd
/// @param newPwd newPwd
/// @param callback callback
- (void)updateTransPwd:(NSString *)weId
                 keyId:(NSString *)keyId
            currentPwd:(NSString *)currentPwd
                newPwd:(NSString *)newPwd
              callback:(void(^)(BOOL success, NSString* msg))callback;


/// 导出文件格式的助记词文件
/// @param destFilePath 存储助记词文件的地址, iOS 是filename
/// @param restorePwd 恢复密码
- (void)exportRestorationFile:(NSString *)destFilePath restorePwd:(NSString *)restorePwd callback:(void(^)(BOOL result,NSString *filePath))callback;


//- (NSString *)getWalletDBName:(NSString *)domain;

// 获取或者创建一个数据库密码(存储到钱包中)
- (void)getOrCreateDomainPwd:(NSString *)domain callback:(void (^)(NSString *hexPwd, NSError *error)) callback;

/// 获取本地存储的指定domain的信息
/// @param domain domain
- (void) getDomainInfo:(NSString *)domain getPwd:(BOOL)getPwd callback:(void (^)(WIDomainInfo *domainInfo ,NSError * error))callback;

/// 创建weid成功以后
/// @param weId weId description
/// @param keyId keyId description
/// @param keyPair keyPair description
/// @param transPwd transPwd description
/// @detail: 1. currentIndex++并存储 ; 2. 更新currentIndex;3. 保存weid#keyId-->keyPair
- (BOOL)saveWIKeyPairAfterCreateWeId:(NSString *)weId keyId:(NSString *)keyId keyPair:(WIHDWalletKeyPair *)keyPair transPwd:(NSString *)transPwd;

/**
 * 1. weid#KeyId--> KeyPair
 * 2. 更新currentIndex
 * 3. 存储weidList
 */
- (BOOL) saveWeIdInfoAndCurrentIndex:(int)currentIndex
                        allWeIdList:(NSArray *)allWeIdList
                      allKeyPairList:(NSArray *)allKeyPairList;

- (void)getWeIdList:(void(^)(NSArray *weIdList))callback;

-(void)getPublicKeyList:(int)start size:(int)size callback:( void (^)(NSArray<WIKeyPairModel *> *publicKeys, NSError *error))callback;

/**
 * 特定index+1 以后存储到本地
 */
-(BOOL)addAndUpdateCurrentIndex:(int)index;
@end



NS_ASSUME_NONNULL_END
