//
//  WIRestorationService.h
//  WeIdentityService
//
//  Created by tank on 2021/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIRestorationService : NSObject

+ (instancetype)sharedService;

/// 通过助记词恢复钱包和weid列表
/// @param mnemonics 助记词
/// @param unlockPwd 解锁密码
/// @param callback 回调
///
/// @detail
/// 1. 通过[com.openchopstick.restoration.WIHDWalletService]恢复钱包
/// 2. 通过后台接口恢复weid列表和currentIndex

- (void)initHDWalletWithMnemonics:(NSString *)mnemonics unlockPwd:(NSString *)unlockPwd callback:(void(^)(BOOL,NSError *error))callback;


/// 获取weid列表
/// @param callback callback
- (void)getWeIdList:(void(^)(NSArray* list))callback;
@end

NS_ASSUME_NONNULL_END
