//
//  ResponseData.h
//  HKard
//
//  Created by Junqi on 2020/9/7.
//  Copyright © 2020 tank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResponseData<id> : NSObject

@property (nonatomic, copy) id result;

@property (nonatomic, assign)  NSInteger errorCode;

@property (nonatomic, copy) NSString *errorMessage;

@end

NS_ASSUME_NONNULL_END
