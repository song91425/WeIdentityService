//
//  WIBAC005AssetService.m
//  WeIdentityService
//
//  Created by lssong on 2021/2/23.
//

#import "WIBAC005AssetService.h"
#import "WINetworkManager.h"
#import "YYModel.h"
#import "WIWeIdentityService.h"
#import "WIQueryOwnedAssetModel.h"
#import "WISDKLog.h"
@implementation WIBAC005AssetService

- (void)queryOwnedAssetList:(NSString *)assetAddress
                assetHolder:(NSString *)assetHolder
                      index:(int)index
                        num:(int)num
                   callback:(void (^)(NSInteger, NSArray<WIQueryOwnedAssetModel *> * , NSError * ))callback{
    NSDictionary *params = @{@"assetAddress":assetAddress,
                             @"assetHolder":assetHolder?:[NSNull null],
                             @"index":@(index?:0),
                             @"num":@(num?:0),
    };
    void(^netCallback)(id) = ^(id response){
        int code = [response[@"errorCode"] intValue];
        if (!code) {
            NSArray<WIQueryOwnedAssetModel *>  *queryModels = [NSArray yy_modelArrayWithClass:[WIQueryOwnedAssetModel class] json:response[@"respBody"]];
            callback(code,queryModels,nil);
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.queryOwnedAssetList" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(code,nil,error);
        }
    };
    
    if ([[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
        [[WINetworkManager manager] requestWithFuncName:WIFunctionName_QueryOwnedAssetList
                                                    url:[[WIConfig SDKConfig] bac005URL]
                                                  param:params
                                                success:^(id _Nullable response) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"response:%@",response);
            netCallback(response);
        }
                                                failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            callback(error.code,nil,error);
        }];
    }else{
        WIWeIdentityService *service = [WIWeIdentityService sharedService];
        
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSMutableDictionary *funcParam = [[[WINetworkManager manager] functionParam:params functionName:WIFunctionName_QueryOwnedAssetList] mutableCopy];
        [funcParam setObject:@"BAC005Query" forKey: @"functionNameAlias"];
        
        if (res) {
            [service.requestDelegate requestWithFunctionName:WIFunctionName_QueryOwnedAssetList
                                                    param:funcParam
                                                  success:^(id _Nullable response) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",response);
                netCallback(response);
            }failure:^( NSError * _Nonnull error) {
                callback(error.code,nil,error);
            }];
        }else{ // 没有实现代理
            NSError *error = [NSError errorWithDomain:@"payment.queryOwnedAssetList" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!"}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(-1,nil,error);
        }
    }
}

- (void)send:(NSString *)assetAddress
sendAssetArgs:(WIBAC005SendArgsModel *)sendAssetArgs
    callback:(void (^)(BOOL, NSError * ))result
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (sendAssetArgs.data == nil) {
        [param setDictionary:@{@"assetAddress":assetAddress,
                                      @"recipient":sendAssetArgs.recipient,
                                      @"assetId":@(sendAssetArgs.assetId)?:[NSNull null]
              }];
    }else{
        [param setDictionary:@{@"assetAddress":assetAddress,
                                      @"recipient":sendAssetArgs.recipient?:[NSNull null],
                                      @"assetId":@(sendAssetArgs.assetId)?:[NSNull null],
                                      @"data":sendAssetArgs.data?:[NSNull null]
              }];
    }
    
    void(^netCallback)(id) = ^(id response){
        int code = [response[@"errorCode"] intValue];
        if(code==0){
            result(code == 0, nil); // 当返回码code=0和请求体返回true，才表示发送成功
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.send" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO,error);
        }
    };
    
    if ( [[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
       [[WINetworkManager manager] requestWithFuncName:WIFunctionName_Send
                                                   url: [[WIConfig SDKConfig] bac005URL]
                                                 param:param
                                                success:^(id _Nullable response) {
           if(WISDKLog.sharedInstance.printLog)
               NSLog(@"%@",response);
           netCallback(response);
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO, error);
        }];
    }else{
        WIWeIdentityService *service = [WIWeIdentityService sharedService];
        
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSDictionary *funcParam = [[WINetworkManager manager] functionParam:param functionName:WIFunctionName_Send];
        
        if (res) {
            [service.requestDelegate requestWithFunctionName:WIFunctionName_Send
                                                    param:funcParam
                                                  success:^(id _Nullable response) {

                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",response);
                netCallback(response);
            }failure:^( NSError * _Nonnull error) {
                result(NO,error);
            }];
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.queryOwnedAssetList" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!"}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO,error);
        }
    }
}

- (void)batchSend:(NSString *)assetAddress
      invokerWeid:(NSString *)invokerWeId
    sendAssetArgs:(NSArray<WIBAC005SendArgsModel *> *)sendAssetArgList
         callback:(void (^)(BOOL, NSError * ))callback{
    NSMutableArray *sendAssetArgs = [NSMutableArray array];
    for (WIBAC005SendArgsModel *model in sendAssetArgList) {
        [sendAssetArgs addObject:[model dictionaryValue]];
    }
    
    NSDictionary *param = @{@"assetAddress":assetAddress ?:[NSNull null],
                            @"list":sendAssetArgs ?:[NSNull null],
                            @"invokerWeId":invokerWeId ?:[NSNull null],
    };
    void(^netCallback)(id) = ^(id response){
        int code = [response[@"errorCode"] intValue];
        if(code==0){
            callback(code == 0, nil); // 当返回码code=0和请求体返回true，才表示发送成功
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.send" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(NO,error);
        }
    };
    
    if ( [[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
       [[WINetworkManager manager] requestWithFuncName:WIFunctionName_BatchSend
                                                   url: [[WIConfig SDKConfig] bac005URL]
                                                 param:param
                                                success:^(id _Nullable response) {
           if(WISDKLog.sharedInstance.printLog)
               NSLog(@"%@",response);
           netCallback(response);
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(NO, error);
        }];
    }else{
        WIWeIdentityService *service = [WIWeIdentityService sharedService];
        
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSMutableDictionary *funcParam = [[[WINetworkManager manager] functionParam:param functionName:WIFunctionName_BatchSend] mutableCopy];
        [funcParam setObject:@"BAC005BatchSend" forKey: @"functionNameAlias"];
        if (res) {
            [service.requestDelegate requestWithFunctionName:WIFunctionName_BatchSend
                                                    param:funcParam
                                                  success:^(id _Nullable response) {

                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",response);
                netCallback(response);
            }failure:^( NSError * _Nonnull error) {
                callback(NO,error);
            }];
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.queryOwnedAssetList" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!"}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(NO,error);
        }
    }
    
}

@end
