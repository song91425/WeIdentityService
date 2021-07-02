//
//  WIWeIdentityService.m
//  WeIdentityService
//
//  Created by tank on 2020/9/14.
//

#import "WIWeIdentityService.h"
#import "YYModel.h"
#import "WICryptoUtils.h"
#import "WINetworkManager.h"
#import "WIHDWallet.h"
#import "WIManager.h"
#import "YYModel.h"
#import "WIHDWalletInternalService.h"
#import "WISDKLog.h"
#import <WeIdentityService/WISDKLog.h>
@implementation WeIdInfo

+ (instancetype)infoWithWeId:(NSString *)weId keyId:(NSString *)keyId keyPair:(WIKeyPairModel *)keyPair document:(WIDocument *)document{
    WeIdInfo *info = [WeIdInfo new];
    info.weId = weId;
    info.keyId = keyId;
    info.keyPair = keyPair;
    info.wiDocument = document;
    return info;
}

- (NSString *)toJson{
    return  [self yy_modelToJSONString];
}

@end

static WIWeIdentityService *service = nil;

@interface WIWeIdentityService()
@property (nonatomic,assign) BOOL isNullWithFirstRequest;
@end

@implementation WIWeIdentityService

+ (instancetype) sharedService{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [WIWeIdentityService new];
    });
    
    return service;
}

- (void)createWeIdWithTransPwd:(NSString *)transPwd callback:(void (^)(BOOL, WeIdInfo * , NSError *))callback{
    
    [[WIHDWalletInternalService sharedService] createKeyPair:^(WIHDWalletKeyPair * _Nonnull keyPair, NSError * error) {
        if (error != nil) {
            callback(NO,nil,error);
            return;
        }else{
            if (keyPair != nil) {
                if (transPwd) {
                    [WISDKLog log:__func__ desc:@"通过交易密码创建 weid" argKeys:@[@"transPwd",@"keyPair"] argValues:@[transPwd,keyPair]];
                }else{
                    [WISDKLog log:__func__ desc:@"通过交易密码创建 weid" argKeys:@[@"transPwd",@"keyPair"] argValues:@[@"nil",keyPair]];
                }

                [self __createWeId:transPwd keyPair:keyPair callback:callback];
            }else{
                callback(NO,nil,nil);
            }
        }
    }];
//    [[WIHDWalletInternalService sharedService] createKeyPair:^(WIHDWalletKeyPair * _Nonnull keyPair) {
//        if (keyPair != nil) {
//            if (transPwd) {
//                [WISDKLog log:__func__ desc:@"通过交易密码创建 weid" argKeys:@[@"transPwd",@"keyPair"] argValues:@[transPwd,keyPair]];
//            }else{
//                [WISDKLog log:__func__ desc:@"通过交易密码创建 weid" argKeys:@[@"transPwd",@"keyPair"] argValues:@[@"nil",keyPair]];
//            }
//
//            [self __createWeId:transPwd keyPair:keyPair callback:callback];
//        }else{
//            callback(NO,nil,nil);
//        }
//    }];
//    WIKeyPairModel *keyPair = [[WIHDWallet sharedInstance] createKeyPair];

}

- (void)__createWeId:(NSString *)transPwd keyPair:(WIHDWalletKeyPair *)keyPair callback:(void (^)(BOOL, WeIdInfo *, NSError * ))callback{
    NSString *base64PubKey = [WICryptoUtils b64StringFromHexString:[keyPair.keyPair publicKeyString]];
    
    //TODO: 增加一个index参数
    NSDictionary *param = @{@"publicKeySecp256k1":base64PubKey};
    [WISDKLog log:__func__ desc:@"发送创建 weid 网络请求"
          argKeys:@[@"transPwd",@"keyPair",@"param"]
        argValues:@[transPwd == nil?@"nil":transPwd,keyPair,param]];
    
    void (^responseBlock) (id) = ^(id response){
        int code = [response[@"errorCode"] intValue];
        if (code == 0) {
            WIDocument *document = [WIDocument  yy_modelWithDictionary:response[@"respBody"]];
            [self __saveWeId:document keyPair:keyPair transPwd:transPwd error:nil callback:callback];
        }else{
            if(code == 100105){
             // 特殊错误码.
                //TODO: ?????
                [[WIHDWalletInternalService sharedService] updateCurrentIndex:keyPair.keyPairIndex callback:^(BOOL succeed) {
                    //这个错误不用管
                }];
            }
            NSError *error = [NSError errorWithDomain:@"weid.getWIDocumentByWeId" code:code userInfo:@{
                NSLocalizedDescriptionKey:response[@"errorMessage"]
            }];
            callback(NO,nil,error);
        }
    };
    
    if ( [[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
        [[WINetworkManager manager]  requestWithFuncName:WIFunctionName_CreateWeIdWithPubKey
                                                     url:[[WIConfig SDKConfig] weIdURL]
                                                   param:param
                                                 success:^(id _Nullable response) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"response:%@",response);
            responseBlock(response);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(NO,nil,error);
        }];
        
    }else{
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSDictionary *funcParam = [[WINetworkManager manager] functionParam:param functionName:WIFunctionName_CreateWeIdWithPubKey];
        
        if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)]) {
            [self.requestDelegate requestWithFunctionName:WIFunctionName_CreateWeIdWithPubKey
                                                    param:funcParam
                                                  success:^(id _Nullable response) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"response:%@",response);
                responseBlock(response);
            }failure:^( NSError * _Nonnull error) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",error);
                callback(NO,nil,error);
            }];
        }
    }
}

- (void) __saveWeId:(NSString *)weId keyId:(NSString *)keyId transPwd:(NSString *)transPwd keyPair:(WIHDWalletKeyPair *)keyPair callback:(void(^)(BOOL res))callback{
    [[WIHDWalletInternalService sharedService] saveWIKeyPair:weId
                                                       keyId:keyId
                                                     keyPair:keyPair
                                                    transPwd:transPwd
                                                    callback:callback];
}
- (void) __saveWeId:(WIDocument *)wiDocument
            keyPair:(WIHDWalletKeyPair *)keyPair
           transPwd:(NSString *)transPwd
              error:(NSError *)error callback:(void (^)(BOOL, WeIdInfo *, NSError * ))callback{
    if (wiDocument != nil) {
        NSString *weId = wiDocument.id;
        NSString *keyId = [wiDocument getKeyIdByPublicKey:[keyPair.keyPair publicKeyString] isHexDocument:NO];
        if (keyId == nil) {
            NSError *error = [NSError errorWithDomain:@"weid.create" code:-1 userInfo:@{
                NSLocalizedDescriptionKey:@"no keyId for special publicKey"
            }];
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"no keyId for special publicKey.");
            callback(NO,nil,error);
            return;
        }
        
        // 创建 weid 成功, save weid.
        [self __saveWeId:weId keyId:keyId transPwd:transPwd keyPair:keyPair callback:^(BOOL res) {
            if (res) {
                // 本地保存 weid info
                WeIdInfo *info = [WeIdInfo infoWithWeId:weId
                                                  keyId:keyId
                                                keyPair:keyPair.keyPair
                                               document:wiDocument];
                // [[WIManager manager] addWeIdInfo:info];
                callback(YES, info, nil);
            }else{
                NSError *error = [NSError errorWithDomain:@"weid.create" code:-1 userInfo:@{
                    NSLocalizedDescriptionKey:@"save WIKeyPair failed"
                }];
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"save WIKeyPair failed.");
                callback(NO, nil, error);
            }
        }];
       
    }
}

- (void)getWIDocumentByWeId:(NSString *)weId
                   callback:(void (^)(BOOL, WIDocument * , NSError * ))callback{
    
    void(^networkCallback)(id response) = ^(id response){
        int code = [response[@"errorCode"] intValue];
        //        NSAssert(code == 0, @"后台返回异常");
        if (code==0) {
            WIDocument *document = [WIDocument  yy_modelWithDictionary:response[@"respBody"]];
            callback(code == 0, document,nil);
        }else{
            NSError *error = [NSError errorWithDomain:@"weid.getWIDocumentByWeId" code:code userInfo:@{
                NSLocalizedDescriptionKey:response[@"errorMessage"]
            }];
            callback(NO,nil,error);
        }
    };
    NSDictionary *param = @{@"weId":weId};
    if ( [[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
        [[WINetworkManager manager] requestWithFuncName:WIFunctionName_GetWIDocument
                                                    url: [[WIConfig SDKConfig] weIdURL]
                                                  param:param
                                                success:^(id _Nullable response) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",response);
            networkCallback(response);
            
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(NO, nil, error);
        }];
    }else{
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSDictionary *funcParam = [[WINetworkManager manager] functionParam:param functionName:WIFunctionName_GetWIDocument];
        
        if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)]) {
            [self.requestDelegate requestWithFunctionName:WIFunctionName_CreateWeIdWithPubKey
                                                    param:funcParam
                                                  success:^(id _Nullable response) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"response:%@",response);
                networkCallback(response);
            }failure:^( NSError * _Nonnull error) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",error);
                callback(NO,nil,error);
            }];
        }
    }
    
  
}

/**
 * base64格式的公钥列表
 * {
 errorCode = 500100;
 errorMessage = "Get weId list by pubKeyList error. ";
 loopback = "<null>";
 respBody =     {
     errorCodeList =         (
         0,
         0,
         0,
         0,
         100117,
         100117,
         100117,
         100117,
         100117,
         100117
     );
     weIdList =         (
         "did:weid:199:0x51925d8590cd6fc507d08c3263b375f834a2c84d",
         "did:weid:199:0x5082c3e9f0ce414cad1e34f3d6da2ba0f7338317",
         "did:weid:199:0x57f62f0196bbc789ce1f6268bb1579ee706651f1",
         "did:weid:199:0x243479fab727dfc32b5ae4143998737d13b4a85c",
         "<null>",
         "<null>",
         "<null>",
         "<null>",
         "<null>",
         "<null>"
     );
 };
}
 */
-(void)getWeIdByPubKeyList:(NSArray *)publicKeyList callback:(void(^)(BOOL success,NSString *msg,NSArray *weIdList))callback
{
    
    // 网络请求
    void(^networkCallback)(id response) = ^(id response){
        int code = [response[@"errorCode"] intValue];
        //        NSAssert(code == 0, @"后台返回异常");
        if (code == 0 || code == 500100) {
            // 将 weid 过滤出来.
            NSArray *errorCodeList = response[@"respBody"][@"errorCodeList"];
            NSArray *weIdList = response[@"respBody"][@"weIdList"];
            NSMutableArray *mutArr = [NSMutableArray array];
            for (int i = 0; i < errorCodeList.count; i++) {
                NSNumber *num = errorCodeList[i];
                if ([num integerValue] == 0 && weIdList[i] != nil) {
                    [mutArr addObject:weIdList[i]];
                }
            }
            NSArray *arr = [NSArray arrayWithArray:mutArr];
            if(!arr.count && !self.isNullWithFirstRequest){
                self.isNullWithFirstRequest = NO;
                callback(NO, @"error code:500100",nil);
            }else{
                self.isNullWithFirstRequest = YES;
                callback(YES, @"get weid by public key succeed.",arr);
            }
        }else{
            callback(NO,response[@"errorMessage"],nil);
        }
    };
    NSDictionary *param = @{@"publicKeyList":publicKeyList};
    if ( [[WIConfig SDKConfig] requestType] == WISDKRequestWeIDBySDK) {
        [[WINetworkManager manager] requestWithFuncName:WIFunctionName_GetWeIdListByPubKeyList
                                                    url: [[WIConfig SDKConfig] weIdURL]
                                                  param:param
                                                success:^(id _Nullable response) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",response);
            networkCallback(response);
            
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",error);
            callback(NO, error.localizedDescription, nil);
        }];
    }else{
        BOOL res = [service requestDelegate] && [service.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)];
        NSAssert(res, @"APP must set requestDelegate ,implement `requestWithFunctionName:param:success:failure:` method!!!");
        NSDictionary *funcParam = [[WINetworkManager manager] functionParam:param functionName:WIFunctionName_GetWeIdListByPubKeyList];
        
        if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(requestWithFunctionName:param:success:failure:)]) {
            [self.requestDelegate requestWithFunctionName:WIFunctionName_GetWeIdListByPubKeyList
                                                    param:funcParam
                                                  success:^(id _Nullable response) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"response:%@",response);
                networkCallback(response);
            }failure:^( NSError * _Nonnull error) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"%@",error);
                callback(NO, error.localizedDescription, nil);
            }];
        }
    }
}

- (NSString *)__base64EncodeString:(NSString *)string{
    if(WISDKLog.sharedInstance.printLog){
        NSLog(@"%s",__func__);
        NSLog(@"string:%@",string);
    }
    NSData *data = [self __dataFromHexString:string];
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    return base64;
}

- (NSData *)__dataFromHexString:(NSString *)originalHexString{
    NSString *hexString = [originalHexString stringByReplacingOccurrencesOfString:@"[ <>]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [originalHexString length])]; // strip out spaces (between every four bytes), "<" (at the start) and ">" (at the end)
    NSMutableData *data = [NSMutableData dataWithCapacity:[hexString length] / 2];
    for (NSInteger i = 0; i < [hexString length]; i += 2){
        NSString *hexChar = [hexString substringWithRange: NSMakeRange(i, 2)];
        int value;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        uint8_t byte = value;
        [data appendBytes:&byte length:1];
    }
    return data;
}



@end
