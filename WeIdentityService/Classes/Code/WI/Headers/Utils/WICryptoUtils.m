//
//  WICryptoUtils.m
//  HKard
//
//  Created by tank on 2020/8/26.
//  Copyright © 2020 tank. All rights reserved.
//

#import "WICryptoUtils.h"
#import "wedpr_ios.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "WISDKLog.h"
@implementation WICryptoUtils

+ (WIKeyPairModel *)generateKeyPair{
    
    char *keyPair = wedpr_secp256k1keyPair();
    NSString *keys = [NSString stringWithCString:keyPair encoding:NSUTF8StringEncoding];
    NSArray *arr = [keys componentsSeparatedByString:@"|"];
    WIKeyPairModel *model = [WIKeyPairModel keyPairWithPublicKey:arr[0] privateKey:arr[1]];
    return model;
}

+ (NSData *)dataFromHexadecimalString:(NSString *)hexStr
{
    // in case the hexadecimal string is from `NSData` description method (or `stringWithFormat`), eliminate
    // any spaces, `<` or `>` characters

    NSString *hexadecimalString = [hexStr stringByReplacingOccurrencesOfString:@"[ <>]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [hexStr length])];

    NSMutableData * data = [NSMutableData dataWithCapacity:[hexadecimalString length] / 2];
    for (NSInteger i = 0; i < [hexadecimalString length]; i += 2) {
        NSString *hexChar = [hexadecimalString substringWithRange: NSMakeRange(i, 2)];
        int value;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        uint8_t byte = value;
        [data appendBytes:&byte length:1];
    }
    return data;
}


+ (NSString *)xxx:(char *)plain{
    NSMutableString * result = [[NSMutableString alloc] init];
    int i;
    for (i=0; i<4; i++) {
        [result appendString:[NSString stringWithFormat:@"%02x",plain[i]]];
    }
    // NSLog(@"%@",result);
    return result;
}

+ (NSString *)eciesSecp256k1Encrypt:(NSString *)hexPublicKey hexPlainText:(NSString *)hexPlainText{
    char *c_hexPublicKey = [self cString:hexPublicKey];
    char *c_hexPlainText = [self cString:hexPlainText];
    char * res = ecies_secp256k1_encrypt_c(c_hexPublicKey, c_hexPlainText);
    return [self hexNSStringFrom:res];
}

+ (NSString *)eciesSecp256k1Decrypt:(NSString *)hexPrivateKey hexCipherText:(NSString *)hexCipherText{
    char * res = ecies_secp256k1_decrypt_c([self cString:hexPrivateKey], [self cString:hexCipherText]);
    return [self hexNSStringFrom:res];
}

+ (NSString *)wedprCryptoSecp256k1Sign:(NSString *)hexPrivateKey message:(NSString *)message{
    char *hexPk = [self cString:hexPrivateKey];
    char *hash = wedpr_keccak256([self cString:message]);
    char *res = wedpr_crypto_secp256k1Sign(hexPk,hash);
    return [self hexNSStringFrom:res];
}

// https://base64.guru/converter/decode/hex
+ (BOOL)wedprSecp256k1VerifySign:(NSString *)hexPublicKey message:(NSString *)message signature:(NSString *)signatureString{
//    char *hash = wedpr_keccak256([self cString:message]);
    char *hash = [self cString:message];
    int ret = wedpr_secp256k1verify([self cString:hexPublicKey], hash, [self cString:signatureString]);
    return (ret == 0);
}


+ (NSString *)wedpr_keccak256:(NSString *)content isHex:(BOOL)isHex{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    if (isHex) {
        char * res = wedpr_keccak256([self cString:content]);
        return [self hexNSStringFrom:res];
    }else{
        char * res = wedpr_keccak256([self cString:[self hexStringFromString:content]]);
        return [self hexNSStringFrom:res];
    }
    
}

+ (NSString *)hashTwice:(NSString *)content{
//    NSLog(@"%s",__func__);
    NSString *hash1 = [self wedpr_keccak256:content isHex:NO];
    NSString *hash2 = [self wedpr_keccak256:hash1 isHex:NO];
    NSAssert(hash1 != nil, @"第一次hash计算失败");
    NSAssert(hash1 != nil, @"第二次hash计算失败");
//    NSLog(@"content:%@",content);
//    NSLog(@"hash1  :%@",hash1);
//    NSLog(@"hash2  :%@",hash2);
    return hash2;
}

+ (NSString *)aesEncryptString:(NSString *)content key:(NSString *)key{
//    NSLog(@"%s",__func__);
//    NSLog(@"content:%@",content);
//    NSLog(@"key    :%@",key);
    NSString *res = [self aes256_encrypt:content key:key];
//    NSAssert(res != nil, @"aes 加密失败.");
//    NSLog(@"result :%@",res);
    return res;
}
+ (NSString *) aesDecryptString:(NSString *)content key:(NSString *)key{
    if(WISDKLog.sharedInstance.printLog){
        NSLog(@"%s",__func__);
        NSLog(@"content:%@",content);
        NSLog(@"key    :%@",key);
    }
    NSString *res = [self aes256_decrypt:content key:key];
//    NSAssert(res != nil, @"aes 解密失败.");
//    NSLog(@"result :%@",res);
    return res;
}

+ (char *)cString:(NSString *)nsString{
    return (char *)[nsString cStringUsingEncoding:kCFStringEncodingUTF8];;
}

+ (char *)cStringA:(NSString *)nsString{
    return (char *)[nsString cStringUsingEncoding:kCFStringEncodingUTF8];;
}

//// string to Hex string.wedpr_keccak256
+ (NSString *)hexStringFromString:(NSString *)string{
//     NSLog(@"%s",__func__);
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
//     NSLog(@"string:%@",string);
//     NSLog(@"hex   :%@",hexStr);
    return hexStr;
}

+ (NSString *)hexStringFromB64String:(NSString *)string{
    NSData *decode = [self __base64Decode:string];
    NSString *hex = [self __hexStringFromData:decode];
    return hex;
}

//+ (BOOL)__checkB64ToHex:(NSString *)b64 hexString:(NSString *)hex{
//
//    NSString *res = [self b64StringFromHexString:hex];
//
//    return [res isEqualToString:b64];
//}
//
//+ (BOOL)__checkHexToB64:(NSString *)hex B64String:(NSString *)b64{
//    NSString *res = [self b64StringFromHexString:hex];
//
//    return [res isEqualToString:b64];
//}

+ (NSString *)__hexStringFromData:(NSData *)data{
    NSMutableString *str = [NSMutableString string];
    Byte *byte = (Byte *)[data bytes];
    for (int i = 0; i<[data length]; i++) {
        // byte+i为指针
        [str appendString:[self __stringFromByte:*(byte+i)]];
    }
    return str;
}
// byte 2 hex
+ (NSString *)__stringFromByte:(Byte)byteVal{
    NSMutableString *str = [NSMutableString string];
     
    //取高四位
    Byte byte1 = byteVal>>4;
    //取低四位
    Byte byte2 = byteVal & 0xf;
    //拼接16进制字符串
    [str appendFormat:@"%x",byte1];
    [str appendFormat:@"%x",byte2];
    return str;
}
 
// Base64 2 Data
+ (NSData*) __base64Decode:(NSString *)string{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[4];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
     
    if (string == nil) {
        return [NSData data];
    }
     
    ixtext = 0;
     
    tempcstring = (const unsigned char *)[string UTF8String];
     
    lentext = [string length];
     
    theData = [NSMutableData dataWithCapacity: lentext];
     
    ixinbuf = 0;
     
    while (true) {
        if (ixtext >= lentext){
            break;
        }
         
        ch = tempcstring [ixtext++];
         
        flignore = false;
         
        if ((ch >= 'A') && (ch <= 'Z')) {
            ch = ch - 'A';
        } else if ((ch >= 'a') && (ch <= 'z')) {
            ch = ch - 'a' + 26;
        } else if ((ch >= '0') && (ch <= '9')) {
            ch = ch - '0' + 52;
        } else if (ch == '+') {
            ch = 62;
        } else if (ch == '=') {
            flendtext = true;
        } else if (ch == '/') {
            ch = 63;
        } else {
            flignore = true;
        }
         
        if (!flignore) {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
             
            if (flendtext) {
                if (ixinbuf == 0) {
                    break;
                }
                 
                if ((ixinbuf == 1) || (ixinbuf == 2)) {
                    ctcharsinbuf = 1;
                } else {
                    ctcharsinbuf = 2;
                }
                 
                ixinbuf = 3;
                 
                flbreak = true;
            }
             
            inbuf [ixinbuf++] = ch;
             
            if (ixinbuf == 4) {
                ixinbuf = 0;
                 
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                 
                for (i = 0; i < ctcharsinbuf; i++) {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
             
            if (flbreak) {
                break;
            }
        }
    }
     
    return theData;
}

+ (NSString *)hexNSStringFrom:(char *)hex { //
    NSAssert(hex != NULL, @"C string is NULL.");
    NSData *data = [NSData dataWithBytes: hex length:strlen(hex)];
    NSString *hexStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSAssert(hexStr != nil, @"C string to NSString Error.");
    return hexStr;
}


// 加密
+ (NSString *) aes256_encrypt:(NSString *)content key:(NSString *)key{
    
    const char *cstr = [content cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:content.length];
    //对数据进行加密
    NSData *result = [self aes256_data_encrypt:data key:key];
    
    //转换为2进制字符串
    if (result && result.length > 0) {
        
        Byte *datas = (Byte*)[result bytes];
        NSMutableString *output = [NSMutableString stringWithCapacity:result.length * 2];
        for(int i = 0; i < result.length; i++){
            [output appendFormat:@"%02x", datas[i]];
        }
        return output;
    }
    return nil;
}


// 解密
+(NSString *) aes256_decrypt:(NSString *)content key:(NSString *)key{
    
    //转换为2进制Data
    NSMutableData *data = [NSMutableData dataWithCapacity:content.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [content length] / 2; i++) {
        byte_chars[0] = [content characterAtIndex:i*2];
        byte_chars[1] = [content characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    
    //对数据进行解密
    NSData* result = [self aes256_data_decrypt:data key:key];
    
    if (result && result.length > 0) {
        
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}

// 加密
+ (NSData *)aes256_data_encrypt:(NSData *)content key:(NSString *)key{
    
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [content length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    //    CCCryptorStatus cryptStatus1 = CCCrypt(<#CCOperation op#>, <#CCAlgorithm alg#>, <#CCOptions options#>, <#const void *key#>, <#size_t keyLength#>, <#const void *iv#>, <#const void *dataIn#>, <#size_t dataInLength#>, <#void *dataOut#>, <#size_t dataOutAvailable#>, <#size_t *dataOutMoved#>)
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [content bytes], dataLength, buffer, bufferSize, &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}


// 解密
+ (NSData *)aes256_data_decrypt:(NSData *)content key:(NSString *)key{
    
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [content length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [content bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        
    }
    free(buffer);
    return nil;
}

+ (NSString *)createRandomStr:(int)len{
    NSString *letterd =@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSUInteger i = 0; i < len; i++) {
        u_int32_t r = arc4random() % [letterd length];
        unichar c = [letterd characterAtIndex:r];
        [randomString appendFormat:@"%C", c];
    }
    return randomString;
}

+ (NSString *)b64StringFromHexString:(NSString *)hex{
    NSString *b64 = [self __base64EncodedStringWithWrapWidth:[self __dataFromHexadecimalString:hex] wrapWidth:0];
    return b64;
//    return [b64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
}

+ (NSData *)__dataFromHexadecimalString:(NSString*)hex
{
    // in case the hexadecimal string is from `NSData` description method (or `stringWithFormat`), eliminate
    // any spaces, `<` or `>` characters

    NSString *hexadecimalString = [hex stringByReplacingOccurrencesOfString:@"[ <>]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [hex length])];

    NSMutableData * data = [NSMutableData dataWithCapacity:[hexadecimalString length] / 2];
    for (NSInteger i = 0; i < [hexadecimalString length]; i += 2) {
        NSString *hexChar = [hexadecimalString substringWithRange: NSMakeRange(i, 2)];
        int value;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        uint8_t byte = value;
        [data appendBytes:&byte length:1];
    }

    return data;
}
+ (NSString *)__base64EncodedStringWithWrapWidth: (NSData *)data wrapWidth:(NSUInteger)wrapWidth
{
    if (![data length]) return nil;
    
    NSString *encoded = nil;
    {
//        NSDataBase64Encoding64CharacterLineLength = 1UL << 0,
//        NSDataBase64Encoding76CharacterLineLength = 1UL << 1,
//
//        // Use zero or more of the following to specify which kind of line ending is inserted. The default line ending is CR LF.
//        NSDataBase64EncodingEndLineWithCarriageReturn = 1UL << 4,
//        NSDataBase64EncodingEndLineWithLineFeed = 1UL << 5,
//        switch (wrapWidth)
//        {
//            case 64:
//            {
//                return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//            }
//            case 76:
//            {
//                return [data base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
//            }
//            default:
//            {
//                encoded = [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
//            }
//        }
        
        encoded = [data base64EncodedStringWithOptions:0];
    }
    
    if (!wrapWidth || wrapWidth >= [encoded length])
    {
        return encoded;
    }
    
    wrapWidth = (wrapWidth / 4) * 4;
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < [encoded length]; i+= wrapWidth)
    {
        if (i + wrapWidth >= [encoded length])
        {
            [result appendString:[encoded substringFromIndex:i]];
            break;
        }
        [result appendString:[encoded substringWithRange:NSMakeRange(i, wrapWidth)]];
        [result appendString:@"\r\n"];
    }
    
    return result;
}


@end
