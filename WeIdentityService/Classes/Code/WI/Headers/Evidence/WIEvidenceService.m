//
//  WIEvidenceService.m
//  HKard
//
//  Created by tank on 2020/9/1.
//  Copyright © 2020 tank. All rights reserved.
//

#import "WIEvidenceService.h"
#import "WINetworkManager.h"
#import "WICredential.h"
#import "BatchCreateEvidenceArg.h"
#import "WIConfig.h"
#import "YYModel.h"
#import "WIWeIdentityService.h"
#import "WISDKLog.h"
@implementation WIHashInfo

- (NSDictionary *)toMap{
    if (self.hash_ == nil || self.sign == nil) {
        return nil;
    }
    if (self.log) {
        return @{
            @"hash":self.hash_,
            @"sign":self.sign,
            @"log":self.log
        };
    }else{
        return @{
            @"hash":self.hash_,
            @"sign":self.sign,
        };
    }
}

@end

@implementation WIEvidenceService

-(void)createEvidenceWithGroupId:(int)groupId hashInfo:(WIHashInfo *)hashInfo callback:(void (^)(int, BOOL, NSError * _Nonnull))callback
{
    NSDictionary *param = [hashInfo toMap];
    if (param == nil) {
        NSError *error = [NSError errorWithDomain:@"evidence.createEvidenceWithHash" code:-1 userInfo:@{
            NSLocalizedDescriptionKey:@"传入的参数不合法: hash 或者 sign 为空"
        }];
        callback(-1,NO,error);
        return;
    }
    
    // 处理网络请求回调.
    void (^responseBlock) (id) = ^(id response){
        int code = [response[@"errorCode"] intValue];
        if (code == 0) {
            callback(code, code== 0,nil);
        }else{
            NSString *errorMessage =response[@"errorMessage"];
            NSError *error = [NSError errorWithDomain:@"evidence.createEvidenceWithHash" code:code userInfo:@{
                NSLocalizedDescriptionKey:errorMessage
            }];
            callback(code, NO, error);
        }
    };
    
    // 将 group id 传进去
    [[WINetworkManager manager] setGroupId:groupId];
    // 发送网络请求
    if ( [[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
        [[WINetworkManager manager] requestWithFuncName:WIFunctionName_DelegateCreateEvidence
                                                    url: [[WIConfig SDKConfig] weIdURL]
                                                  param:param
                                                success:^(id _Nullable response) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",response);
            responseBlock(response);
        
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(-1, NO, error);
        }];
    }else{
        WIWeIdentityService *service = [WIWeIdentityService sharedService];
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSDictionary *funcParam = [[WINetworkManager manager] functionParam:param functionName:WIFunctionName_DelegateCreateEvidence];
        
        if (service.requestDelegate && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)]) {
            [service.requestDelegate requestWithFunctionName:WIFunctionName_DelegateCreateEvidence
                                                    param:funcParam
                                                  success:^(id _Nullable response) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",response);
                responseBlock(response);
            }failure:^( NSError * _Nonnull error) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",error);
                callback(-1, NO, error);
            }];
        }
    }
}


- (void)createEvidenceBatchWithGroupId:(int)groupId
                                  list:(NSArray<WIHashInfo *> *)arr
                              callback:(void (^)(int, BOOL, NSError * _Nonnull))callback
{
    
    NSAssert(arr != nil, @"参数不合法!");
    NSMutableArray *credentialArray = [NSMutableArray array];
    for (WIHashInfo *info in arr) {
        NSDictionary *dic = [info toMap];
        if (dic != nil) {
            [credentialArray addObject:dic];
        }
    }
    // 处理网络请求回调.
    void (^responseBlock) (id) = ^(id response){
        int code = [response[@"errorCode"] intValue];
        if (code == 0) {
            callback(code , code== 0,nil);
        }else{
            NSString *errorMessage =response[@"errorMessage"];
            NSError *error = [NSError errorWithDomain:@"evidence.createEvidenceBatchWithArr" code:code userInfo:@{
                NSLocalizedDescriptionKey:errorMessage
            }];
            callback(code, NO, error);
        }
    };
    [[WINetworkManager manager] setGroupId:groupId];
    NSDictionary *param = @{@"list":[NSArray arrayWithArray:credentialArray]};
    if ( [[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
        [[WINetworkManager manager] requestWithFuncName:WIFunctionName_DelegateCreateEvidenceBatch
                                                    url: [[WIConfig SDKConfig] weIdURL]
                                                  param:param
                                                success:^(id _Nullable response) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",response);
            responseBlock(response);
           
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(-1, NO, error);
        }];
    }else{
        WIWeIdentityService *service = [WIWeIdentityService sharedService];
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSDictionary *funcParam = [[WINetworkManager manager] functionParam:param functionName:WIFunctionName_DelegateCreateEvidenceBatch];
        
        if (service.requestDelegate && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)]) {
            [service.requestDelegate requestWithFunctionName:WIFunctionName_DelegateCreateEvidenceBatch
                                                    param:funcParam
                                                  success:^(id _Nullable response) {
                
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",response);
                responseBlock(response);
            }failure:^( NSError * _Nonnull error) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",error);
                callback(-1, NO, error);
            }];
        }
    }
}


- (void)getEvidenceWithGroupId:(int)groupId
                     hashValue:(NSString *)hashValue
                      callback:(void (^)(BOOL, WIEvidence * _Nonnull, NSError * _Nonnull))callback
{
    NSDictionary *param = @{@"hashValue":hashValue};
    // 处理网络请求回调.
    void (^responseBlock) (id) = ^(id response){
        int code = [response[@"errorCode"] intValue];
        NSDictionary *respBody = response[@"respBody"];
        if (code == 0 && respBody) {
            WIEvidence *evidence = [WIEvidence yy_modelWithDictionary:respBody];
            if (evidence != nil) {
                callback(YES, evidence, nil);
            }else{
                callback(NO, nil, nil);
            }
        }else{
           NSString *errorMessage =response[@"errorMessage"];
            NSError *error = [NSError errorWithDomain:@"evidence.createEvidenceWithHash" code:code userInfo:@{
                NSLocalizedDescriptionKey:errorMessage
            }];
            callback(NO, nil, error);
        }
    };
    
    [[WINetworkManager manager] setGroupId:groupId];
    if ( [[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
        [[WINetworkManager manager] requestWithFuncName:WIFunctionName_GetEvidence
                                                    url: [[WIConfig SDKConfig] weIdURL]
                                                  param:param
                                                success:^(id _Nullable response) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",response);
            responseBlock(response);
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(NO, nil, error);
        }];
    }else{
        WIWeIdentityService *service = [WIWeIdentityService sharedService];
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSDictionary *funcParam = [[WINetworkManager manager] functionParam:param functionName:WIFunctionName_GetEvidence];
        
        if (service.requestDelegate && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)]) {
            [service.requestDelegate requestWithFunctionName:WIFunctionName_GetEvidence
                                                    param:funcParam
                                                  success:^(id _Nullable response) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",response);
                responseBlock(response);
            }failure:^( NSError * _Nonnull error) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",error);
                callback(NO, nil, error);
            }];
        }
    }
}


@end
