//
//  WIManager.m
//  WeIdentityService
//
//  Created by tank on 2020/12/31.
//

#import "WIManager.h"
#import "WISDKLog.h"
@interface WIManager()
//key: weid#keyId,value: publicKeyHex
@property (nonatomic, strong) NSMutableDictionary *weIdInfoMap;
@end

static WIManager *manager = nil;

@implementation WIManager

+(instancetype)manager{
    if (manager == nil) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"初始化 WIManager 失败,调用这个接口之前,需要调用 +[managerWithName:encryptDB:]");
    }
    NSAssert(manager != nil, @"初始化 WIManager 失败,调用这个接口之前,需要调用 +[managerWithName:encryptDB:]");
    return manager;
}

+ (void)managerWithName:(NSString *)name encryptDB:(BOOL)encryptDB callback:(void (^)(WIManager *, NSError *))callback{

    [WISDKLog log:__func__ desc:@"首次初始化 WIManager" argKeys:@[@"name",@"encryptDB"] argValues:@[name,@(encryptDB)]];
    manager = [WIManager new];
    manager.weIdInfoMap = [NSMutableDictionary dictionary];
    [WICredentialPersistence initWithDomain:name encryptDB:encryptDB callback:^(WICredentialPersistence * credentialPersistence, NSError * err) {
        if(err !=nil){
            callback(nil,err);
            return;
        }else{
            manager.credentialStore = credentialPersistence;
            [WISDKLog log:__func__ desc:@"WIManager 已经完成初始化了" argKeys:@[@"weIdInfoMap"] argValues:@[manager.weIdInfoMap]];
            callback(manager,nil);
        }
    }];
}

//- (void)getPublicKeyByWeId:(NSString *)issuerWeId
//                     keyId:(NSString *)keyId
//                  callback:(void (^) (BOOL,NSString *))callback{
//    
//    NSString *publicKey = [self __getWeIdPublicKey:issuerWeId keyId:keyId];
//    if (publicKey != nil) {
//        // 使用缓存的
//        callback(YES, publicKey);
//    }else{
//        [[WIWeIdentityService sharedService] getWIDocumentByWeId:issuerWeId
//                                                          callback:^(BOOL succeed, WIDocument * _Nonnull document, NSError * _Nonnull error) {
//            if (!succeed) {
//                callback(NO, error.localizedDescription);
//            }else{
//                
//                NSString *pubKeyHex = [document getPublicKeyByKeyId:keyId];
//                [WISDKLog log:__func__ desc:@"WIManager 后台获取 pubkey" argKeys:@[@"weiId",@"keyId",@"pubKeyHex"] argValues:@[issuerWeId,keyId,pubKeyHex]];
//                [self addWeIdInfo:issuerWeId keyId:keyId publicKeyHex:pubKeyHex];
//                callback(YES, pubKeyHex);
//            }
//        }];
//    }
//}

- (NSString *)__getWeIdPublicKey:(NSString *)weId keyId:(NSString *)keyId{
    NSString *key = [NSString stringWithFormat:@"%@#%@",weId,keyId];
    
    [WISDKLog log:__func__ desc:@"WIManager 本地获取 pubkey" argKeys:@[@"weiId",@"keyId",@"key",@"self.weIdInfoMap"] argValues:@[weId,keyId,key,self.weIdInfoMap]];
    
    return [self.weIdInfoMap objectForKey:key];
}

- (void)addWeIdInfo:(WeIdInfo *)weIdInfo{
    NSString *key = [NSString stringWithFormat:@"%@#%@",weIdInfo.weId,weIdInfo.keyId];
    self.weIdInfoMap[key] = [weIdInfo.wiDocument getPublicKeyByKeyId:weIdInfo.keyId];
    [WISDKLog log:__func__ desc:@"WIManager 本地保存 weid info" argKeys:@[@"weIdInfo",@"key",@"self.weIdInfoMap"] argValues:@[weIdInfo,key,self.weIdInfoMap]];
}

- (void)addWeIdInfo:(NSString *)weiId keyId:(NSString *)keyId publicKeyHex:(NSString *)publicKeyHex{
    NSString *key = [NSString stringWithFormat:@"%@#%@",weiId,keyId];
    [self.weIdInfoMap setObject:publicKeyHex forKey:key];
    [WISDKLog log:__func__ desc:@"WIManager 本地保存 weid info" argKeys:@[@"weiId",@"keyId",@"publicKeyHex",@"key",@"self.weIdInfoMap"] argValues:@[weiId,keyId,publicKeyHex,key,self.weIdInfoMap]];
}

- (void)reset{
    manager = nil;
}

@end
