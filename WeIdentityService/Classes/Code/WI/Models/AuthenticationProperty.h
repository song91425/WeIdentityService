//
//  AuthenticationProperty.h
//  HKard
//
//  Created by Junqi on 2020/9/8.
//  Copyright © 2020 tank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuthenticationProperty : NSObject
//目前只需要支持SECP256K1,可以定义一个常量来标识
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *publicKey;
@property (nonatomic, assign)  BOOL revoked;

@end

NS_ASSUME_NONNULL_END
