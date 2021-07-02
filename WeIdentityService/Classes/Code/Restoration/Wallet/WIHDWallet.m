//
//  WIHDWallet.m
//  WeIdentityService
//
//  Created by tank on 2020/12/22.
//

#import "WIHDWallet.h"
#import "WIKeychainPersistence.h"
#import "WedprHdW.h"
#import "WIHDWalletUtils.h"
#import "WIWalletInfo.h"
#import "WICryptoUtils.h"

#import "WISaveDataWithFile.h"
#import "WIWalletManager.h"
#import "WIHDWalletInternalService.h"

#import <WeIdentityService/WISDKLog.h>

#import "WIError.h"

#pragma mark - 常量
// ========== 固定数据 ==========
static  int       const WI_HDWALLET_START_INDEX             = 1000;  //生成子私钥的起始currentIndex
static  int       const WI_HDWALLET_MAX_KEY_INDEX           = 65535; //加密数据库密码的子私钥的index的最大值
static  NSString* const WI_HDWALLET_SPLIT  = @"\n"; //用来分隔同一组数据
static  NSString* const WI_HDWALLET_PASSPHRASE              = @"wi_wallet"; // 固定的助记词口令

// ========== 这个和 Android 存在差异, Android 新建一个 sp 文件存如下两个值, iOS 作为前缀
// walletname_${}
static  NSString* const WI_HDWALLET_SP_KEY_WEID_LIST_SUFFIX       = @"_wallet_weid_list";//当前钱包创建的所有weid的有序列表
//static  NSString* const WI_HDWALLET_SP_KEY_WALLET_PWD_SUFFIX = @"_wallet_pwd";//加密了的钱包数据库密码, ios不需要!!!


// ========== 钱包内容 ==========
static  NSString* const WI_HDWALLET_KEY_DB_PREFIX           = @"wi_domain_pwd_"; //存储domain数据库密码的加密结果
static  NSString* const WI_HDWALLET_KEY_MASTER_KEY          = @"wi_master_key"; //存储私钥
static  NSString* const WI_HDWALLET_KEY_UNLOCK_PWD_HASH     = @"wi_unlock_pwd_hash";//存储解锁密码的hash值，用来验证解锁密码是否正确
static  NSString* const WI_HDWALLET_KEY_MNEMONICS           = @"wi_mnemonics";//存储助记词，用来导出
static  NSString* const WI_HDWALLET_KEY_CURRENT_INDEX       = @"wi_current_index";//存储currentIndex

// ========== 子私钥和交易密码相关 ==========
//static  NSString* const WI_HDWALLET_KEY_PUBLIC_INDEX_PREFIX    = @"wi_public_key_index_";//通过公钥取HDWallet tree index的前缀
static  NSString* const WI_HDWALLET_KEY_PUBLIC_KEY_PREFIX      = @"wi_public_key_pair_"; //通过公钥取WIKeyPair的前缀
static  NSString* const WI_HDWALLET_KEY_PUBLIC_KEY_HASH_PREFIX =@"wi_public_key_hash_";//通过公钥取WIKeyPair对应交易密码的hash，用来验证交易密码是否正确

@interface WIHDWallet ()
/// 当前的 index
@property (nonatomic) int currentIndex;
/// 用来存储钱包相关
@property (nonatomic, strong) WIKeychainPersistence *keyStore;
@property (nonatomic, copy) NSString *unlockPwd;
// 判断钱包是否初始化
@property (nonatomic) BOOL inited;

@property (nonatomic, strong) WISaveDataWithFile *fileHandle;
@property (nonatomic, strong) void (^internalError)(BOOL, NSError *);

@end

static WIHDWallet *wallet = nil;
@implementation WIHDWallet

#pragma mark - public method

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wallet = [WIHDWallet new];
    });
    return wallet;
}

- (void)unInit
{
    self.inited = NO;
}

#pragma mark - HDWallet init && export
// TODO: BUG ==> APP 删除,同时清理 keychain.
- (void)initHDWallet:(NSString *)unlockPwd callback:(void (^)(BOOL, NSError * ))callback
{
    if(!self.inited){
        // 没有 init wallet.
        BOOL hasWallet = [self isHDWalletCreated];
        if (hasWallet) {
            NSString *currentWallet = [[WIWalletManager manager] getCurrentWallet];
            WIKeychainPersistence *keyStore = [WIKeychainPersistence keyChainPersistenceWithDomain:currentWallet];
            [self __loadHDWalletFromLocal:keyStore unlockPwd:unlockPwd callback:^(WIWalletInfo * wallet, NSError * err) {
                if (err !=nil) {
                    callback(NO,err);
                    return;
                }else{
                    if (wallet.masterKey == nil) {
                        [WISDKLog log:__func__
                                 desc:@"HDWallet not initd, load HDWallet From Local, master key is nil."
                              argKeys:@[@"unlockPwd"]
                            argValues:@[unlockPwd]];
                        NSAssert(wallet.masterKey != nil, @"HDWallet not initd, load HDWallet From Local, master key is nil.");
                        self.inited = NO;
                        NSError * err = [WIError normalError:@"wallet not found" errcode:ERR_NO_WALLET];
                        callback(NO, err);
                    }else{
                        [WISDKLog log:__func__
                                 desc:@"HDWallet not initd, load HDWallet From Local."
                              argKeys:@[@"unlockPwd",@"wallet info"]
                            argValues:@[unlockPwd,wallet]];
                        callback(YES,nil);
                    }
                }
            }];
           
        }else{
            // 清理 keychain 里面的数据
            // newWalletName 从 _wi_wallet_1 开始
            NSString* newWalletName = [[WIWalletManager manager] getNextWalletName];
            WIKeychainPersistence *keyStore = [WIKeychainPersistence keyChainPersistenceWithDomain:newWalletName];
            NSArray *keychinCash = [keyStore getByDomain:newWalletName].allKeys;
            if (keychinCash != nil && keychinCash.count >0 ) {
                [WISDKLog log:__func__
                         desc:@"Clean keychain ........"
                      argKeys:@[@"newWalletName",@"keychinCash"]
                    argValues:@[newWalletName,keychinCash]];
                BOOL delete = [keyStore deleteKeyChainPersistenceWithDomain:newWalletName];
                NSAssert(delete, @"SDK Error: Delete keychain failed.");
            }
            
            [WISDKLog log:__func__ desc:@"create new HDWallet." argKeys:@[@"unlockPwd",@"domain"] argValues:@[unlockPwd?:[NSNull null],newWalletName]];
            // 本地不存在 wallet,new 一个 wallet.
            [self __createNewMasterKeyAndSave:keyStore newWalletName:newWalletName unloackPwd:unlockPwd callback:^(BOOL createWallet, NSError * err) {
                callback(createWallet,err);
            }];
        }
    }else{
        callback(YES,nil);
    }
    // TODO: inited 校验 unlockpwd
//    return YES;
}

// Init wallet with mnemonics / master key pwd / current index / unloack pwd
- (void)initHDWalletWithMnemonics:(NSString *)mnemonics
                     currentIndex:(int)currentIndex
                        unlockPwd:(NSString *)unlockPwd
             deletePreviousWallet:(BOOL)deletePreviousWallet
                         callback:(void (^)(BOOL, NSError *))callback
{
    [self __initHDWalletWithMnemonics:mnemonics
                         currentIndex:currentIndex
                            unlockPwd:unlockPwd
                 deletePreviousWallet:deletePreviousWallet
                             callback:^(BOOL res, NSError * err){
        callback(res,err);
    }];
}

- (void)initHDWalletWithFile:(NSString *)restoreFilePath
                  restorePwd:(NSString *)restorePwd
                   unlockPwd:(NSString *)unlockPwd
                    callback:(void (^)(BOOL, NSError *))callback
{
    
    [self __initHDWalletWithFile:restoreFilePath
                             restorePwd:restorePwd
                              unlockPwd:unlockPwd
            deletePreviousWallet:YES callback:^(BOOL res, NSError * err) {
        callback(res,err);
    }];
    
}



- (void)exportMnemonics:(void(^)(WIMnemonicsInfo *info))callback
{
    WIMnemonicsInfo *info = [self __getMnemonics];
    if (callback) callback(info);
}

- (void)updateTransPwd:(NSString *)weId keyId:(NSString *)keyId currentPwd:(NSString *)currentPwd newPwd:(NSString *)newPwd
              callback:(void(^)(BOOL success, NSString* msg))callback
{
    WIKeyPairModel *keyPair = [self getWIKeyPair:weId keyId:keyId transPwd:currentPwd];
    if (keyPair == nil) {
        if (callback) {
            callback(NO,@"get keypair failed.");
            return;
        }
    }
    BOOL res = [self saveWIKeyPair:keyPair weId:weId keyId:keyId transPwd:newPwd];
    if (callback)
        callback(res,nil);
}

// 理完
- (void)exportRestorationFile:(NSString *)destFilePath
                   restorePwd:(NSString *)restorePwd
                     callback:(void(^)(BOOL,NSString*))callback
{
    WIMnemonicsInfo *mnemonics = [self __getMnemonics];
    NSString *text = [NSString stringWithFormat:@"%@\n%d",mnemonics.mnemonics,mnemonics.currentIndex];
    // 备份密码两次 hash
    NSString *keyFromPwd = [self __getKeyFromPwd:restorePwd];
    if(keyFromPwd == nil){
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"get key from storePwd failed");
        callback(NO,@"get key from storePwd failed");
        return;
    }
    NSString *encrypted = [WICryptoUtils aesEncryptString:text key:keyFromPwd];
    // TODO: 删除同名文件
    NSString* path = [self.fileHandle writeContentWithFileName:destFilePath contentWithString:encrypted];
    // 写文件
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"export path:%@",path);
//    NSArray *arr = [self.fileHandle readContentWithFileName:path fileType:FileTypeString];
//    NSLog(@"%@",arr);
    [WISDKLog log:__func__ desc:@"export succeed" argKeys:@[@"filepath"] argValues:@[path]];
    callback(YES,path);
}

// 理完
- (void)__initHDWalletWithFile:(NSString *)restoreFilePath
                    restorePwd:(NSString *)restorePwd
                     unlockPwd:(NSString *)unlockPwd
          deletePreviousWallet:(BOOL)delete
                      callback:(void (^)(BOOL, NSError *))callback

{
    if(![[NSFileManager defaultManager] fileExistsAtPath:restoreFilePath]){
        NSError *error = [WIError normalError:@"restoreFile not exist" errcode:ERR_FILE_NOT_EXIST];
        callback(NO,error);
        return ;
    }
    
    NSArray *arr = [self.fileHandle readContentWithFileName:restoreFilePath fileType:FileTypeString];
    NSString *encryptedStr = nil;
    if(arr != nil && arr.count == 1){
        // 只有一个数据.
        encryptedStr = arr[0];
    }else{
        NSError *error = [WIError normalError:@"file has no content" errcode:ERR_NOT_FOUND];
        callback(NO,error);
        return ;
    }
    NSString *keyFromPwd = [self __getKeyFromPwd:restorePwd];
    if (keyFromPwd == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"get key from storePwd failed");
        NSError *error = [WIError internalError:@"get key from storePwd failed"];
        callback(NO,error);
        return ;
    }
    NSString *decryptedStr = [WICryptoUtils aesDecryptString:encryptedStr key:keyFromPwd];
    if (decryptedStr == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"decrypt mnemonic err, check your restorePwd ");
        
        NSError *error = [WIError normalError:@"decrypt mnemonic err, check your restorePwd" errcode:ERR_RESTORE_PWD];
        callback(NO,error);
        return ;
    }
    NSArray *decryptedArr = [decryptedStr componentsSeparatedByString:@"\n"];
    if (decryptedArr != nil && decryptedArr.count == 2) {
        NSString *mnemonics = decryptedArr[0];
        int currentIndex = [decryptedArr[1] intValue];
        [self __initHDWalletWithMnemonics:mnemonics currentIndex:currentIndex unlockPwd:unlockPwd deletePreviousWallet:delete callback:^(BOOL res, NSError * err) {
            callback(res, err);
            return;
        }];
        
//        return [self __initHDWalletWithMnemonics:mnemonics currentIndex:currentIndex unlockPwd:unlockPwd deletePreviousWallet:delete];
    }
    NSError *error = [WIError normalError:@"Failed to parse file contents" errcode:ERR_DEFAULT];
    callback(NO,error);
}

// 理完
- (void) __initHDWalletWithMnemonics:(NSString *)mnemonics
                       currentIndex:(int)index
                          unlockPwd:(NSString *)unlockPwd
               deletePreviousWallet:(BOOL)delete
                           callback:(void (^)(BOOL, NSError *))callback
{
    //1. 是否已经创建钱包.
    BOOL hdWalletCreated = [self isHDWalletCreated];
    
    //2. 生成 master key.
    NSString *passphrase = [self __createPassphrase];
    [self __createMasterKeyFromMnemonic:mnemonics passphrase:passphrase callback:^(bool result, NSString * masterKey, NSError * error) {
        // TODO: masterKey 一定不能为空
        if(!result){
            callback(NO,error);
            return;
        }
        int currentIndex = MAX(index, WI_HDWALLET_START_INDEX);
        
        if (!hdWalletCreated) { // 当前没有钱包,直接创建
            NSString *newWalletName = [[WIWalletManager manager] getNextWalletName];
            NSString *passPhrase = [self __createPassphrase];
            
            WIKeychainPersistence *keyStore = [self __createNewKeyStoreWith:newWalletName];
            
            [self __saveMasterKeyToKeyStore:keyStore masterKey:masterKey mnemonic:mnemonics passPhrase:passPhrase currentIndex:currentIndex unlockPwd:unlockPwd callback:^(BOOL saved, NSError * err) {
                if (saved) {
                    [self __initHDWalletSuccess:keyStore currentIndex:currentIndex unloackPwd:unlockPwd newWalletName:newWalletName];
                    callback(saved,nil);
                }else{
                    callback(NO,err);
                }
            }];
        }else{ // 当前有钱包，先创建在新的位置,创建成功以后删除老钱包
            
            NSString *newWalletName = [[WIWalletManager manager] getNextWalletName];
            NSString *passPhrase = [self __createPassphrase];
            
            WIKeychainPersistence *keyStoreNew = [self __createNewKeyStoreWith:newWalletName];
            
            [self __saveMasterKeyToKeyStore:keyStoreNew masterKey:masterKey mnemonic:mnemonics passPhrase:passPhrase currentIndex:currentIndex unlockPwd:unlockPwd callback:^(BOOL saved, NSError * err) {
                if (saved) {
                    if (delete) { //删除当前钱包
                        [[WIWalletManager manager] deleteWallet:[[WIWalletManager manager] getCurrentWallet]];
                    }
                    [self __initHDWalletSuccess:keyStoreNew currentIndex:currentIndex unloackPwd:unlockPwd newWalletName:newWalletName];
                    callback(saved,nil);
                }else{
                    // 删除新的 wallet,初始化失败.
                    [[WIWalletManager manager] deleteWallet:newWalletName];
                    callback(NO,err);
                }
            }];
        }
    }];
    
    
    
}

/// 创建新的钱包 keychain, 如果 domain 已经存在的话, 删除掉.
/// @param name new name
- (WIKeychainPersistence *)__createNewKeyStoreWith:(NSString *)name
{
    WIKeychainPersistence *keyStore = [WIKeychainPersistence keyChainPersistenceWithDomain:name];
    
    // 判断新创建的 keyStore 是否已经存在了, 如果已经存在,删除之前的.
    if ([keyStore getByDomain:name] != nil) {
       BOOL res = [keyStore deleteKeyChainPersistenceWithDomain:name];
        NSAssert(res, @"delete keychain persistence failed.");
    }
    return keyStore;
}



- (BOOL)isHDWalletCreated
{
    NSString *currentWallet = [[WIWalletManager manager] getCurrentWallet];
    return currentWallet != nil;
}
//理完
- (void) createKeyPairSuccess:(void (^)(WIKeyPairModel * keyPair,int index))success
                         fail:(void (^)(NSError *)) fail{
    // 维护 index
    [self __createKeyPair:self.currentIndex callback:^(WIKeyPairModel * kPair, NSError * err) {
        if(err!=nil){
            fail(err);
            return;
        }else{
            WIKeyPairModel *keyPair = kPair;//[self __createKeyPair:self.currentIndex];
            success(keyPair, self.currentIndex);
        }
    }];
   
}

// 理完
- (BOOL)saveWIKeyPair:(WIKeyPairModel *)keyPair weId:(NSString *)weId keyId:(NSString *)keyId transPwd:(NSString *)transPwd
{
    NSString *keyPairString = [NSString stringWithFormat:@"%@|%@",[keyPair privateKeyString],[keyPair publicKeyString]];
    NSString *enctyptedKeyPairString = keyPairString;
    
    NSString *hash_key = [NSString stringWithFormat:@"%@%@#%@",WI_HDWALLET_KEY_PUBLIC_KEY_HASH_PREFIX,weId,keyId];
    NSString *keyPair_key = [NSString stringWithFormat:@"%@%@#%@",WI_HDWALLET_KEY_PUBLIC_KEY_PREFIX,weId,keyId];
    BOOL hasTransPwd = transPwd == nil || transPwd.length < 1;

    if (!hasTransPwd) {
        // 1. 有交易密码, 计算密文
        NSString *keyFromPwd = [self __getKeyFromPwd:transPwd];
        if (keyFromPwd == nil) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"transPwd to key failed.");
            NSError *error = [WIError internalError:@"transPwd to key failed."];
            return NO;
        }
        
        NSString *hash = [WICryptoUtils wedpr_keccak256:keyFromPwd isHex:NO];
        if (hash == nil) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"hash transPwd key failed");
            NSError *error = [WIError internalError:@"hash transPwd key failed"];
            return NO;
        }
        
        int add = [self.keyStore add:hash_key data:hash];
        
        if (add != 1) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"store transPwd hash failed");
            NSError *error = [WIError internalError:@"store transPwd hash failed"];
            return NO;
        }
        
        enctyptedKeyPairString = [WICryptoUtils aesEncryptString:keyPairString key:hash];
    }
    // 2. 不加密存储
    int add = [self.keyStore add:keyPair_key data:enctyptedKeyPairString];
    
    if (add != 1) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"save WIKeyPair failed");
        NSError *error = [WIError internalError:@"save WIKeyPair failed"];
        return NO;
    }
    return YES;
}

// 理完
-(WIKeyPairModel *) getWIKeyPair: (NSString *)weId keyId:(NSString *)keyId transPwd:(NSString*)transPwd
{
    [WISDKLog log:__FUNCTION__ desc:@"通过公钥获取 + transpwd 获取 keypair."];
    NSString *hash_key = [NSString stringWithFormat:@"%@%@#%@",WI_HDWALLET_KEY_PUBLIC_KEY_HASH_PREFIX,weId,keyId];
    NSString *keyPair_key = [NSString stringWithFormat:@"%@%@#%@",WI_HDWALLET_KEY_PUBLIC_KEY_PREFIX,weId,keyId];
    
    NSString *hash_local = [self.keyStore get:hash_key];
    // 有 local hash 值,没有密码
    if (hash_local != nil && transPwd == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"get WIKeyPair error: pwd error");
        NSError *error = [WIError normalError:@"get  WIKeyPair error: transPwd error, need pwd" errcode:ERR_TRANS_PWD];
        return nil;
    }
    
    // 没有 local hash 值,有密码
    if (hash_local == nil && transPwd != nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"get WIKeyPair error: hashLocal error");
        NSError *error = [WIError normalError:@"get  WIKeyPair error: transPwd error, need no pwd" errcode:ERR_TRANS_PWD];
        return nil;
    }
    
    // 获取密钥对
    NSString *keyPairString = [self.keyStore get:keyPair_key];
    if (keyPairString == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"@WIKeyPair not found");
        NSError *error = [WIError normalError:@"@WIKeyPair not found" errcode:ERR_NOT_FOUND];
        return nil;
    }
    
    if (transPwd != nil) {
        // 有密码,需要解密
        // 校验传入密码的正确性
        NSString *keyFromPwd = [self __getKeyFromPwd:transPwd];
        if(keyFromPwd == nil){
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"get key from pwd error");
            NSError *error = [WIError internalError:@"get key from pwd error"];
            return nil;
        }
        
        NSString *hash_new = [WICryptoUtils wedpr_keccak256:keyFromPwd  isHex:NO];
        if (![hash_new isEqualToString:hash_local]) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"get WIKeyPair error: transPwd error,hash compare failed");
            NSError *error = [WIError normalError:@"get WIKeyPair error: transPwd error,hash compare failed" errcode:ERR_TRANS_PWD];
            return nil;
        }
        
        keyPairString = [WICryptoUtils aesDecryptString:keyPairString key:keyFromPwd];
        if (keyPairString == nil) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"decrypt KeyPair error, check your transPwd");
            NSError *error = [WIError normalError:@"decrypt KeyPair error, check your transPwd" errcode:ERR_TRANS_PWD];
            return nil;
        }
    }
    
    NSArray *arr = [keyPairString componentsSeparatedByString:@"|"];
    if (arr && arr.count == 2) {
        WIKeyPairModel *keyPair = [WIKeyPairModel keyPairWithPublicKey:arr[1] privateKey:arr[0]];
        return keyPair;
    }
    return nil;
}

// 理完
- (void)getDomainInfo:(NSString *)domain getPwd:(BOOL)getPwd callback:(void (^)(WIDomainInfo *,NSError *))callback
{
    NSString *dbPwdItemId = [NSString stringWithFormat:@"%@%@",WI_HDWALLET_KEY_DB_PREFIX,domain];
    NSString *pwdInfo = [self.keyStore get:dbPwdItemId];
    
    if(pwdInfo == nil){
        NSError *error = [WIError normalError:@"the wallet has not been initialized" errcode:ERR_DEFAULT];
        callback(nil,error);
        return ;
    }
    
    if (!getPwd) {
         callback([WIDomainInfo domainInfo:domain encrypted:(pwdInfo != nil) domainPwd:nil],nil);
        return;
    }
    
    [self __loadMasterKeyFromLocal:self.keyStore unlockPwd:self.unlockPwd callback:^(NSString *mKey, NSError * err) {
        if (err !=nil) {
            callback(nil,err);
            return;
        }else{
            NSString *masterKey = mKey;//[self __loadMasterKeyFromLocal:self.keyStore unlockPwd:self.unlockPwd];
            NSAssert(masterKey != nil, @"load masterKey for getDomainList failed");
            if (masterKey == nil) {
                NSError *error = [WIError internalError:@"load masterKey for getDomainList failed"];
                callback(nil,error);
                return;
            }
            
            if (pwdInfo == nil) {
                 callback([WIDomainInfo domainInfo:domain encrypted:NO domainPwd:nil],nil);
                return;
            }else{
                // 直接获取当前的密钥
                NSArray *split = [pwdInfo componentsSeparatedByString:WI_HDWALLET_SPLIT];
                if (split && [split isKindOfClass:[NSArray class]] && split.count == 2) {
                    int index = [split[0] intValue];
                    NSString *encryptedPwd = split[1];
                    //获取解密dbPwd的KeyPair
                    WIKeyPairModel *keyPair = [self __createKeyPair:masterKey index:index];

                    if (keyPair == nil) {
                        if(WISDKLog.sharedInstance.printLog)
                            NSLog(@"get db keyPair for %d failed",index);
                        NSError *error = [WIError internalError:@"get db keyPair for %d failed"];
                        callback(nil,error);
                        return;
                    }
                    if (encryptedPwd == nil || [encryptedPwd isEqualToString:@""]) {
                        // 没有密码
                        callback([WIDomainInfo domainInfo:domain encrypted:NO domainPwd:nil],nil);
                        return;
                    }else{
                        NSString *privateKeyHex = [keyPair privateKeyString];
                        if(WISDKLog.sharedInstance.printLog)
                            NSLog(@"=============>\n直接获取当前的密钥\nkeyPair:%@\nencryptedPwd:%@\n",keyPair,encryptedPwd);

                        NSString *result = [WICryptoUtils eciesSecp256k1Decrypt:privateKeyHex hexCipherText:encryptedPwd];
                        
                        if (result == nil) {
                            [WISDKLog log:__FUNCTION__ desc:@"直接获取当前的密码失败"
                                  argKeys:@[@"db中存储的 pwd",@"index",@"encryptedPwd",@"keyPair",@"解密结果(pwd)"]
                                argValues:@[pwdInfo,@(index),encryptedPwd,keyPair,@"解密失败拉!!!"]];
                            NSAssert(result != nil, @"解密失败");
                            
                            NSError *error = [WIError internalError:[NSString stringWithFormat:@"decrypt domain: %@'s pwd failed",domain]];
                            callback(nil,error);
                            return;
                        }else{
                            [WISDKLog log:__FUNCTION__ desc:@"直接获取当前的密码成功"
                                  argKeys:@[@"db中存储的 pwd",@"index",@"encryptedPwd",@"keyPair",@"解密结果(pwd)"]
                                argValues:@[pwdInfo,@(index),encryptedPwd,keyPair,result]];
                            callback( [WIDomainInfo domainInfo:domain encrypted:YES domainPwd:result],nil);
                        }
                    }
                }else{
                    if(WISDKLog.sharedInstance.printLog)
                        NSLog(@"encrypt pwd can't be separated by \\n");
                    if(WISDKLog.sharedInstance.printLog)
                        NSLog(@"%@",pwdInfo);
                    
                    NSError *error = [WIError internalError:@"encrypt pwd can't be separated by \\n"];
                    callback(nil,error);
                    return;
                }
            }
        }
    }];
    
}

// 理完
-(void)getPublicKeyList:(int)start size:(int)size callback:( void (^)(NSArray<WIKeyPairModel *> *, NSError *err))callback
{
    [self __loadWalletInfo:self.keyStore unlockPwd:self.unlockPwd callback:^(WIWalletInfo * walletInfo, NSError * err) {
        if (err != nil) {
            callback(nil, err);
        }else{
            WIWalletInfo *info = walletInfo; //[self __loadWalletInfo:self.keyStore unlockPwd:self.unlockPwd];
            if (info != nil) {
                NSMutableArray *mutArr = [NSMutableArray array];
                for (int i = 0; i < size; i++) {
                    WIKeyPairModel *keyPair = [self __createKeyPair:info.masterKey index:(start + i)];
        //            [mutArr addObject:[keyPair publicKeyString]];
                    [mutArr addObject:keyPair];
                }
                callback([NSArray arrayWithArray:mutArr],nil);
                return ;
            }else{
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%s - load wallet info failed.",__func__);
                NSError *error= [WIError internalError:@"load wallet info failed"];
                callback(nil,error);
                return;
            }
        }
    }];
   
}
// 需要再返回添加错误的回调
//NSError *error = [WIError internalError:@"get key from unlock ped failed"];
-(BOOL)addAndUpdateCurrentIndex:(int)index
{
    int newCurrentIndex = index + 1;
    self.currentIndex = newCurrentIndex;
    int add = [self.keyStore update:WI_HDWALLET_KEY_CURRENT_INDEX
                            data:[NSString stringWithFormat:@"%d",newCurrentIndex]];

    return (add == 1);
}

/**
 * 创建weid成功以后
 * 1. currentIndex++并存储
 * 2. 存储weid列表
 * 3. 保存weid#keyId-->keyPair
 */
// 理完
- (BOOL)saveWIKeyPairAfterCreateWeId:(NSString *)weId
                               keyId:(NSString *)keyId
                             keyPair:(WIHDWalletKeyPair *)keyPair
                            transPwd:(NSString *)transPwd
{
    // 保存 currentIndex
    BOOL save = [self addAndUpdateCurrentIndex:keyPair.keyPairIndex];
    if (!save) {
        NSAssert(save, @"save current index error.");
        NSError *error = [WIError internalError:@"save current index error."];
        return NO;
    }
    // 保存 weid
    [self __saveWeIdList:@[weId]];
    // 保存 weid#keyid 和 keypair
    return [self saveWIKeyPair:keyPair.keyPair weId:weId keyId:keyId transPwd:transPwd];
}

/**
 * 1. weid#KeyId--> KeyPair
 * 2. 更新currentIndex
 * 3. 存储weidList
 */
// 理完
- (BOOL) saveWeIdInfoAndCurrentIndex:(int)currentIndex
                         allWeIdList:(NSArray *)allWeIdList
                      allKeyPairList:(NSArray *)allKeyPairList
{
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < allWeIdList.count; i++) {
        NSString *weId = [allWeIdList objectAtIndex:i];
        
        WIKeyPairModel *keyPair = [allKeyPairList objectAtIndex:i];
        NSString *keyPairStr = [NSString stringWithFormat:@"%@|%@",[keyPair privateKeyString],[keyPair publicKeyString]];
        
        NSString *key = [NSString stringWithFormat:@"%@%@#0",WI_HDWALLET_KEY_PUBLIC_KEY_PREFIX,weId];
        [mutDic setObject:keyPairStr forKey:key];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:mutDic];
    // 1.weid#KeyId--> KeyPair
    int res = [self.keyStore batchAdd:dic];
    if (res == 1) {
        //2. 更新currentIndex
        // 3. 存储weidList
        [self __saveWeIdList:allWeIdList];
        return [self addAndUpdateCurrentIndex:currentIndex];
    }else{
        NSError *error = [WIError internalError:@"batch save WIKeyPair failed"];
        return NO;
    }
    
}

// 理完
- (void)__saveWeIdList:(NSArray *)list
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s | %@",__func__,list);
    NSString *key = [self __getWeIdListUserDefaultKey];
    NSString *currentList = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    for (NSString *weid in list) {
        if (currentList == nil) {
            currentList = weid;
        }else{
            currentList = [NSString stringWithFormat:@"%@\n%@",currentList,weid];
        }
    }
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s | %@ %@ %@",__func__,list,currentList,key);
    [[NSUserDefaults standardUserDefaults] setObject:currentList forKey:key];
}
//理完
- (NSString *)__getWeIdListUserDefaultKey
{
    NSString *walletName = [[WIWalletManager manager] getCurrentWallet];
    NSString *key = [NSString stringWithFormat:@"%@%@",walletName,WI_HDWALLET_SP_KEY_WEID_LIST_SUFFIX];
    return key;
}

// 理完
- (void)getWeIdList:(void(^)(NSArray *))callback
{
    NSString *walletName = [[WIWalletManager manager] getCurrentWallet];
    if (walletName == nil) {
        NSAssert(NO, @"wallet not found");
        callback(nil);
        return;
//        NSError *error = [WIError normalError:@"wallet not found" errcode:ERR_NO_WALLET];
//        return;
    }
    NSString *key = [self __getWeIdListUserDefaultKey];
    NSString *weIdListString = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    
    // 还原 array.
    NSArray *weIdArr = [weIdListString componentsSeparatedByString:@"\n"];
    callback(weIdArr);
}

//- (NSString *)getWalletDBName:(NSString *)domain{
//    NSString *current = [[WIWalletManager manager] getCurrentWallet];
//    NSAssert(current != nil, @"getCurrentWallet is nil");
//    return [NSString stringWithFormat:@"%@_%@",current,domain];
//}

/**
 * 获取一个数据库密码，并且存储到KeyStore
 */
// 理完
- (void)getOrCreateDomainPwd:(NSString *)domain callback:(void (^)(NSString *, NSError *)) callback
{
    NSString *dbPwdItemId = [NSString stringWithFormat:@"%@%@",WI_HDWALLET_KEY_DB_PREFIX,domain];
    NSString *pwd = [self.keyStore get:dbPwdItemId];
    
    if (pwd == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"创建一个新的 pwd");
        // 创建一个新的,存起来
        NSString *randomStr = [WICryptoUtils createRandomStr:10];
        NSString *dbPwdHex  = [WICryptoUtils hashTwice:randomStr];
        if (dbPwdHex == nil) {
            NSAssert(dbPwdHex != nil, @"[SDK Error - getDomainPwd - dbPwdHex is nil.]");
            NSError *error = [WIError internalError:@"get db pwd hex failed"];
            callback(nil,error);
            return;
        }
        // val index = SecureRandomUtils.secureRandom().nextInt(MAX_KEY_INDEX)
        // (0,MAX_KEY_INDEX)
        srand((unsigned int)time(NULL));
        int index = (int)(rand() % WI_HDWALLET_MAX_KEY_INDEX);
        [self __createKeyPair:index callback:^(WIKeyPairModel * kPair, NSError * err) {
            if (err !=nil) {
                callback(nil,err);
                return;
            }else{
                WIKeyPairModel *keyPair = kPair;//[self __createKeyPair:index];
                if (keyPair == nil) {
                    if(WISDKLog.sharedInstance.printLog)
                        NSLog(@"create db keypair failed");
                    NSError *error = [WIError internalError:@"create db keypair failed"];
                    callback(nil,error);
                    return;
                }
                
                NSString *pubKeyHex = [keyPair publicKeyString];
                
                NSString *result = [WICryptoUtils eciesSecp256k1Encrypt:pubKeyHex hexPlainText:dbPwdHex];
                if(result && [result isKindOfClass:[NSString class]] && result.length > 0){
                    NSString *addToDbData = [NSString stringWithFormat:@"%d%@%@",index,WI_HDWALLET_SPLIT,result];
                    [WISDKLog log:__FUNCTION__ desc:@"创建一个新的密码成功" argKeys:@[@"keyPair",@"index",@"随机数两次hash值 dbPwdHex",@"encrypted Result"] argValues:@[keyPair,@(index),dbPwdHex,result]];
                    [self.keyStore add:dbPwdItemId data:addToDbData];
                     callback(dbPwdHex,nil);
                    return;
                }else{
                    if(WISDKLog.sharedInstance.printLog)
                        NSLog(@"encrypt db pwd failed");
                    NSError *error = [WIError internalError:@"encrypt db pwd failed"];
                    callback(nil,error);
                    return;
                }
            }
        }];
    }else{
        // 直接获取当前的密钥
        NSArray *split = [pwd componentsSeparatedByString:WI_HDWALLET_SPLIT];
        if (split && [split isKindOfClass:[NSArray class]] && split.count == 2) {
            int index = [split[0] intValue];
            NSString *encryptedPwd = split[1];
            //获取解密dbPwd的KeyPair
            [self __createKeyPair:index callback:^(WIKeyPairModel *kPair, NSError * err) {
                if (err != nil) {
                    callback(nil,err);
                    return;
                }
                
                WIKeyPairModel *keyPair = kPair;//[self __createKeyPair:index];
                if (keyPair == nil) {
                    if(WISDKLog.sharedInstance.printLog)
                        NSLog(@"get db keyPair for %d failed",index);
                    NSError *error = [WIError internalError:@"create db keypair failed"];
                    callback(nil,error);
                    return;
                }
                NSString *privateKeyHex = [keyPair privateKeyString];
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"=============>\n直接获取当前的密钥\nkeyPair:%@\nencryptedPwd:%@\n",keyPair,encryptedPwd);
                
                NSString *result = [WICryptoUtils eciesSecp256k1Decrypt:privateKeyHex hexCipherText:encryptedPwd];
                if (result == nil) {
                    [WISDKLog log:__FUNCTION__ desc:@"直接获取当前的密码失败"
                          argKeys:@[@"db中存储的 pwd",@"index",@"encryptedPwd",@"keyPair",@"解密结果(pwd)"]
                        argValues:@[pwd,@(index),encryptedPwd,keyPair,@"解密失败拉!!!"]];
                    NSError *error = [WIError internalError:@"encrypt db pwd failed"];
                    callback(nil,error);
                    return;
                }else{
                    [WISDKLog log:__FUNCTION__ desc:@"直接获取当前的密码成功"
                          argKeys:@[@"db中存储的 pwd",@"index",@"encryptedPwd",@"keyPair",@"解密结果(pwd)"]
                        argValues:@[pwd,@(index),encryptedPwd,keyPair,result]];
                }
                callback( result, nil);
            }];
            
        }else{
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"encrypt pwd can't be separated by \\n");
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",pwd);
            NSError *error = [WIError internalError:@"encrypt pwd can't be separated by \\n"];
            callback(nil,error);
            return;
        }
    }
}


- (WISaveDataWithFile *)fileHandle{
    if (_fileHandle == nil) {
        _fileHandle = [WISaveDataWithFile new];
    }
    return _fileHandle;
}

// 理完
- (WIMnemonicsInfo *)__getMnemonics{
    if (![self isHDWalletCreated]) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"wallet has not init when getMnemonics.");
        
        NSError *error = [WIError normalError:@"wallet has not initialized" errcode:ERR_NOT_INIT];
        return nil;
    }
    
    return [self __loadMnemonicsInfo:self.keyStore unlockPwd:self.unlockPwd];
}

// 理完
- (WIMnemonicsInfo *)__loadMnemonicsInfo:(WIKeychainPersistence *)keyStore unlockPwd:(NSString *)unlockPwd
{
    NSString *keyFromPwd = [self __getKeyFromPwd:unlockPwd];
    if(keyFromPwd == nil){
        NSError *erroe = [WIError internalError:@"get key from unlock pwd failed"];
        return nil;
    }
    NSAssert(keyFromPwd != nil, @"get key from unlock pwd failed");
    
    NSString *encryptdMn = [keyStore get:WI_HDWALLET_KEY_MNEMONICS];
    if (encryptdMn == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"wallet mnemonics is null");
        NSError *erroe = [WIError internalError:@"wallet mnemonics is null"];
        return nil;
    }
    NSString *decryptedMn = [WICryptoUtils aesDecryptString:encryptdMn key:keyFromPwd];
    if (decryptedMn == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"decrypt mnemonics error, please check your unlockPwd");
        NSError *erroe = [WIError normalError:@"decrypt mnemonics error,please check your unlockPwd" errcode:ERR_UNLOCK_PWD];
        return nil;
    }
    
    NSString *currentIndexStr = [keyStore get:WI_HDWALLET_KEY_CURRENT_INDEX];
    if (currentIndexStr == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"no currentIndex saved");
        NSError *error = [WIError internalError:@"no currentIndex saved"];
        return nil;
    }
    NSString *passPhrase = [self __createPassphrase];
    int index = [currentIndexStr intValue];
    
    return [WIMnemonicsInfo generateWith:decryptedMn passphrase:passPhrase currentIndex:index];
}

// 理完
// 创建并保存 master key.
- (void)__createNewMasterKeyAndSave:(WIKeychainPersistence*)keyStore newWalletName:(NSString *)name unloackPwd:(NSString *)pwd callback:(void (^)(BOOL, NSError *))callback
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    // 1. 生成助记词
    NSString * mnemonic = [WIHDWalletUtils wedpr_hdw_create_mnemonic:12];
    NSString *passPhrase = [self __createPassphrase];
    // 2. 生成 master key
    [self __createMasterKeyFromMnemonic:mnemonic passphrase:passPhrase callback:^(bool result, NSString * masterKey, NSError * error) {
        if (!result) {
            callback(NO, error);
            return;
        }
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"\n>>>>>>>>>[SDK log]>>>>>>>>>\nmnemonic:%@\npassPhrase:%@\nmasterKey:%@",mnemonic,passPhrase,masterKey);
        
        // 3. 设置起始索引
        int currentIndex = WI_HDWALLET_START_INDEX;
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"currentIndex>>>: %d",currentIndex);
        
        NSAssert((mnemonic != nil), @"[SDK Error] - Mnemonic Error!");
        NSAssert((masterKey != nil), @"[SDK Error] - MasterKey Error!");
        
        [self __saveMasterKeyToKeyStore:keyStore masterKey:masterKey mnemonic:mnemonic passPhrase:passPhrase currentIndex:currentIndex unlockPwd:pwd callback:^(BOOL saved, NSError * err) {
            if (saved) {
                // 5. 更新状态
                [self __initHDWalletSuccess:keyStore currentIndex:currentIndex unloackPwd:pwd newWalletName:name];
                callback(YES,nil);
            }else{
                callback(NO,err);
            }
        }];
    }];
    
    
//    // 4. 保存
//    BOOL saved = [self __saveMasterKeyToKeyStore:keyStore
//                                       masterKey:masterKey
//                                        mnemonic:mnemonic
//                                      passPhrase:passPhrase
//                                    currentIndex:currentIndex
//                                       unlockPwd:pwd];
//    if(saved){
//        // 5. 更新状态
//        [self __initHDWalletSuccess:keyStore currentIndex:currentIndex unloackPwd:pwd newWalletName:name];
//    }
//    return saved;
}

//理完
/// 通过 master key 创建 key pair
/// @param index current index
- (void)__createKeyPair:(int)index callback:(void (^)(WIKeyPairModel *,NSError *)) callback
{
    NSAssert(self.inited, @"[SDK Error] - create key pair,but hd wallet is not initd.");
    if (!self.inited){
        NSError *error = [WIError normalError:@"wallet has not initialized" errcode:ERR_NOT_INIT];
        callback(nil,error);
        return;
        
    }
    [self __loadMasterKeyFromLocal:self.keyStore unlockPwd:self.unlockPwd callback:^(NSString * masterKey, NSError * err) {
        if (err != nil) {
            callback(nil,err);
            return;
        }else{
            //NSString *masterKey = mKey;//[self __loadMasterKeyFromLocal:self.keyStore unlockPwd:self.unlockPwd];
            NSAssert((masterKey != nil), @"[SDK Error] - master key is nil.");
            if(masterKey == nil){
                NSError *error = [WIError internalError:@"load masterKey from local failed when createKeyPair"];
                callback(nil,error);
                return;
            }
            callback([self __createKeyPair:masterKey index:index],nil);
        }
    }];
}


//理完
- (WIKeyPairModel *)__createKeyPair:(NSString *)masterKey index:(int)index{
    /**
     //purpose: 44
     //coin type: 513866
     //account : 0   (未来会支持多账户)
     //Change : 0  (未来可能为0或者1)
     //Index ： 每次自增即可
     */
    WIKeyPairModel* keyPair = [WIHDWalletUtils wedpr_extended_key:masterKey
                                                purpose_type:44
                                                   coin_type:513866
                                                     account:1
                                                      change:0
                                               address_index:index];
    [WISDKLog log:__func__ desc:@"create key pair" argKeys:@[@"master key",@"index",@"keyPair"] argValues:@[masterKey,@(index),keyPair]];
    return keyPair;
}

//理完
- (void)__loadHDWalletFromLocal:(WIKeychainPersistence *)keyStore unlockPwd:(NSString *)pwd callback:(void (^)(WIWalletInfo *, NSError *)) callback
{
    // get wallet info.
    [self __loadWalletInfo:keyStore unlockPwd:pwd callback:^(WIWalletInfo * wallet, NSError * err) {
        if (err != nil) {
            callback(nil,err);
            return;
        }else{
            if (wallet != nil){
                [self __initHDWalletSuccess:keyStore currentIndex:wallet.currentIndex unloackPwd:pwd newWalletName:nil];
            }
            callback(wallet,nil);
            return;
        }
    }];
}

//理完
- (void)__loadWalletInfo:(WIKeychainPersistence *)keyStore unlockPwd:(NSString *)unlockPwd callback:(void (^)(WIWalletInfo *, NSError *)) callback
{
    //TODO: 重构代码,将获取 masterkey 和 index 封装在一起.
    // load master key
    [self __loadMasterKeyFromLocal:keyStore unlockPwd:unlockPwd callback:^(NSString * mKey, NSError * err) {
        if (err != nil) {
            callback(nil,err);
            return;
        }else{
            NSString *masterKey = mKey ;
            if(masterKey == nil){
                [WISDKLog log:__func__ desc:@"Load HDWallet Info Failed, Master Key is nil"];
                NSError *error = [WIError normalError:@"decrypt masterKey failed, check your unlockPwd" errcode:ERR_UNLOCK_PWD];
                callback(nil,error);
                return;
            }
            // load current index
            
            
        //    NSString *keyFromPwd = [self __getKeyFromPwd:unlockPwd];
            NSString *encryptedIndexStr = [keyStore get:WI_HDWALLET_KEY_CURRENT_INDEX];
        //    NSString *index = [WICryptoUtils aesDecryptString:encryptedIndexStr key:keyFromPwd];
            NSString *index = encryptedIndexStr;
            int currentIndex = MAX([index intValue], WI_HDWALLET_START_INDEX);
            WIWalletInfo *wallet = [WIWalletInfo walletInfoWith:masterKey currentIndex:currentIndex];
            callback(wallet,nil);
        }
    }];
    
}

// 理完
- (void )__loadMasterKeyFromLocal:(WIKeychainPersistence *)keyStore unlockPwd:(NSString *)unlockPwd callback:(void(^)(NSString *, NSError *)) callback
{
    // 从 keychain 获取加密数据
    NSString *encryptedMasterKey = [keyStore get:WI_HDWALLET_KEY_MASTER_KEY];
    if(encryptedMasterKey == nil){
        [WISDKLog log:__func__ desc:@"从本地加载 master key Failed:encrypted MasterKey is nil"];
        NSError *error = [WIError internalError:@"wallet key is nil"];
        callback(nil,error);
        return;
    }
    
    NSString *pwdHashLocal = [keyStore get:WI_HDWALLET_KEY_UNLOCK_PWD_HASH];
//    NSAssert(pwdHashLocal != nil, @"pwdHashLocal is nil");
    if(pwdHashLocal == nil){
        [WISDKLog log:__func__ desc:@"从本地加载 master key Failed:pwd Hash Local is nil"];
        NSError *error = [WIError internalError:@"unlock pwd hash is nil"];
        callback(nil,error);
        return ;
    }
    NSString *keyFromPwd = [self __getKeyFromPwd:unlockPwd];
    
    if (keyFromPwd == nil) {
        [WISDKLog log:__func__ desc:@"从本地加载 master key Failed:key From Pwd is nil"];
        NSError *error = [WIError internalError:@"unlock pwd abnormal"];
        NSAssert(keyFromPwd != nil, @"keyFromPwd is nil.");
        callback(nil,error);
        return ;
    }
    BOOL isEqual = [[WICryptoUtils wedpr_keccak256:keyFromPwd isHex:NO] isEqualToString:pwdHashLocal];
    
    if (!isEqual) {
        [WISDKLog log:__func__ desc:@"从本地加载 master key Failed: 密码 hash 校验失败"];
        NSAssert(isEqual, @"密码 hash 校验失败.");
        NSError *error = [WIError normalError:@"unlockPwd is invalid" errcode:ERR_UNLOCK_PWD];
        callback(nil,error);
        return ;
    }else{
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@">>>>>> Hash 相同");
    }
    
    NSString *masterKey = [WICryptoUtils aesDecryptString:encryptedMasterKey key:keyFromPwd];
    if (masterKey == nil) {
        [WISDKLog log:__func__ desc:@"从本地加载 master key Failed:aes 解密 master key 失败" argKeys:@[@"encryptedMasterKey",@"keyFromPwd"] argValues:@[encryptedMasterKey,keyFromPwd]];
        NSAssert(masterKey != nil, @"masterKey 解密失败.");
        NSError *error = [WIError normalError:@"从本地加载 master key Failed:aes 解密 master key 失败" errcode:ERR_UNLOCK_PWD];
        callback(nil,error);
        return;
    }
    
    // 返回 base64 格式的 master key
    [WISDKLog log:__FUNCTION__ desc:@"从本地加载 master key 成功" argKeys:@[@"unlockPwd",@"masterKey"] argValues:@[unlockPwd,masterKey]];
    callback(masterKey ,nil);
}

// 理完
- (void)__initHDWalletSuccess:(WIKeychainPersistence *)keyStore currentIndex:(int)index unloackPwd:(NSString *)pwd newWalletName:(NSString *)name
{
    if (name != nil) {
        [[WIWalletManager manager] setCurrentWallet:name];
        [WISDKLog log:__func__ desc:@"init HD wallet succeed." argKeys:@[@"index",@"unlockpwd",@"newWalletName"] argValues:@[@(index),pwd,name]];
    }else{
        [WISDKLog log:__func__ desc:@"init HD wallet succeed." argKeys:@[@"index",@"unlockpwd",@"newWalletName"] argValues:@[@(index),pwd,[[WIWalletManager manager] getCurrentWallet]]];
    }
    
    
    self.keyStore = keyStore;
    self.currentIndex = index;
    self.inited = YES;
    self.unlockPwd = pwd;
    
}

// 理完
/// 保存 master key
/// @param keyStore   keychain
/// @param masterKey master key
/// @param mnemonic   助记词
/// @param phrase        phrase pwd
/// @param index          current index
- (void)__saveMasterKeyToKeyStore:(WIKeychainPersistence *)keyStore
                        masterKey:(NSString *)masterKey
                         mnemonic:(NSString *)mnemonic
                       passPhrase:(NSString *)phrase
                     currentIndex:(int)index
                        unlockPwd:(NSString *)unlockPwd
                         callback:(void (^)(BOOL, NSError *))callback
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    NSString *indexString = [NSString stringWithFormat:@"%d",index];
    
    //对称加密的密钥 = hash(hash(unlockPwd))
    NSString *keyFromPwd   = [self __getKeyFromPwd:unlockPwd];
    if (keyFromPwd == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"get pwd hash hash failed");
        NSError *error = [WIError internalError:@"get key from unlock pwd failed"];
        callback(NO,error);
        return;
    }
    
    // keyHash = hash(对称加密的密钥),存起来用来下次验证密钥的正确性
    NSString *keyHash = [WICryptoUtils wedpr_keccak256:keyFromPwd isHex:NO];
    if (keyHash == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"get key hash failed");
        NSError *error = [WIError internalError:@"get pwd hash failed"];
        callback(NO,error);
        return;
    }
    
    // 对称加密存储的内容
    NSString *encryptedMasterKey    = [WICryptoUtils aesEncryptString:masterKey   key:keyFromPwd];
    NSString *encryptedMnemonics    = [WICryptoUtils aesEncryptString:mnemonic    key:keyFromPwd];
//    NSString *encryptedCurrentIndex = [WICryptoUtils aesEncryptString:indexString key:keyFromPwd];
    NSString *encryptedCurrentIndex = indexString;

    int add = [keyStore batchAdd:
               @{
                   WI_HDWALLET_KEY_MASTER_KEY:encryptedMasterKey,
                   WI_HDWALLET_KEY_MNEMONICS:encryptedMnemonics,
                   WI_HDWALLET_KEY_CURRENT_INDEX:encryptedCurrentIndex,
                   WI_HDWALLET_KEY_UNLOCK_PWD_HASH:keyHash
               }];
    NSAssert(add == 1, @"[SDK Error] - Save Master Key Failed!");
    
    NSString *log = [NSString stringWithFormat:@"\n\n\n==========>>> Save master key success.\nmasterKey:%@\nmnemonic:%@\nindexString:%@\naeskey:%@\nencryptedMasterKey:%@",masterKey,mnemonic,indexString,keyFromPwd,encryptedMasterKey];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%@",log);
    
    if(add==0){
        NSError *error = [WIError internalError:@"save master key failed"];
        callback(NO,error);
    }else{
        callback(YES,nil);
    }
}

- (NSString *)__getKeyFromPwd:(NSString *)unlockPwd{
    // unlock pwd 两次 hash 作为密码
    return [WICryptoUtils hashTwice:unlockPwd];
}

- (NSString *) __createPassphrase{
    return WI_HDWALLET_PASSPHRASE;
}
// 理完
- (void)__createMasterKeyFromMnemonic:(NSString *)mnemonic passphrase:(NSString *)passphrase callback:(void (^)(bool,NSString *,NSError *)) callback
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    NSString *masterKey = [WIHDWalletUtils wedpr_create_master_key:passphrase mnemonic:mnemonic];
    if (masterKey == nil) {
        
        NSError *error = [NSError errorWithDomain:@"WeHDWallet" code:ERR_CREATE_MASTERKEY userInfo:@{NSLocalizedDescriptionKey:@"[SDK Error] - wedpr_create_master_key error."}];// [WIError internalError:@"[SDK Error] - wedpr_create_master_key error."];
        callback(NO,nil,error);
    }else{
        callback(YES,masterKey,nil);
    }
}

@end


@implementation WIDomainInfo

+ (instancetype)domainInfo:(NSString *)domain encrypted:(BOOL)encrypted domainPwd:(NSString *)domainPwd{
    WIDomainInfo *domainInfo = [WIDomainInfo new];
    domainInfo.domain = domain;
    domainInfo.encrypted = encrypted;
    domainInfo.domainPwd = domainPwd;
    return domainInfo;
}

@end
