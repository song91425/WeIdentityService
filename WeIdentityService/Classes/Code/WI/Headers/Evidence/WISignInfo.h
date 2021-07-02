//
//  WISignInfo.h
//  WeIdentityService
//
//  Created by tank on 2020/9/22.
//

#import "WIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WISignInfo : WIBaseModel

@property (nonatomic, copy)NSArray *logs;
@property (nonatomic, copy)NSString *signature;
@property (nonatomic, assign) int timestamp;

@end

NS_ASSUME_NONNULL_END
//   signInfo =         {
//            "did:weid:298:0x275b07e90831c96807acaebdf384635ff9fcb0ae" = {
//                logs = (
//                    log
//                );
//                signature = bf757beb7750b2bc172f008f594b8d6c0340e0c41dcf68983b2208a49a26b0a307e68daf8e4f67897576d90303c3141b3242649469583216180c7508f180f04201;
//                timestamp = 1600774298;
