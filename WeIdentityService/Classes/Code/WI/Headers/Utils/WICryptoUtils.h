//
//  WICryptoUtils.h
//  HKard
//
//  Created by tank on 2020/8/26.
//  Copyright © 2020 tank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WIKeyPairModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WICryptoUtils : NSObject

// TODO: SEP21
/// Generate Key Pair
+ (WIKeyPairModel *)generateKeyPair;

/// Encrypt API, return cipher text string.
/// @param hexPublicKey Public Key
/// @param hexPlainText Plain Text
+ (NSString *)eciesSecp256k1Encrypt:(NSString *)hexPublicKey hexPlainText:(NSString *)hexPlainText;

/// Decrypt API, return plain text string.
/// @param hexPrivateKey Private Key
/// @param hexCipherText Cipher Text
+ (NSString *)eciesSecp256k1Decrypt:(NSString *)hexPrivateKey hexCipherText:(NSString *)hexCipherText;

/// Sign API, return sign string.
/// @param hexPrivateKey Private Key
/// @param message              Hash String
+ (NSString *)wedprCryptoSecp256k1Sign:(NSString *)hexPrivateKey message:(NSString *)message;


/// calculate keccak256 hash
/// @param content  Content String
+ (NSString *)wedpr_keccak256:(NSString *)content isHex:(BOOL)isHex;

/// Verigy Sign API, retun YES when verify succeed.
/// @param hexPublicKey Public Key
/// @param message            Hash String
/// @param signatureString  Signature
+ (BOOL)wedprSecp256k1VerifySign:(NSString *)hexPublicKey message:(NSString *)message signature:(NSString *)signatureString;

+ (NSString *)hexStringFromString:(NSString *)string;

/// Twice hash calculation
/// @param content content, return hex string!!!!!!!!
+ (NSString *)hashTwice:(NSString *)content;


+ (NSString *)hexStringFromB64String:(NSString *)string;

+ (NSString *)b64StringFromHexString:(NSString *)hex;

+ (NSString *)aesEncryptString:(NSString *)content key:(NSString *)key;

+ (NSString *)aesDecryptString:(NSString *)content key:(NSString *)key;

+ (NSString *)createRandomStr:(int)len;

@end

NS_ASSUME_NONNULL_END


/*
 WeIdService
 1. createWeid
 2. getWIDocument
 
 CredentialService
 1.createCredential
 2.verify
 3.get
 4.set
 
 EvidenceService
 1.createEvidence
 2.getEvidence
*/
