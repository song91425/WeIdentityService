//
//  WIError.h
//  WeIdentityService
//
//  Created by lssong on 2021/1/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIError : NSObject
extern const NSInteger ERR_DEFAULT;//默认错误
extern const NSInteger ERR_INTERNAL ; //内部错误，比如hash失败等，非业务流程或者数据错误,一般不会发生
extern const NSInteger ERR_NOT_INIT ; //还未初始化
extern const NSInteger ERR_NO_WALLET ;
extern const NSInteger LOCAL_ERR_CREATE_KEYPAIR ;
extern const NSInteger ERR_GET_PUBLIC_KEY_BY_KEY_ID ;
extern const NSInteger ERR_UNLOCK_PWD ;//密码错误
extern const NSInteger ERR_RESTORE_PWD ; //密码错误
extern const NSInteger ERR_TRANS_PWD ; //密码错误
extern const NSInteger ERR_FILE_EXIST ; //文件已存在
extern const NSInteger ERR_FILE_NOT_EXIST ; //文件不存在
extern const NSInteger ERR_NOT_FOUND ; //不存在
extern const NSInteger ERR_CREATE_MASTERKEY; //创建maserkey为nil

extern NSString * const  NETWORK_ERR_MSG_DEFAULT ;
extern NSString * const  MSG_UNKNOWN ;

+(NSError *)normalError:(NSString  *) msg errcode:(NSInteger) code;

+(NSError *)internalError:(NSString *) msg;
@end

NS_ASSUME_NONNULL_END
