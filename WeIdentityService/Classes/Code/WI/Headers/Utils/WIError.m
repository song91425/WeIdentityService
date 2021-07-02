//
//  WIError.m
//  WeIdentityService
//
//  Created by lssong on 2021/1/27.
//

#import "WIError.h"

@implementation WIError
 const NSInteger ERR_DEFAULT = -1 ;//默认错误
 const NSInteger ERR_INTERNAL = -2; //内部错误，比如hash失败等，非业务流程或者数据错误,一般不会发生
 const NSInteger ERR_NOT_INIT = -3 ;//还未初始化
 const NSInteger ERR_NO_WALLET = -4;
 const NSInteger LOCAL_ERR_CREATE_KEYPAIR = 111;
 const NSInteger ERR_GET_PUBLIC_KEY_BY_KEY_ID = 211;
 const NSInteger ERR_UNLOCK_PWD = -311 ;//密码错误
 const NSInteger ERR_RESTORE_PWD = -312; //密码错误
 const NSInteger ERR_TRANS_PWD = -313 ;//密码错误
 const NSInteger ERR_FILE_EXIST = -411 ;//文件已存在
 const NSInteger ERR_FILE_NOT_EXIST = -412 ;//文件不存在
 const NSInteger ERR_NOT_FOUND = -414; //不存在
const NSInteger ERR_CREATE_MASTERKEY = -415; //创建maserkey为nil


 NSString * const  NETWORK_ERR_MSG_DEFAULT = @"网络未连接";
 NSString * const  MSG_UNKNOWN = @"unknown";

+ (NSError *)normalError:(NSString *)msg errcode:(NSInteger)code{
    return  [NSError errorWithDomain:@"WeHDWallet" code:code userInfo:@{
        NSLocalizedDescriptionKey:msg}];
}

+ (NSError *)internalError:(NSString *)msg {
    return  [NSError errorWithDomain:@"WeHDWallet" code:ERR_INTERNAL userInfo:@{
        NSLocalizedDescriptionKey:msg}];
}

@end
