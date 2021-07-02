//
//  WISDKLog.h
//  WeIdentityService
//
//  Created by tank on 2021/1/7.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface WISDKLog : NSObject

/// Yes 有日志输出，NO 没有日志输出，默认为NO
@property(nonatomic, assign) bool printLog;
+(instancetype) sharedInstance;
+ (void)log:(const char*)sel desc:(NSString *)desc argKeys:(NSArray *)keys argValues:(NSArray *)values;
+ (void)log:(const char*)sel desc:(NSString *)desc;

@end

NS_ASSUME_NONNULL_END
