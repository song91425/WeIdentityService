//
//  WIRestoration.h
//  WeIdentityService
//
//  Created by tank on 2021/1/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    OVERRIDE,
    MERGE
} WIRestoreMode;

@interface WIRestoration : NSObject


/// 文件格式导出persistence
/// @param domain  domain
/// @param restorePwd 恢复密码
/// @param destFilePath 文件路径
- (void)exportCredentialList:(NSString *)domain
                  restorePwd:(NSString *)restorePwd
                destFilePath:(NSString *)destFilePath
                    callback:(void(^)(BOOL success,NSArray *credentials,NSString *filePath,NSString *errMsg))callback;


/// 通过文件恢复所有的Credential
/// @param domain  domain
/// @param restorePwd 恢复密码
/// @param srcFilePath 文件路径
/// @param isForce 强制覆盖
/// @param callback 回调
-(void)restoreCredentialListByFile:(NSString *)domain
                        restorePwd:(nonnull NSString *)restorePwd
                       srcFilePath:(nonnull NSString *)srcFilePath
                restoreModeIsForce:(BOOL)isForce
                          callback:(void(^)(BOOL success,NSArray *credentials,NSString *filePath,NSString *errMsg))callback;


/// 导出钱包和数据(目前只有credential)
/// @param walletDestFilePath 钱包文件路径
/// @param dataDestFilePath      credential 数据文件路径
/// @param restorePwd                   恢复密码
/// @param domain                            domain
- (void) exportWalletAndData:(NSString *)walletDestFilePath
            dataDestFilePath:(NSString *)dataDestFilePath
                  restorePwd:(NSString *)restorePwd
                      domain:(NSString *)domain;
@end

NS_ASSUME_NONNULL_END
