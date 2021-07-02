//
//  WIHDWalletInternalService.m
//  WeIdentityService
//
//  Created by tank on 2021/1/18.
//

#import "WIHDWalletInternalService.h"
#import "WIHDWallet.h"

static WIHDWalletInternalService *service = nil;

@interface WIHDWalletInternalService()

@end

@implementation WIHDWalletInternalService

+ (instancetype)sharedService{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [WIHDWalletInternalService new];
    });
    return service;
}

- (void)initHDWalletWithMnemonics:(NSString *)mnemonics
                     currentIndex:(int)currentIndex
                        unlockPwd:(NSString *)unlockPwd
             deletePreviousWallet:(BOOL)deletePreviousWallet
                         callback:(void(^)(BOOL , NSError *))callback
{
    [[WIHDWallet sharedInstance] initHDWalletWithMnemonics:mnemonics
                                              currentIndex:currentIndex
                                                 unlockPwd:unlockPwd
                                      deletePreviousWallet:deletePreviousWallet
                                                  callback:^(BOOL res, NSError * err) {
        callback(res,err);
    }];
}

- (void)createKeyPair:(void(^)(WIHDWalletKeyPair *keyPair, NSError *error))callback{
    [[WIHDWallet sharedInstance] createKeyPairSuccess:^(WIKeyPairModel * _Nonnull keyPair, int index) {
            WIHDWalletKeyPair *kp = [WIHDWalletKeyPair keyPairWith:keyPair index:index];
            callback(kp,nil);
        } fail:^(NSError * err) {
            callback(nil,err);
        }];
//    [[WIHDWallet sharedInstance] createKeyPair:^(WIKeyPairModel * _Nonnull keyPair, int index) {
//        WIHDWalletKeyPair *kp = [WIHDWalletKeyPair keyPairWith:keyPair index:index];
//        callback(kp);
//    }];
    
}


- (void)saveWIKeyPair:(NSString *)weid
                keyId:(NSString *)keyId
              keyPair:(WIHDWalletKeyPair *)keyPair
             transPwd:(NSString *)transPwd
             callback:(void(^)(BOOL sucess))callback{
    BOOL res = [[WIHDWallet sharedInstance] saveWIKeyPairAfterCreateWeId:weid
                                                                   keyId:keyId
                                                                 keyPair:keyPair
                                                                transPwd:transPwd];
    if(callback) callback(res);
    
}

- (void)saveWeIdInfoAndCurrentIndex:(NSArray *)allWeIdList
                     allKeyPairList:(NSArray *)allKeyPairList
                       currentIndex:(int)currentIndex
                           callback:(void(^)(BOOL succeed))callback
{
    BOOL res = [[WIHDWallet sharedInstance] saveWeIdInfoAndCurrentIndex:currentIndex
                                                            allWeIdList:allWeIdList
                                                         allKeyPairList:allKeyPairList];
    callback(res);
}

- (void)getWIKeyPairByWeId:(NSString *)weId
                     keyId:(NSString *)keyId
                  transPwd:(NSString *)transPwd
                  callback:(void(^)(WIKeyPairModel *keyPair))callback{
    WIKeyPairModel * kp = [[WIHDWallet sharedInstance] getWIKeyPair:weId
                                                              keyId:keyId
                                                           transPwd:transPwd];
    
    if(callback) callback(kp);
}

- (void)getPublicKeyList:(int)start size:(int)size callback:(void(^)(BOOL succeed,NSArray *keyPairList, NSError *error))callback
{
    [[WIHDWallet sharedInstance] getPublicKeyList:start size:size callback:^(NSArray<WIKeyPairModel *> * publicKeyList, NSError *  err) {
        if (publicKeyList != nil && publicKeyList.count > 0) {
            if (callback)
                callback(YES, publicKeyList,nil);
        }else{
            if (callback)
                callback(NO, nil,nil);
        }
    }];
}

- (void)updateCurrentIndex:(int)keyPairIndex callback:(void(^)(BOOL succeed))callback
{
    BOOL res = [[WIHDWallet sharedInstance] addAndUpdateCurrentIndex:keyPairIndex];
    if (callback) {
        callback(res);
    }
}
@end

