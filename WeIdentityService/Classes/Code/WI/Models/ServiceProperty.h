//
//  ServiceProperty.h
//  HKard
//
//  Created by Junqi on 2020/9/8.
//  Copyright © 2020 tank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceProperty : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *serviceEndpoint;

@end

NS_ASSUME_NONNULL_END
