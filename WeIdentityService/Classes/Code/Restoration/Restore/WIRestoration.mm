//
//  WIRestoration.m
//  WeIdentityService
//
//  Created by tank on 2021/1/8.
//

#import "WIRestoration.h"
#import "WICredentialService.h"
#import "WISaveDataWithFile.h"

#import "WIMnemonicsInfo.h"
#import "WICryptoUtils.h"
#import "WIHDWallet.h"

#import "WIDBPersistence.h"
#import "WIWalletManager.h"

#import "WISaveDataWithFile.h"
#import "WIError.h"
#import "WISDKLog.h"
@interface WIRestoration()
@property(nonatomic,strong) NSString *filePath; // 保存写入文件，返回的文件名称
@property(nonatomic, strong) WISaveDataWithFile* fileHandle;
//TODO 测试用，可删除
//@property(nonatomic,strong) NSMutableArray *filePathArr;// 每次只写一条数据的返回文件路径

@end

@implementation WIRestoration

- (WISaveDataWithFile *)fileHandle{
    if (_fileHandle == nil) {
        _fileHandle = [WISaveDataWithFile new];
    }
    return _fileHandle;
}

- (void)exportCredentialList:(NSString *)domain
                  restorePwd:(NSString *)restorePwd
                destFilePath:(NSString *)destFilePath
                    callback:(void(^)(BOOL success,NSArray *credentials,NSString *filePath,NSString *errMsg))callback
{
    // TODO: 判断文件是否已经存在...
    NSString *keyFromPwd = [self __getKeyFromPwd:restorePwd];
    NSAssert(keyFromPwd != nil, @"get key from restorePwd failed");
    if (keyFromPwd == nil) {
        callback(NO,nil,nil,@"get key from restorePwd failed.");
    }
    
    [[WIHDWallet sharedInstance] getDomainInfo:domain getPwd:YES callback:^(WIDomainInfo * domainInfo, NSError * error) {
        if (error!=nil) {
            callback(NO,nil,nil,error.localizedDescription);
            return;
        }
        
        NSString *dbName = [[WIWalletManager manager] getWalletDBName:domain];
        WIDBPersistence *persitence = [WIDBPersistence persistenceWithDomain:dbName domainPwd:domainInfo.domainPwd];
        NSAssert(persitence != nil, @"open persistence failed");
        if (persitence == nil) {
            callback(NO,nil,nil,@"open persistence failed.");
            return;
        }
        NSArray *res = [persitence getAllObjectsOfClass:[WICredential class]];
        if (res == nil || res.count < 1) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"no credential!!!");
            callback(NO,nil,nil,@"no credential");
        }else{
            NSString *path = [self.fileHandle writeContentWithFileName:destFilePath contentWithArray:res];
            callback(YES,res,path,nil);
        }
    }];
}

-(void)restoreCredentialListByFile:(NSString *)domain
                        restorePwd:(nonnull NSString *)restorePwd
                       srcFilePath:(nonnull NSString *)srcFilePath
                restoreModeIsForce:(BOOL)isForce
                          callback:(void(^)(BOOL success,NSArray *credentials,NSString *filePath,NSString *errMsg))callback
{
    if(!isForce){
        NSAssert(NO, @"restore merge mode not currently supported");
        callback(NO,nil,srcFilePath,@"restore merge mode not currently supported.");
        return;
    }
    
    // TODO: 判断文件是否存在
    // TODO: 读写文件改异步返回.
    NSString *keyFromPwd = [self __getKeyFromPwd:restorePwd];
    NSAssert(keyFromPwd != nil, @"get key from restorePwd failed");
    if (keyFromPwd == nil) {
        // ...
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"get key from restorePwd failed");
        callback(NO,nil,srcFilePath,@"get key from restorePwd failed.");
        return;
    }
    [[WIHDWallet sharedInstance] getDomainInfo:domain getPwd:YES callback:^(WIDomainInfo * domainInfo, NSError * err) {
        
        if (err!=nil) {
            callback(NO,nil,srcFilePath,err.localizedDescription);
            return;
        }
        NSString *dbName = [[WIWalletManager manager] getWalletDBName:domain];
        WIDBPersistence *persitence = [WIDBPersistence persistenceWithDomain:dbName domainPwd:domainInfo.domainPwd];
        
        NSAssert(persitence != nil, @"open persistence failed");
        if (persitence == nil) {
            //        callback(NO,nil,nil,@"open persistence failed.");
            callback(NO,nil,srcFilePath,@"open persistence failed.");
            return;
        }
        
        NSArray* res = [self.fileHandle readContentWithFileName:srcFilePath fileType:FileTypeArray];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSString *json in res) {
            WICredential *credential = [WICredential fromJson:json];
            if (credential != nil) {
                [mutArr addObject:credential];
            }else{
                NSAssert(credential != nil , @"json to credential failed.");
                callback(NO,nil,srcFilePath,@"json to credential failed.");
                return;
            }
        }
        NSArray *credentials = [NSArray arrayWithArray:mutArr];
        BOOL add = [persitence batchAdd:credentials];
        if (add) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"添加成功");
            callback(YES,credentials,srcFilePath,nil);
        }else{
            callback(NO,credentials,srcFilePath,@"batch add failed.");
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"添加失败");
        }
    }];
//    WIDomainInfo *domainInfo = [[WIHDWallet sharedInstance] getDomainInfo:domain getPwd:YES];
    
}

-(WIMnemonicsInfo *)__getMnenomics{
    
    return nil;
}

- (NSString *)__getKeyFromPwd:(NSString *)restorePwd
{
    return [WICryptoUtils hashTwice:restorePwd];
}

- (NSArray<WICredential *>*)mockCredentials{
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<10;i++) {
        WICredential *credential = [WICredential new];
        credential.context= [@"context" stringByAppendingFormat:@"-%i",i];
        credential.id = [@"id" stringByAppendingFormat:@"-%i",i];
        credential.cptId = 1+i;
        credential.issuer = [@"issuer" stringByAppendingFormat:@"-%i",i];
        credential.issuanceDate = 1232232313+i;
        credential.expirationDate= 322213345+i;
        credential.claim=@{@"claim1":[@"claim1" stringByAppendingFormat:@"-%i",i],
                           @"claim2":@(1+i),@"claim3":@YES} ;
        credential.f = @"1";
        credential.proof=@{@"proof1":[@"proof1" stringByAppendingFormat:@"-%i",i],
                           @"proof2":@(1+i),@"proof3":@NO} ;
        credential.type = [@"type" stringByAppendingFormat:@"-%i",i];
        [array addObject:credential];
    }
    return array;
}


@end
