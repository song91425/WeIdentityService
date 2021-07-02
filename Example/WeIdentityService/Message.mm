//
//  Message.m
//  WeIdentityService_Example
//
//  Created by tank on 2020/11/9.
//  Copyright © 2020 shoutanxie@gmail.com. All rights reserved.
//

#import "Message.h"
#import <WCDB/WCDB.h>
@implementation Message

WCDB_IMPLEMENTATION(Message)
WCDB_SYNTHESIZE(Message, localID)  // 字段宏以WCDB_SYNTHESIZE开头，定义了类属性与字段之间的联系。支持自定义字段名和默认值。
WCDB_SYNTHESIZE(Message, content)
WCDB_SYNTHESIZE(Message, createTime)
WCDB_SYNTHESIZE(Message, modifiedTime)

WCDB_PRIMARY(Message, localID)// 主键约束以 WCDB_PRIMARY 开头，定义了数据库的主键，支持自定义主键的排序方式、是否自增, 是最基本的用法，它直接使用propertyName作为数据库主键。
//WCDB_PRIMARY(Message, createTime)// 主键约束以 WCDB_PRIMARY 开头，定义了数据库的主键，支持自定义主键的排序方式、是否自增, 是最基本的用法，它直接使用propertyName作为数据库主键。

WCDB_INDEX(Message, "_index", createTime) // 索引宏以WCDB_INDEX开头，定义了数据库的索引属性。支持定义索引的排序方式。



- (NSString *)description{
    return [NSString stringWithFormat:@"msg:%d %@ %d %@", self.localID,self.content,self.createTime,self.modifiedTime];
}
@end
