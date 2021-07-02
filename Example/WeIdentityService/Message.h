//
//  Message.h
//  WeIdentityService_Example
//
//  Created by tank on 2020/11/9.
//  Copyright © 2020 shoutanxie@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSObject

@property int localID;
@property(retain) NSString *content;
@property int createTime;
@property(retain) NSDate *modifiedTime;
@property(assign) int unused; //You can only define the properties you need

@end

NS_ASSUME_NONNULL_END
