//
//  WalletInfo.m
//  WeIdentityService
//
//  Created by tank on 2020/12/28.
//

#import "WIWalletInfo.h"

@implementation WIWalletInfo

+ (WIWalletInfo *)walletInfoWith:(NSString *)masterKey currentIndex:(int)index;{
    WIWalletInfo *info = [WIWalletInfo new];
    info.masterKey = masterKey;
    info.currentIndex = index;
    return info;
}

- (NSString *)description{
    return [NSString stringWithFormat:@">>>\n>>> master key:%@\n>>> currentIndex:%d",self.masterKey,self.currentIndex];
}

@end
