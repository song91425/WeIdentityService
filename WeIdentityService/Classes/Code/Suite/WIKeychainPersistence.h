//
//  WIKeychainPersistence.h
//  Pods
//
//  Created by lssong on 2020/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIKeychainPersistence : NSObject

//+(instancetype)keyChainManager;
+ (instancetype)keyChainPersistenceWithDomain:(NSString *)domain;

-(BOOL)deleteKeyChainPersistenceWithDomain:(NSString *)domain;

/// 插入 数据到KeyChain的 接口
/// @param itemId  主键
/// @param data   NSString 数据
/// @return 1 成功   0 失败
-(int)add:(NSString *) itemId data:(NSString *)data;

/// 批量插入 数据到KeyChain的 接口
/// @param datas  要查如的数据字典{ itemId:data }, 即把item作为key，data作为value
/// @return 1 成功   0 失败
-(int) batchAdd:(NSDictionary<NSString *,NSString *> *)datas;

/// 查找数据到KeyChain的 接口
/// @param itemId  主键
/// @return 查找结果
-(NSString *)get:(NSString *)itemId;


/// 根据domain查询，查询domain下的所有itemId
/// @param domain domain
/// @return 返回key和value。 key是itemId， value是保存的数据，比如私钥
-(NSDictionary *)getByDomain:(NSString *) domain;

/// 删除数据到KeyChain的 接口
/// @param itemId  主键
/// @return Yes 成功   NO 失败
-(int) deleteItem:(NSString *)itemId;


/// 跟新数据到KeyChain的 接口
/// @param itemId  主键
/// /// @param data   NSString 数据
/// @return YES 成功   NO 失败
-(int) update:(NSString *)itemId data:(NSString *) data;

- (void)clearKeyChain;

@end

NS_ASSUME_NONNULL_END
