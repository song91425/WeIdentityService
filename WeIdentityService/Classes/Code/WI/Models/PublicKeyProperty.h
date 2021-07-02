//
//  PublicKeyProperty.h
//  HKard
//
//  Created by Junqi on 2020/9/8.
//  Copyright © 2020 tank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PublicKeyProperty : NSObject

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *owner;
@property (nonatomic, copy) NSString *publicKey;
@property (nonatomic, assign)  BOOL revoked;

@end

NS_ASSUME_NONNULL_END
