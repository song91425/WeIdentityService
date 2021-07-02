//
//  WIJsonfromArrDict.h
//  WeIdentityService_Example
//
//  Created by lssong on 2020/10/27.
//  Copyright © 2020 shoutanxie@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIJsonfromArrDict : NSObject


/// 将字典或者数组的模型转为json串
/// @param model 模型
+ (NSString *) jsonStringFromArrDic:(id) model;
@end

NS_ASSUME_NONNULL_END
