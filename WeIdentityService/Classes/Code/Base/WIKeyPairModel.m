//
//  WIKeyPair.m
//  HKard
//
//  Created by tank on 2020/8/26.
//  Copyright © 2020 tank. All rights reserved.
//

#import "WIKeyPairModel.h"


@implementation WIPublicKey

+ (instancetype)publicKeyWith:(NSString *)key{
    WIPublicKey *pubKey = [WIPublicKey new];
    pubKey.publicKey = key;
    return pubKey;
}

-(NSString *)description{
    return self.publicKey;
}
@end

@implementation WIPrivateKey
+ (instancetype)privateKeyWith:(NSString *)key{
    WIPrivateKey *priKey = [WIPrivateKey new];
    priKey.privateKey = key;
    return priKey;
}
-(NSString *)description{
    return self.privateKey;
}

@end

@implementation WIKeyPairModel

+ (instancetype)keyPairWithPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey{
    WIKeyPairModel *keyPair = [WIKeyPairModel new];
    keyPair.privateKey = [WIPrivateKey privateKeyWith:privateKey];
    keyPair.publicKey  = [WIPublicKey  publicKeyWith: publicKey];
    return keyPair;
}

- (NSString *)privateKeyString{
    return self.privateKey.privateKey;
}

- (NSString *)publicKeyString{
    return self.publicKey.publicKey;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"\n===key pair===\nprivate_key:%@\npublic_key:%@",self.privateKey,self.publicKey];
}

@end
