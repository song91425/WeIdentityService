//
//  WIHDWalletKeyPair.h
//  WeIdentityService
//
//  Created by tank on 2021/1/18.
//

#import <Foundation/Foundation.h>
#import "WIKeyPairModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WIHDWalletKeyPair : NSObject
@property (nonatomic, assign) int keyPairIndex;
@property (nonatomic, strong) WIKeyPairModel *keyPair;

+(instancetype)keyPairWith:(WIKeyPairModel *)keyPair index:(int)index;

- (NSString *)publicKey;
- (NSString *)privateKey;
@end

NS_ASSUME_NONNULL_END
