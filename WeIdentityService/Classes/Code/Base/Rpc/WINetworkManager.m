//
//  WINetworkManager.m
//  WeIdentityService-WeIdentityService
//
//  Created by tank on 2020/9/22.
//

#import "WINetworkManager.h"
#import "WIConfig.h"
#import <AFNetworking/AFNetworking.h>
#import "WISDKLog.h"
//#import "AFNetworkActivityLogger.h"

WIFunctionName const WIFunctionName_CreateWeIdWithPubKey = @"createWeIdWithPubKey2";    // 通过公钥创建 WeID 接口
WIFunctionName const WIFunctionName_GetWIDocument = @"getWeIdDocument";              // 获取公钥信息
WIFunctionName const WIFunctionName_GetWIDocumentByOrgId = @"getWIDocumentByOrgId";// 根据Authority Issuer机构名获取公钥等信息

WIFunctionName const WIFunctionName_DelegateCreateEvidence = @"delegateCreateEvidence";// 作用： 创建一个存证，其他机构可以使用这个存证用于验证。
WIFunctionName const WIFunctionName_DelegateCreateEvidenceBatch = @"delegateCreateEvidenceB";// 作用： 创建一个存证，其他机构可以使用这个存证用于验证。
WIFunctionName const WIFunctionName_GetEvidence = @"getEvidence";

# pragma Payment functionName
WIFunctionName const WIFunctionName_Construct = @"construct"; // 部署 BAC004 合约并构建
WIFunctionName const WIFunctionName_Issue = @"issue"; //发行特定数量的 BAC004 资产
WIFunctionName const WIFunctionName_ConstructAndIssue=@"constructAndIssue";// 部署 BAC004 合约，同时发行特定数量的 BAC004 资产
WIFunctionName const WIFunctionName_GetBalance = @"getBalance"; // 用户根据资产地址获取资产余额
WIFunctionName const WIFunctionName_GetBatchBalance= @"getBatchBalance"; // 用户根据资产集合获取资产余额
WIFunctionName const WIFunctionName_GetBalanceByWeId= @"getBalanceByWeId";// 用户分页获取其名下资产余额
WIFunctionName const WIFunctionName_Send= @"send";// 用户发送资产给其他用户
WIFunctionName const WIFunctionName_BatchSend= @"batchSend";// 用户将某个资产发送给不同用户
WIFunctionName const WIFunctionName_GetBaseInfo= @"getBaseInfo";// 用户根据资产地址查询基础信息
WIFunctionName const WIFunctionName_GetBaseInfoByWeId= @"getBaseInfoByWeId"; // 用户分页查询其名下资产集成信息

WIFunctionName const WIFunctionName_GetWeIdListByPubKeyList= @"getWeIdListByPubKeyList"; // 用户分页查询其名下资产集成信息

#pragma Bac005 function name
WIFunctionName const WIFunctionName_QueryOwnedAssetList=@"queryOwnedAssetList";

//NSString* const WI_FUNCTION_ARG    = @"functionArg";
//NSString* const WI_TRANSACTION_ARG = @"transactionArg";
//NSString* const WI_FUNCTION_NAME   = @"functionName";

static WINetworkManager *manager = nil;

@interface WINetworkManager()

@property (nonatomic, strong) AFHTTPSessionManager* afnManager;

@end

@implementation WINetworkManager


+ (instancetype) manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [WINetworkManager new];
        //        [[AFNetworkActivityLogger sharedLogger] setLogLevel:AFLoggerLevelDebug];
        //        [[AFNetworkActivityLogger sharedLogger] startLogging];
        
        manager.groupId = 2;
    });
    return manager;
}

- (AFHTTPSessionManager *)afnManager{
    if (_afnManager == nil) {
        _afnManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _afnManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _afnManager.responseSerializer = [AFJSONResponseSerializer serializer];
        [_afnManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return _afnManager;
}


- (void)requestWithFuncName:(WIFunctionName)functionName
                        url:(NSString *)url
                      param:(NSDictionary *)functionArgParam
                    success:(void (^)( id _Nullable))success
                    failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    
    NSDictionary *param = [self functionParam:functionArgParam functionName:functionName];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"param:%@",param);
    NSAssert(url != nil, @"SDK Request URL is nil.");
    
    [self.afnManager POST:url parameters:param headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task,error);
    }];
    
}

//group 1 是 放weid的,group 2是存evidence的,
-(NSDictionary *)functionParam:(NSDictionary *)dic functionName:(NSString *)name{
    NSString *version     = @"1.0.0";
    NSString *invokerWeId = @"admin";
    //TO
    NSMutableDictionary *arg = [NSMutableDictionary dictionaryWithDictionary:dic];
    if ([arg objectForKey:@"invokerWeId"]) {
        invokerWeId = dic[@"invokerWeId"];
        [arg removeObjectForKey:@"invokerWeId"];
    }
    
    if([WIFunctionName_GetBalance isEqualToString:name]||[WIFunctionName_GetBatchBalance isEqualToString:name]|| [WIFunctionName_GetBalanceByWeId isEqualToString:name]||
       [WIFunctionName_GetBaseInfo isEqualToString:name]||[WIFunctionName_GetBalanceByWeId isEqualToString:name] ||
       [WIFunctionName_GetWeIdListByPubKeyList isEqualToString:name]){
        NSDictionary *funcParam = @{
            @"functionArg":arg,
            @"functionName":name,
            @"transactionArg":@{},
            @"v":version
        };
        return funcParam;
    }else if ([WIFunctionName_GetEvidence isEqualToString:name]
              || [WIFunctionName_DelegateCreateEvidence isEqualToString:name]
              || [WIFunctionName_DelegateCreateEvidenceBatch isEqualToString:name] ) { //  原来这个不做比较 || WIFunctionName_DelegateCreateEvidenceBatch
        NSDictionary *funcParam = @{
            @"functionArg":arg,
            @"transactionArg":@{
                    @"groupId": @(self.groupId)
            },
            @"functionName":name,
            @"v":version
        };
        return funcParam;
    }else if([WIFunctionName_Send isEqualToString:name] ||[WIFunctionName_BatchSend isEqualToString:name] || [WIFunctionName_QueryOwnedAssetList isEqualToString:name]){
        int num = (arc4random() % 10000);
        NSDictionary *funcParam = @{
            @"functionArg":arg,
            @"transactionArg":@{
                    @"invokerWeId":invokerWeId
            },
            @"functionName":name,
            @"v":version
        };
        return funcParam;
    }else{
        NSDictionary *funcParam = @{
            @"functionArg":arg,
            @"transactionArg":@{
                    @"invokerWeId":invokerWeId
            },
            @"functionName":name,
            @"v":version
        };
        return funcParam;
    }
}

-(BOOL)containObj:(NSString *) key inArray:(NSArray *)array{
    for (int i=0; i<array.count; i++) {
        if ([array[i] isEqualToString:key]) {
            return  YES;
        }
    }
    return NO;
}
@end
