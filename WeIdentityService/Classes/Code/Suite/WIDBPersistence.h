//
//  WIDBPersistence.h
//  AFNetworking
//
//  Created by tank on 2020/11/6.
//

//TODO: 建议把domain删除,用 classname 作为表名称

#import <Foundation/Foundation.h>
#import <WCDB/WCDB.h>
#import <WCDB/WCTDeclare.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIDBPersistence : NSObject

/// build 数据库实例
/// @param domain      db名称  wi-domain.sqlite
/// @param domainPwd  打开 db 传入的密码
+ (instancetype)persistenceWithDomain:(NSString *)domain
                            domainPwd:(NSString *)domainPwd;

// 设置密码, 可选动作
//- (BOOL)setKey:(NSString *)key;
////TODO: 改密码
//- (BOOL)open:(NSString *)key;
//
//// kill 单例
//- (BOOL)close;

/// 插入OC对象数据接口
/// @param object       遵守 WCTTableCoding 协议的对象
-(int)add:(NSObject<WCTTableCoding>*)object;

/// 批量插入插入OC对象数据接口
/// @param objects {itemId: data} 的集合
-(int)batchAdd:(NSArray <NSObject<WCTTableCoding>*>*)objects;

/**
 查询支持的功能:
 1. 排序
 2. 分页查询
 3. 按字段筛选
 */
/// 查询接口,返回指定类型的所有数据
/// @param cls 数据类型
//- (NSArray /* <WCTObject*> */ *)getAllObjectsOfClass:(Class)cls;

/// 分页查询
/// @param cls 从那张表获得数据
/// @param condition 查找条件
/// @param orderList 排序方式
/// @param num          返回的数据量
/// @param index        起始偏移
- (NSArray /* <WCTObject*> */ *)get:(Class)cls
                             where:(const WCTCondition &)condition
                           orderBy:(const WCTOrderByList &)orderList
                               num:(const WCTLimit &)num
                             index:(const WCTOffset &)index;

- (NSArray /* <WCTObject*> */ *)getObjectsOfClass:(Class)cls where:(const WCTCondition &)condition;
/// 数据更新
/// @param cls 从那张表获得数据
/// @param property 更新属性值
/// @param object      更新的对象
/// @param condition  查找条件
- (int)update:(Class)cls
    onProperty:(const WCTProperty &)property
    withObject:(WCTObject *)object
         where:(const WCTCondition &)condition;

//-(void)forceAdd:(NSString *)domain itemId:(NSString *)itemId data:(NSString *)data;


- (NSArray /* <WCTObject*> */ *)getAllObjectsOfClass:(Class)cls;
/// 删除指定条件的数据
/// @param cls 类型
/// @param condition 删除条件
-(int)deleteObjectsOfClass:(Class)cls
                    where:(const WCTCondition &)condition
                      num:(const WCTLimit &)num
                     index:(const WCTOffset &)index;

- (BOOL)deleteObjectsOfClass:(Class)cls
                         where:(const WCTCondition &)condition;


/// 删除数据库
/// @param error error
- (BOOL)removeDBWithError:(WCTError **)error;

@end

NS_ASSUME_NONNULL_END
