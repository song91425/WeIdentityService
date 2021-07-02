//
//  WINetworkProtocal.h
//  WeIdentityService-WeIdentityService
//
//  Created by tank on 2020/9/21.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol WINetworkProtocal <NSObject>

@required
/// APP 代发网络请求, 请求类型 POST,Content-Type application/json
/// @param wiArgs                       请求参数
/// @param success                     成功回调
/// @param failure                      失败回调

- (void)requestWithFunctionName:(NSString *)name
                          param:(NSDictionary *)wiArgs
                        success:(void (^)( id _Nullable response))success
                        failure:(void (^)(NSError * _Nonnull error))failure;

@end

NS_ASSUME_NONNULL_END
