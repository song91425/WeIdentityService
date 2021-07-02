//
//  WIStringPersistence.h
//  WeIdentityService
//
//  Created by tank on 2020/11/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 存储位置枚举, 对于 NSString 对象,可以选择存 DB 

@interface WIKVPersistence : NSObject
/// build 数据库实例
/// @param domain      db名称  wi-domain.sqlite
/// @param cipherKey  打开 db 传入的密码
+ (instancetype)persistenceWithDomain:(NSString *)domain
                            cipherKey:(NSString *)cipherKey;

/// 插入 NSString 数据接口
/// @param domain 关联数据库表名称
/// @param itemId  主键
/// @param data       NSString 数据
-(int)add:(NSString *)domain itemId:(NSString *)itemId data:(NSString *)data;

/// 批量插入 NSString 数据接口
/// @param domain 关联数据库表名称
/// @param datas {itemId: object} 的集合
-(int)batchAdd:(NSString *)domain datas:(NSArray <NSDictionary<NSString *,NSString *> *>*)datas;


/// 根据给定条件查询
/// @param domain 关联数据库表名称
/// @param itemId 主键
/// @result 返回查询成功结果
- (NSString *)get:(NSString *)domain itemId:(NSString *)itemId;


/// 更新数据
/// @param domain 关联数据库表名称
/// @param itemId 主键
/// @param data 新值
-(int)update:(NSString *)domain itemId:(NSString *)itemId data:(NSString *)data;

- (int)deleteObject:(NSString *)domain itemId:(NSString *)itemId;

- (int)deleteAll;
@end

NS_ASSUME_NONNULL_END
