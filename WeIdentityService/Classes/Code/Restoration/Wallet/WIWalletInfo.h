//
//  WalletInfo.h
//  WeIdentityService
//
//  Created by tank on 2020/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIWalletInfo : NSObject

@property (nonatomic, copy) NSString *masterKey;
@property (nonatomic, assign) int currentIndex;

+ (WIWalletInfo *)walletInfoWith:(NSString *)masterKey currentIndex:(int)index;

@end

NS_ASSUME_NONNULL_END
