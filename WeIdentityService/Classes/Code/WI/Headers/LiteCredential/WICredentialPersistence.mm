//
//  WICredentialPersistence.m
//  WeIdentityService
//
//  Created by tank on 2021/1/4.
//

#import "WICredentialPersistence.h"
#import "WIHDWallet.h"
#import "WIDBPersistence.h"

#import "WICredential.h"
#import "WICredential+WCTTableCoding.h"
#import "WIWalletManager.h"
#import "WISDKLog.h"
#import <WeIdentityService/WISDKLog.h>
@interface WICredentialPersistence()

@property (nonatomic, strong)WIDBPersistence *persistence;

@end

@implementation WICredentialPersistence

+ (void)initWithDomain:(NSString *)domain encryptDB:(BOOL)encryptDB callback:(void(^)(WICredentialPersistence *, NSError *)) callback
{
    WICredentialPersistence *credentialPer = [WICredentialPersistence new];
    NSString  __block * domainPwd = nil;
    NSString *dbName = [[WIWalletManager manager] getWalletDBName:domain];
    if (encryptDB) {
        [[WIHDWallet sharedInstance] getOrCreateDomainPwd:dbName callback:^(NSString * pwd, NSError * err) {
            //NSString *pwd = [[WIHDWallet sharedInstance] getOrCreateDomainPwd:dbName];
            if(err != nil){
                callback(nil,err);
                return;
            }
            if (pwd == nil) {
                if(WISDKLog.sharedInstance.printLog)
                    NSLog(@"get db pwd failed");
                [WISDKLog log:__FUNCTION__
                         desc:@"WICredentialPersistence 创建 DB 存放 credential, 从 HDWallet 获取密码 nil"
                      argKeys:@[@"domain"] argValues:@[domain]];
                NSAssert(pwd != nil, @"get db pwd failed");
            }
            domainPwd = pwd;
        }];
    }

    WIDBPersistence *per = [WIDBPersistence persistenceWithDomain:dbName domainPwd:domainPwd];
    [WISDKLog log:__FUNCTION__ desc:@"WICredentialPersistence 创建 DB 存放 credential, 有密码" argKeys:@[@"domain",@"domainPwd"] argValues:@[domain,domainPwd]];
    credentialPer.persistence = per;
    
    // 在 HDWallet 中注册 db
    [[WIWalletManager manager] registerDatabase:dbName];
    callback(credentialPer,nil);
    return ;
}

- (void)saveCredential:(WICredential *)credential callback:(void(^)(BOOL,NSString*))callback{
    BOOL add = [self.persistence add:credential];
    if (add == 1) {
        // 存成功.
        if (callback)
            callback(YES,@"Success.");
    }else{
        // 存失败.
        if (callback)
            callback(NO,@"save credential failed.");
    }
}

- (void) loadByCredentialId:(NSString *)credentialId
                   callback:(void(^)(BOOL,WICredential*,NSString*))callback{
    
    [self loadByCredentials:nil];
    
    NSArray *resArr = [self.persistence getObjectsOfClass:WICredential.class
                                                    where:WICredential.id == credentialId];
    if (resArr && resArr.count == 1) {
        if (callback)
            callback(YES,resArr[0],@"load succeed.");
    }else{
        NSString *log = [NSString stringWithFormat:@"loadByCredentialId error-\nid:%@\nresArr:-%@",credentialId,resArr];
        if (callback)
            callback(NO,nil,@"not found credential.");
        NSAssert(resArr.count <= 1, log);
    }
    
}

- (void)deleteCredentialBy:(NSString *)credentialID callback:(void(^)(BOOL))callback{
    BOOL del = [self.persistence deleteObjectsOfClass:WICredential.class
                                                where:WICredential.id == credentialID];
    if (callback)
        callback(del);
    
}
- (void) loadByCredentials:(void(^)(BOOL,NSArray*,NSString*))callback{
    NSArray *res = [self.persistence getAllObjectsOfClass:WICredential.class];
    if (res != nil) {
        [WISDKLog log:__FUNCTION__ desc:@"测试用,加载所有的 credential | 合计:" argKeys:@[@"counts",@"credentials"] argValues:@[@(res.count),res]];
    }else{
        [WISDKLog log:__FUNCTION__ desc:@"测试用,加载所有的 credential...." argKeys:@[@"credentials"] argValues:@[@"nil"]];
    }
}

//TODO: 待处理的问题, 删除 db.
- (void) __deleteDB{
    WCTError *err = nil;
    [self.persistence removeDBWithError:&err];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%ld",(long)err.code);
}
@end
