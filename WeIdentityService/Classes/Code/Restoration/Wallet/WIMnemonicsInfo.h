//
//  WIMnemonicsInfo.h
//  WeIdentityService
//
//  Created by tank on 2020/12/28.
//

#import <Foundation/Foundation.h>
#import "WIKeyPairModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface WIMnemonicsInfo : NSObject

@property (nonatomic, copy) NSString *mnemonics;
@property (nonatomic, copy) NSString *passphrase;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, strong) WIPrivateKey *masterKey;

+ (instancetype)generateWith:(NSString *)mnemonics passphrase:(NSString *)passphrase currentIndex:(int)index;

@end

NS_ASSUME_NONNULL_END
