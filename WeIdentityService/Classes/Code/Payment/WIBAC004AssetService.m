//
//  WIBAC004AssetService.m
//  WeIdentityService
//
//  Created by tank on 2020/10/26.
//

#import "WINetworkManager.h"
#import "WIBAC004AssetService.h"
#import "YYModel.h"
#import "WIWeIdentityService.h"
#import "WISDKLog.h"
@implementation WIBAC004AssetService

/// 部署 BAC004 合约并构建
/// @param userWeId 传执行的weid，或者传"admin"
/// @param WIKeyPair 秘钥对
/// @param shortName 资产简称
/// @param description 资产描述
/// @param result 成功则返回合约地址
- (void)construct:(NSString *)userWeId keyId:(NSString *)keyId transPwd:(NSString *)transPwd shortName:(NSString *)shortName description:(NSString *)description callback:(void (^)(BOOL, NSString * _Nonnull, NSError * _Nonnull))result
{
    NSDictionary *param = @{@"shortName":shortName,
                           @"description":description,
                           @"invokerWeId":userWeId
    };
    
    [[WINetworkManager manager] requestWithFuncName:WIFunctionName_Construct
                                                url: [[WIConfig SDKConfig] bac004URL]
                                              param:param
                                            success:^(id _Nullable response) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",response);
        int code = [response[@"errorCode"] intValue];
        //
        NSDictionary * resBody = response[@"respBody"];
        
        if(code == 0){
            result(code == 0, resBody[@"assetAddress"],nil);
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.construct" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO,nil,error);
        }
        
    }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",error);
        result(NO, nil, error);
    }];
}

/// 发行特定数量的 BAC004 资产
/// @param userWeId 传执行的weid，或者传"admin"
/// @param WIKeyPair 秘钥对
/// @param assetAddress BAC004 智能合约的地址
/// @param recipient 将指定数量的资产发行到这个字段指定的WeID账户
/// @param amount 资产数量
/// @param data 资产数据
/// @param result 成功返回YES
- (void)issue:(NSString *)userWeId keyId:(NSString *)keyId transPwd:(NSString *)transPwd assetAddress:(NSString *)assetAddress recipient:(NSString *)recipient amount:(NSInteger)amount data:(NSString *)data callback:(void (^)(BOOL, NSError * _Nonnull))result
{
    
    NSDictionary *param = @{@"assetAddress":assetAddress,
                            @"recipient":recipient,
                            @"amount":@(amount),
                            @"data":data,
                            @"invokerWeId":userWeId
    };
    
    [[WINetworkManager manager] requestWithFuncName:WIFunctionName_Issue
                                                url: [[WIConfig SDKConfig] bac004URL]
                                              param:param
                                            success:^(id _Nullable response) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",response);
        //        response = @{
        //            @"respBody": @true,
        //            @"errorCode": @0,
        //            @"errorMessage":@"success"
        //        };
        int code = [response[@"errorCode"] intValue];
        if(code==0){
            result(code == 0, nil); // 当返回码code=0和请求体返回true，才表示发送成功
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.send" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO,error);
        }
    }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",error);
        result(NO, error);
    }];
}

/// 部署 BAC004 合约，同时发行特定数量的 BAC004 资产
/// @param userWeId 传执行的weid，或者传"admin"
/// @param WIKeyPair 秘钥对
/// @param shortName 资产简称
/// @param description 资产描述
/// @param recipient 将指定数量的资产发行到这个字段指定的WeID账户
/// @param amount 资产数量
/// @param data 资产数据
/// @param result 结果返回 YES 部署成功的合约地址
-(void)constructAndIssue:(NSString *)userWeId
                   keyId:(NSString*)keyId
                transPwd:(NSString *)transPwd
               shortName:(NSString *)shortName
             description:(NSString *)description
               recipient:(NSString *)recipient
                  amount:(NSInteger)amount
                    data:(NSString *)data
                callback:(void (^) (BOOL succeed,NSString *assetAddress, NSError *error))result{
    NSMutableDictionary *mutaDic = [NSMutableDictionary dictionaryWithDictionary:
                                    @{
                                        @"invokerWeId":@"admin",
                                        @"shortName":shortName,
                                        @"recipient":recipient,
                                        @"amount":@(amount),
                                    }];
    if (description != nil) {
        [mutaDic setObject:description forKey:@"description"];
    }
    
    if (data != nil) {
        [mutaDic setObject:data forKey:@"data"];
    }
    NSDictionary *param = [NSDictionary dictionaryWithDictionary:mutaDic];
    
    void(^netSucceedCallback)(id) = ^(id response){
        int code = [response[@"errorCode"] intValue];
        //
        NSDictionary * resBody = response[@"respBody"];
        if(code == 0){
            result(code == 0, resBody[@"assetAddress"],nil);
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.constructAndIssue" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO,nil,error);
        }
    };
    
    if ( [[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
        [[WINetworkManager manager] requestWithFuncName:WIFunctionName_ConstructAndIssue
                                                    url: [[WIConfig SDKConfig] bac004URL]
                                                  param:param
                                                success:^(id _Nullable response) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",response);
            netSucceedCallback(response);
            
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO, nil,error);
        }];
    }else{
        WIWeIdentityService *service = [WIWeIdentityService sharedService];
        
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSDictionary *funcParam = [[WINetworkManager manager] functionParam:param functionName:WIFunctionName_ConstructAndIssue];
        
        if (service.requestDelegate && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)]) {
            [service.requestDelegate requestWithFunctionName:WIFunctionName_ConstructAndIssue
                                                       param:funcParam
                                                     success:^(id _Nullable response) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",response);
                netSucceedCallback(response);
            }failure:^( NSError * _Nonnull error) {
                result(NO,nil,error);
            }];
        }
    }
    
}

/// 查询BAC004资产余额
/// @param assetAddress 资产地址
/// @param userWeId 用户地址
/// @param result 查找结果
- (void)getBalance:(NSString *)assetAddress
          userWeId:(NSString *)userWeId
          callback:(void (^) (BOOL succeed,WIAssetBalanceModel *model, NSError *error))result{
    
    NSDictionary *param = @{@"assetAddress":assetAddress,
                            @"assetHolder":userWeId};
    
    if ( [[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
        
        [[WINetworkManager manager] requestWithFuncName:WIFunctionName_GetBalance
                                                    url: [[WIConfig SDKConfig] bac004URL]
                                                  param:param
                                                success:^(id _Nullable response) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",response);
            //        response = @{
            //            @"respBody": @{
            //            },
            //            @"errorCode": @0,
            //            @"errorMessage": @"success"
            //        };
            int code = [response[@"errorCode"] intValue];
            //
            NSDictionary * respBody = response[@"respBody"];
            
            if(code == 0){
                WIAssetBalanceModel *assetBalanceModel = [WIAssetBalanceModel  yy_modelWithDictionary:respBody];
                result(code == 0, assetBalanceModel,nil);
            }else{
                NSError *error = [NSError errorWithDomain:@"payment.getBalance" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",error);
                result(NO,nil,error);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO, nil, error);
        }];
        
    }else{
        WIWeIdentityService *service = [WIWeIdentityService sharedService];
        
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSDictionary *funcParam = [[WINetworkManager manager] functionParam:param functionName:WIFunctionName_GetBalance];
        
        if (service.requestDelegate && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)]) {
            [service.requestDelegate requestWithFunctionName:WIFunctionName_GetBalance
                                                    param:funcParam
                                                  success:^(id _Nullable responseObject) {

                int code = [responseObject[@"errorCode"] intValue];
                //
                NSDictionary * respBody = responseObject[@"respBody"];
                
                if(code == 0){
                    WIAssetBalanceModel *assetBalanceModel = [WIAssetBalanceModel  yy_modelWithDictionary:respBody];
                    result(code == 0, assetBalanceModel,nil);
                }else{
                    NSError *error = [NSError errorWithDomain:@"payment.getBalance" code:code userInfo:@{NSLocalizedDescriptionKey:responseObject[@"errorMessage"]}];
                    if(WISDKLog.sharedInstance.printLog)
                        NSLog(@"%@",error);
                    result(NO,nil,error);
                }
            }failure:^( NSError * _Nonnull error) {
                result(NO,nil,error);
            }];
        }
    }
    

}

/// 批量查询用户的BAC004资产余额
/// @param assetAddressList 资产地址集合
/// @param userWeId 用户地址
/// @param result 查询结果
- (void)getBatchBalance:(NSArray<NSString *> *)assetAddressList
               userWeId:(NSString *)userWeId
               callback:(void (^) (BOOL succeed,NSArray<WIAssetBalanceModel *> *models, NSError *error))result{
    
    NSDictionary *param = @{@"assetAddressList":assetAddressList,
                            @"assetHolder":userWeId};
    
    [[WINetworkManager manager] requestWithFuncName:WIFunctionName_GetBatchBalance
                                                url: [[WIConfig SDKConfig] bac004URL]
                                              param:param
                                            success:^(id _Nullable response) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",response);
        //        response =@{
        //            @"respBody": @[
        //                @{
        //                    @"assetAddress": @"0xd18129b83c0e02283cbd5363232faf8781debfd1",
        //                    @"balance": @980,
        //                },
        //                @{
        //                    @"assetAddress": @"0x60e0db3db412fb62fa418f792e7f728d3b098629",
        //                    @"balance": @0,
        //                }
        //            ],
        //            @"errorCode": @0,
        //            @"errorMessage": @"success"
        //        };
        int code = [response[@"errorCode"] intValue];
        NSArray * respBody = response[@"respBody"];
        
        if(code == 0){
            NSArray<WIAssetBalanceModel *>  *assetBalanceModels = [NSArray yy_modelArrayWithClass:[WIAssetBalanceModel class] json:respBody];
            result(code == 0, assetBalanceModels,nil);
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.getBatchBalance" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO,nil,error);
        }
    }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",error);
        result(NO, nil, error);
    }];
}

/// 分页查询用户所有的BAC004资产余额
/// @param userWeId  用户地址
/// @param index  分页查询起始位置
/// @param pageSize 页面大小
/// @param result 查询结果
- (void)getBalanceByWeId:(NSString *)userWeId
                   index:(int)index
                pageSize:(int)pageSize
                callback:(void (^) (BOOL succeed,NSArray<WIAssetBalanceModel *> *models, NSError *error))result{
    NSDictionary *param = @{@"assetHolder":userWeId,
                            @"index":@(index),
                            @"num":@(pageSize)
    };
    
    [[WINetworkManager manager] requestWithFuncName:WIFunctionName_GetBalanceByWeId
                                                url: [[WIConfig SDKConfig] bac004URL]
                                              param:param
                                            success:^(id _Nullable response) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",response);
        //        response = @{
        //            @"respBody": @[
        //                @{
        //                    @"assetAddress": @"0xd18129b83c0e02283cbd5363232faf8781debfd1",
        //                    @"balance": @990,
        //                }
        //            ],
        //            @"errorCode": @0,
        //            @"errorMessage": @"success"
        //        };
        int code = [response[@"errorCode"] intValue];
        NSArray * respBody = response[@"respBody"];
        
        if(code == 0){
            NSArray<WIAssetBalanceModel *>  *assetBalanceModels = [NSArray yy_modelArrayWithClass:[WIAssetBalanceModel class] json:respBody];
            result(code == 0, assetBalanceModels,nil);
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.getBalanceByWeId" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO,nil,error);
        }
    }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",error);
        result(NO, nil, error);
    }];
}

/// 用户发送资产给其他用户
/// @param assetAddress 资产地址
/// @param userWeId 资产持有者的weid
/// @param wiKeyPair 资产持有者的密钥信息
/// @param invokerWeId 传执行的weid,直接传"admin"
/// @param sendAssetArgs 接收资产配置
/// @param result 发送结果
- (void)send:(NSString *)assetAddress
    userWeId:(NSString *)userWeId
       keyId:(NSString*)keyId
    transPwd:(NSString *)transPwd
 invokerWeId:(NSString *) invokerWeId
sendAssetArgs:(WISendAssetArgsModel *)sendAssetArgs
    callback:(void (^) (BOOL succeed, NSError *error))result
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (sendAssetArgs.remark == nil) {
        [param setDictionary:@{@"assetAddress":assetAddress,
                                      @"recipient":sendAssetArgs.recipient,
                                      @"amount":@(sendAssetArgs.amount),
                                      @"invokerWeId":invokerWeId
              }];
    }else{
        [param setDictionary:@{@"assetAddress":assetAddress,
                                      @"recipient":sendAssetArgs.recipient,
                                      @"amount":@(sendAssetArgs.amount),
                                      @"remark":sendAssetArgs.remark,
                                      @"invokerWeId":invokerWeId
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
                                                   url: [[WIConfig SDKConfig] bac004URL]
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
        
        if (service.requestDelegate && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)]) {
            [service.requestDelegate requestWithFunctionName:WIFunctionName_Send
                                                    param:funcParam
                                                  success:^(id _Nullable response) {

                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",response);
                netCallback(response);
            }failure:^( NSError * _Nonnull error) {
                result(NO,error);
            }];
        }
    }
    
}

/// 批量发送Bac004资产
/// @param assetAddress 资产地址
/// @param userWeId 资产持有者的weid
/// @param wiKeyPair 资产持有者的密钥信息
/// @param invokerWeId 传执行的weid,直接传"admin"
/// @param sendAssetArgList 接收资产配置集合
/// @param result 发送结果
-(void)batchSend:(NSString *)assetAddress userWeId:(NSString *)userWeId keyId:(NSString *)keyId transPwd:(NSString *)transPwd invokerWeId:(NSString *)invokerWeId sendAssetArgs:(NSArray<WISendAssetArgsModel *> *)sendAssetArgList callback:(void (^)(BOOL, NSArray<WISendAssetResponseModel *> * _Nonnull, NSError * _Nonnull))result
{
    
    NSMutableArray *sendAssetArgs = [NSMutableArray array];
    for (WISendAssetArgsModel *model in sendAssetArgList) {
        [sendAssetArgs addObject:[model dictionaryValue]];
    }
    
    NSDictionary *param = @{@"assetAddress":assetAddress,
                            @"list":sendAssetArgs,
                             @"invokerWeId":invokerWeId
    };
    
    [[WINetworkManager manager] requestWithFuncName:WIFunctionName_BatchSend
                                                url: [[WIConfig SDKConfig] bac004URL]
                                              param:param
                                            success:^(id _Nullable response) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",response);
//                response=@{
//                    @"respBody": @[
//                        @{
//                            @"recipient": @"0x16c8a21456d2d59061a1cefceb111fd76008a795",
//                            @"result": @true,
//                            @"errorCode": @"SUCCESS"
//                        }
//                    ],
//                    @"errorCode": @0,
//                    @"errorMessage": @"success"
//                };
        int code = [response[@"errorCode"] intValue];
        NSArray * respBody = response[@"respBody"];
        
        if(code == 0){
            NSArray<WISendAssetResponseModel *>  *sendAssetResponseModel = [NSArray yy_modelArrayWithClass:[WISendAssetResponseModel class] json:respBody];
            result(code == 0, sendAssetResponseModel,nil);
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.batchSend" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO,nil,error);
        }
        
    }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",error);
        result(NO, nil, error);
    }];
}

/// 用户根据资产地址查询基础信息
/// @param assetAddressList 资产地址集合
/// @param result  查询结果
- (void)getBaseInfo:(NSArray <NSString *>*)assetAddressList
           callback:(void (^) (BOOL succeed,NSArray<WIBAC004AssetModel *> *models, NSError *error))result{
    
    NSAssert(assetAddressList.count !=0, @"参数不能为空!");
    NSDictionary *param = @{@"assetAddressList":assetAddressList};
    
    [[WINetworkManager manager] requestWithFuncName:WIFunctionName_GetBaseInfo
                                                url: [[WIConfig SDKConfig] bac004URL]
                                              param:param
                                            success:^(id _Nullable response) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",response);
        //        response=@{
        //            @"respBody": @[
        //                @{
        //                    @"assetAddress": @"0xd18129b83c0e02283cbd5363232faf8781debfd1",
        //                    @"shortName": @"RMB",
        //                    @"description": @"人民币",
        //                    @"totalSupply": @1000
        //                },
        //                @{
        //                    @"assetAddress": @"0x60e0db3db412fb62fa418f792e7f728d3b098629",
        //                    @"shortName": @"RMB",
        //                    @"description": @"人民币",
        //                    @"totalSupply": @2000
        //                }
        //            ],
        //            @"errorCode": @0,
        //            @"errorMessage": @"success"
        //        };
        int code = [response[@"errorCode"] intValue];
        NSArray * respBody = response[@"respBody"];
        
        if(code == 0){
            NSArray<WIBAC004AssetModel *>  *bAC004AssetModel = [NSArray yy_modelArrayWithClass:[WIBAC004AssetModel class] json:respBody];
            result(code == 0, bAC004AssetModel,nil);
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.getBaseInfo" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO,nil,error);
        }
    }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",error);
        result(NO, nil, error);
    }];
}


/// 用户分页查询其名下资产集成信息
/// @param userWeId 用户weId
/// @param index  分页查询起始位置
/// @param pageSize 页面大小
/// @param result  查询结果
- (void)getBaseInfoByWeId:(NSString *)userWeId
                    index:(int)index
                 pageSize:(int)pageSize
                 callback:(void (^) (BOOL succeed,NSArray<WIBAC004AssetModel *> *models, NSError *error))result{
    
    NSDictionary *param = @{@"assetHolder":userWeId,
                            @"index":@(index),
                            @"num":@(pageSize)
    };
    
    [[WINetworkManager manager] requestWithFuncName:WIFunctionName_GetBaseInfoByWeId
                                                url: [[WIConfig SDKConfig] bac004URL]
                                              param:param
                                            success:^(id _Nullable response) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",response);
        //        response=@{
        //            @"respBody": @[
        //                @{
        //                    @"assetAddress": @"0xd18129b83c0e02283cbd5363232faf8781debfd1",
        //                    @"shortName": @"RMB",
        //                    @"description": @"sdgsdg",
        //                    @"totalSupply": @1000
        //                }
        //            ],
        //            @"errorCode":@0,
        //            @"errorMessage": @"success"
        //        };
        int code = [response[@"errorCode"] intValue];
        NSArray * respBody = response[@"respBody"];
        
        if(code == 0 && respBody!= nil && respBody.count){
            // 解析
            NSArray<WIBAC004AssetModel *>  *bAC004AssetModel = [NSArray yy_modelArrayWithClass:[WIBAC004AssetModel class] json:respBody];
            result(code == 0, bAC004AssetModel,nil);
        }else{
            NSError *error = [NSError errorWithDomain:@"payment.getBaseInfoByWeId" code:code userInfo:@{NSLocalizedDescriptionKey:response[@"errorMessage"]}];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            result(NO,nil,error);
        }
        
    }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",error);
        result(NO, nil, error);
    }];
}

@end

