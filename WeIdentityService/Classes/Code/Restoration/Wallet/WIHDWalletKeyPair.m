//
//  WIHDWalletKeyPair.m
//  WeIdentityService
//
//  Created by tank on 2021/1/18.
//

#import "WIHDWalletKeyPair.h"


@implementation WIHDWalletKeyPair

+(instancetype)keyPairWith:(WIKeyPairModel *)keyPair index:(int)index{
    WIHDWalletKeyPair *kp = [WIHDWalletKeyPair new];
    kp.keyPair = keyPair;
    kp.keyPairIndex = index;
    return kp;
}

-(NSString *)publicKey{
    return [self.keyPair publicKeyString];
}

- (NSString *)privateKey{
    return [self.keyPair privateKeyString];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"=== WIHDWalletKeyPair === \n%@\nkeyPairIndex:%d",self.keyPair,self.keyPairIndex];
}

@end
