//
//  WIHDWalletUtils.m
//  WeIdentityService
//
//  Created by tank on 2020/12/23.
//

#import "WIHDWalletUtils.h"
#import "WedprHdW.h"
#import "WihdwResult.pbobjc.h"
#import "WICryptoUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import "WISDKLog.h"

@implementation WIHDWalletUtils

/// 产生助记词
/// @param word_count 助记词长度,必须是 3 的倍数
+ (NSString *)wedpr_hdw_create_mnemonic:(unsigned char )word_count
{
    char* c_result = wedpr_hdk_create_mnemonic_en(word_count);
    HdwResult *hdwResult = [self __hdwResult:c_result];
    NSString *mnemonic = hdwResult.mnemonic;
    if (mnemonic == nil) {
        return nil;
    }
    return mnemonic;
}

/// 创建 master key,wedpr_create_master_key() 返回结果是 base64 字符串
/// @param passwd 密码
/// @param mnemonic 助记词
+ (NSString *)wedpr_create_master_key:(NSString *)passwd mnemonic:(NSString *)mnemonic
{
    char *c_passwd   = (char *)[passwd   cStringUsingEncoding:NSUTF8StringEncoding];
    char *c_mnemonic = (char *)[mnemonic cStringUsingEncoding:NSUTF8StringEncoding];
    
    char* c_result = wedpr_hdk_create_master_key_en(c_passwd, c_mnemonic);
    if(c_result == NULL){
        return nil;
    }
    HdwResult *hdwResult = [self __hdwResult:c_result];
    
    NSData *masterKeyData = [hdwResult masterKey];
    NSString *masterKey = [self __base64StringFromData:masterKeyData];
    return masterKey;
    //    NSString *padding_mk = nil;
    //    if (fmod(masterKey.length, 4) == 1) {
    //
    //        padding_mk =[NSString stringWithFormat:@"%@===",masterKey];
    //    }
    //    else if (fmod(masterKey.length, 4) == 2){
    //        padding_mk =[NSString stringWithFormat:@"%@==",masterKey];
    //    }
    //    else if (fmod(masterKey.length, 4) == 3){
    //        padding_mk =[NSString stringWithFormat:@"%@=",masterKey];
    //    }
    //
    //    // BASE64 ==> HEX , 和Android 对齐
    //    NSString *hexMasterKey = [WICryptoUtils hexStringFromB64String:padding_mk];
    ////    NSLog(@"%s | %@ | %@",__func__,masterKey,hexMasterKey);
    //    NSString *normal = [[WICryptoUtils b64StringFromHexString:hexMasterKey] stringByReplacingOccurrencesOfString:@"=" withString:@""];
    //    NSAssert([normal isEqual:masterKey], @"GGGGGGGGGGGGGG");
    //    return hexMasterKey;
}
//
//+ (NSString *)stringFromHexString:(NSString *)str {
//    // The hex codes should all be two characters.
//    NSMutableString * newString = [[NSMutableString alloc] init];
//    int i = 0;
//    while (i < [str length])
//    {
//        NSString * hexChar = [str substringWithRange: NSMakeRange(i, 2)];
//        NSLog(@">>>> %@",hexChar);
//        int value = 0;
//        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
//        [newString appendFormat:@"%c", (char)value];
//        i+=2;
//    }
//    return newString;
//}

/// 通过 master key 生成密钥对
/// @param master_key master key
/// @param purpose_type purpose_type
/// @param coin_type coin_type
/// @param account account
/// @param change change
/// @param address_index address_index
+ (WIKeyPairModel *)wedpr_extended_key:(NSString *)master_key
                          purpose_type:(int)purpose_type
                             coin_type:(int)coin_type
                               account:(int)account
                                change:(int)change
                         address_index:(int)address_index
{
    
    char *c_master_key = (char *)[master_key cStringUsingEncoding:NSUTF8StringEncoding];
    char* c_result = wedpr_hdk_derive_extended_key(c_master_key,
                                                   purpose_type,
                                                   coin_type,
                                                   account,
                                                   change,
                                                   address_index);
    HdwResult *hdwResult = [self __hdwResult:c_result];
    if (hdwResult.hasKeyPair) {
        NSData *privateKeyData = hdwResult.keyPair.extendedPrivateKey;
        NSString *privateKeyHex = [self __hexFrom:privateKeyData];
        
        NSData *publicKeyData = hdwResult.keyPair.extendedPublicKey;
        NSString *publicKeyHex = [self __hexFrom:publicKeyData];
        
        // BASE64 ==> HEX , 和Android 对齐
        //        NSString *privateKeyHex = [WICryptoUtils hexStringFromB64String:privateKey];
        //        NSString *publicKeyHex  = [WICryptoUtils hexStringFromB64String:publicKey];
        if (privateKeyHex != nil && publicKeyHex !=nil) {
            return [WIKeyPairModel keyPairWithPublicKey:publicKeyHex privateKey:privateKeyHex];
        }
    }
    
    return nil;
}

+ (NSString *)__hexFrom:(NSData *)myD{
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
    return hexStr;
}



/// 将 HDWallet 函数返回的结果,转化成 OC object
/// @param c_result 钱包 SDK 返回的 C 字符串
+ (HdwResult *)__hdwResult:(char *)c_result
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    //    NSData *data = [NSData dataWithBytes:c_result length:strlen(c_result)];
    //    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *base64String = [NSString stringWithUTF8String:c_result];// @(c_result);
    NSData * base64Data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSError *error = nil;
    HdwResult *hdwResult = [HdwResult parseFromData:base64Data error:&error];
    NSAssert((hdwResult != nil) && (error == nil), @"hdw sdk error.");
    return hdwResult;
}

+ (NSString *)__base64StringFromData:(NSData *) data
{
    if (data != nil) {
        // base64 编码的字符串
        NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSInteger len = [base64String length];
        NSInteger padding = fmod(len, 3);
        if (padding == 1) {
            base64String = [NSString stringWithFormat:@"%@==",base64String];
        }else if(padding == 2){
            base64String = [NSString stringWithFormat:@"%@=",base64String];
        }
        return base64String;
    }
    return nil;
}
@end
