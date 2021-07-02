//
//  WIRestorationService.m
//  WeIdentityService
//
//  Created by tank on 2021/1/21.
//

#import "WIRestorationService.h"
#import "WIHDWallet.h"
#import "WIHDWalletInternalService.h"
#import "WIWeIdentityService.h"
#import "WIWalletManager.h"
#import "WICryptoUtils.h"
#import "WIError.h"
#import "WISDKLog.h"
static WIRestorationService *service = nil;

static int const WIRestorationWeIDBucket = 10;

@interface WIRestorationService()

@property (nonatomic, strong)NSMutableArray *allWeIdList;
@property (nonatomic, strong)NSMutableArray *allKeyPairList;

@end

@implementation WIRestorationService

+ (instancetype)sharedService
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [WIRestorationService new];

    });
    return service;
}


/// 通过助记词恢复钱包和weid列表
/// @param mnemonics 助记词
/// @param unlockPwd 解锁密码
/// @param callback 回调
///
/// @detail
/// 1. 通过[com.openchopstick.restoration.WIHDWalletService]恢复钱包
/// 2. 通过后台接口恢复weid列表和currentIndex

- (void)initHDWalletWithMnemonics:(NSString *)mnemonics unlockPwd:(NSString *)unlockPwd callback:(void(^)(BOOL,NSError *))callback
{
    NSString *validateMnmeonies = [self p_validateParamsCount:mnemonics];
    //通过助记词恢复钱包但先不删除老钱包
    [[WIHDWalletInternalService sharedService] initHDWalletWithMnemonics:validateMnmeonies
                                                                       currentIndex:0
                                                                          unlockPwd:unlockPwd
                                                               deletePreviousWallet:NO
                                                                           callback:^(BOOL succeed, NSError *err) {
        if (!succeed) {
            if (err.code == ERR_CREATE_MASTERKEY) {
                callback(NO,err);
                return;
            }
            [self __initHDWalletFailed:callback];
            return;
        }
        int start = 1000;
        int size = WIRestorationWeIDBucket;
        service.allWeIdList = [NSMutableArray new];
        service.allKeyPairList = [NSMutableArray new];
        [self __getWeIdByPubKeyListFrom:start size:size callback:callback];
    }];
}


/// 规范化助记词的空格
/// @param mnemonics
-(NSString *) p_validateParamsCount:(NSString *)mnemonics{
    NSMutableString * mStr = [NSMutableString string];
    NSArray *arrs = [mnemonics componentsSeparatedByString:@" "];
    for (NSString *str in arrs) {
        if ( [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
            [mStr appendFormat:str];
            [mStr appendFormat:@" "];
        }
    }
    
    return [mStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)__getWeIdByPubKeyListFrom:(int)start size:(int)size callback:(void(^)(BOOL,NSError *))callback
{
    [[WIHDWalletInternalService sharedService] getPublicKeyList:start
                                                           size:size
                                                       callback:^(BOOL succeed, NSArray * _Nonnull keyPairList, NSError *error) {
        if (succeed) {
            [self __getWeIdByPubKeyListFrom:start
                                       size:size
                                keyPairList:keyPairList
                                   callback:callback];
        }else{
            [self __initHDWalletFailed:callback];
        }
    }];
}

- (void)__getWeIdByPubKeyListFrom:(int)start
                             size:(int)size
                      keyPairList:(NSArray *)keyPairList
                         callback:(void(^)(BOOL,NSError *))callback
{
    NSMutableArray *mutaPubKeyList = [NSMutableArray array];
    for (WIKeyPairModel *keyPair in keyPairList) {
        NSString *b64PubKey = [WICryptoUtils b64StringFromHexString:[keyPair publicKeyString]];
        [mutaPubKeyList addObject: b64PubKey];
    }
    NSArray *pubKeyList = [NSArray arrayWithArray:mutaPubKeyList];
    [[WIWeIdentityService sharedService] getWeIdByPubKeyList:pubKeyList
                                                    callback:^(BOOL success, NSString * _Nonnull msg, NSArray * _Nonnull weIdList) {
        if (!success) {
            // init failed
            [self __initHDWalletFailed:callback];
        }else{
            
            if (weIdList.count == pubKeyList.count) {// 继续拉取下一批.
                [self __getWeIdByPubKeyListFrom:start + size size:size callback:callback];
            }else{// 拉取完了.
                
                // 计算 current index
                int currentIndex = [self __matchWeIdWithKeyPair:start data:weIdList keyPairList:keyPairList];
                
                [self __afterRestoreWeIdListAndCurrentIndex:currentIndex callback:callback];
            }
        }
        
    }];
}

- (void)getWeIdList:(void(^)(NSArray* list))callback{
    [WIWalletManager manager];
    [[WIHDWallet sharedInstance] getWeIdList:callback];
}

- (int)__matchWeIdWithKeyPair:(int)start data:(NSArray *)data keyPairList:(NSArray *)keyPairList
{
    for (int i = 0; i < data.count; i++) {
        [self.allWeIdList addObject:data[i]];
        [self.allKeyPairList addObject:keyPairList[i]];
    }
    return (int)(start + data.count);
}

- (void)__afterRestoreWeIdListAndCurrentIndex:(int)currentIndex callback:(void(^)(BOOL,NSError *))callback
{
    [[WIHDWalletInternalService sharedService] saveWeIdInfoAndCurrentIndex:[NSArray arrayWithArray:self.allWeIdList]
                                                            allKeyPairList:[NSArray arrayWithArray:self.allKeyPairList]
                                                              currentIndex:currentIndex
                                                                  callback:^(BOOL succeed) {
        if (succeed) {
            // 恢复成功
            [[WIWalletManager manager] deletePreviousWallet];
            callback(YES,nil);
        }else{
            // 恢复失败
            [self __initHDWalletFailed:callback];
        }
    }];
}

- (void)__initHDWalletFailed:(void(^)(BOOL,NSError *))callback
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    //删除新钱包
    NSString *current = [[WIWalletManager manager] getCurrentWallet];
    [[WIWalletManager manager] deleteWallet:current];
    
    //恢复老钱包
    NSString *previous =[[WIWalletManager manager] getPreviousWallet];
    if (previous != nil) {
        [[WIWalletManager manager] setCurrentWallet:previous];
    }
    NSError *err = [WIError normalError:@"Failed to import wallet." errcode:-1];
    if (callback) callback(NO,err);
}


@end
