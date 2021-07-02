//
//  WIMnemonicsInfo.m
//  WeIdentityService
//
//  Created by tank on 2020/12/28.
//

#import "WIMnemonicsInfo.h"

@implementation WIMnemonicsInfo
+ (instancetype)generateWith:(NSString *)mnemonics passphrase:(NSString *)passphrase currentIndex:(int)index{
    WIMnemonicsInfo *info = [WIMnemonicsInfo new];
    info.mnemonics = mnemonics;
    info.passphrase = passphrase;
    info.currentIndex = index;
    return info;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"====WIMnemonicsInfo\nmnemonics:%@\npassphrase:%@\ncurrentIndex:%d",self.mnemonics,self.passphrase,self.currentIndex];
}

@end
