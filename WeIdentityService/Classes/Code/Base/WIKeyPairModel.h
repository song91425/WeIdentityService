//
//  WIKeyPair.h
//  HKard
//
//  Created by tank on 2020/8/26.
//  Copyright © 2020 tank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIPublicKey : NSObject
@property(nonatomic, copy) NSString *publicKey;

+ (instancetype)publicKeyWith:(NSString *)key;

@end

@interface WIPrivateKey : NSObject
@property(nonatomic, copy) NSString *privateKey;

+ (instancetype)privateKeyWith:(NSString *)key;
@end


@interface WIKeyPairModel : NSObject

+ (instancetype)keyPairWithPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey;

@property(nonatomic, strong) WIPrivateKey *privateKey;
@property(nonatomic, strong) WIPublicKey  *publicKey;

- (NSString *)privateKeyString;
- (NSString *)publicKeyString;

@end

NS_ASSUME_NONNULL_END
