//
//  WIHDWalletInternalService.h
//  WeIdentityService
//
//  Created by tank on 2021/1/18.
//

#import <Foundation/Foundation.h>
#import "WIHDWalletKeyPair.h"

NS_ASSUME_NONNULL_BEGIN


@interface WIHDWalletInternalService : NSObject

+ (instancetype)sharedService;


- (void)initHDWalletWithMnemonics:(NSString *)mnemonics
                     currentIndex:(int)currentIndex
                        unlockPwd:(NSString *)unlockPwd
             deletePreviousWallet:(BOOL)deletePreviousWallet
                         callback:(void(^)(BOOL succeed, NSError *error))callback;

- (void)createKeyPair:(void(^)(WIHDWalletKeyPair *keyPair,NSError *error))callback;

- (void)saveWeIdInfoAndCurrentIndex:(NSArray *)allWeIdList
                     allKeyPairList:(NSArray *)allKeyPairList
                       currentIndex:(int)currentIndex
                           callback:(void(^)(BOOL succeed))callback;

- (void)saveWIKeyPair:(NSString *)weid
                keyId:(NSString *)keyId
              keyPair:(WIHDWalletKeyPair *)keyPair
             transPwd:(NSString *)transPwd
             callback:(void(^)(BOOL succeed))callback;

- (void)updateCurrentIndex:(int)index callback:(void(^)(BOOL succeed))callback;

- (void)getWIKeyPairByWeId:(NSString *)weId
                     keyId:(NSString *)keyId
                  transPwd:(NSString *)transPwd
                  callback:(void(^)(WIKeyPairModel *keyPair))callback;

- (void)getPublicKeyList:(int)start size:(int)size callback:(void(^)(BOOL succeed,NSArray *keyPairList, NSError *error))callback;


@end

NS_ASSUME_NONNULL_END
