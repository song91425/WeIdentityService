//
//  SortDictionaryByKeys.h
//  AFNetworking
//
//  Created by lssong on 2020/10/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WISortDictionaryByKeys : NSObject
/// 按照字典的key排序，返回json的数据格式
/// @param dict 要转换成
/// @param asc @"YES" 代表升序，@"NO" 降序\

+(NSString*)jsonStringWithDict:(NSDictionary*)dict ascend:(NSString *)asc;

/// 按照字典的key排序，返回json的数据格式, 是对jsonStringWithDict的封装
/// @param dict 需要转换成json的字典
+(NSString *)__jsonFromDic:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
