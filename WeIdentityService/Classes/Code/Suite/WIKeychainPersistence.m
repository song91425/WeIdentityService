//
//  WIKeychainPersistence.m
//  Pods
//
//  Created by lssong on 2020/11/10.
//

#import "WIKeychainPersistence.h"
#import <Security/Security.h>
#import "WISDKLog.h"
@interface WIKeychainPersistence()

// domain 不同场景的名称区分
@property(nonatomic, copy)NSString *domain;

@end

@implementation WIKeychainPersistence

-(BOOL)deleteKeyChainPersistenceWithDomain:(NSString *)domain{
    // 获取删除数据的查询条件
    [WISDKLog log:__func__ desc:@"Keychain Persistence delete Item by domain." argKeys:@[@"domain"] argValues:@[domain]];
    NSMutableDictionary * deleteDic = [self setStoreAtrribution];
    [deleteDic setObject:[domain dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationTag];
    // 删除指定条件的数据
    OSStatus status=  SecItemDelete((__bridge CFDictionaryRef)deleteDic);
    if (status == errSecSuccess) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"The specified item was been found in the keychain, and deleted it.");
        return YES;
    }else{
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"The specified item could not be found in the keychain.Meaning deleted success");
        return  NO;
    }
}

+ (instancetype)keyChainPersistenceWithDomain:(NSString *)domain{
    WIKeychainPersistence *keyChainManager;
    keyChainManager = [WIKeychainPersistence new];
    keyChainManager.domain =domain;
    [WISDKLog log:__func__ desc:@"创建 Keychain Persistence." argKeys:@[@"domain"] argValues:@[domain]];
    return keyChainManager;
}

-(int)add:(NSString *)itemId data:(NSString *)data{
    [WISDKLog log:__func__ desc:@"Keychain Persistence ADD." argKeys:@[@"domain",@"itemId",@"data"] argValues:@[self.domain,itemId,data]];
    // 获取存储的数据的条件
    NSMutableDictionary * addQueryDic = [self setStoreAtrribution];
    // 设置要删除的数据
    [addQueryDic setObject:[self.domain dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationTag];
    [addQueryDic setObject:[itemId dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationLabel];
    // 从KeyChain中删除旧的数据
    SecItemDelete((__bridge CFDictionaryRef)addQueryDic);

    [addQueryDic setObject:[data dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
    
    // 添加数据到KeyChain
    OSStatus addState = SecItemAdd((__bridge CFDictionaryRef) addQueryDic, nil);
    addQueryDic = nil;
    if(addState == errSecSuccess){
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"SecItemAdd success");
        return YES;
    }
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"SecItemAdd fail");
    return NO;
}

- (int)batchAdd:(NSDictionary<NSString *,NSString *> *) datas{
    [WISDKLog log:__func__ desc:@"Keychain Persistence batchAdd." argKeys:@[@"domain",@"data"] argValues:@[self.domain,datas]];
    if (datas == nil || datas.count <=0)  return 0;
    int success = 0;
   
    NSArray *item = datas.allKeys;
    for (NSString *itemId in item) {
        int result = [self add:itemId data:datas[itemId]];
        if (result == 0) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"Try to add domain:%@ itemId:%@ data:%@ to keyChain item failure",self.domain, itemId,datas[itemId]);
        }
        success += result;
    }
   
    if (success == datas.count) {
        return 1;
    }
    return 0;
}

-(NSString *)get:(NSString *) itemId{
    // 获取存储的数据的条件
    NSMutableDictionary *queryDic = [self setStoreAtrribution];
    
    [queryDic setObject:[self.domain dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationTag];
    [queryDic setObject:[itemId dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationLabel];// 按照item 查询
    
    [queryDic setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData]; // 查询结果返回到 kSecValueData
    [queryDic setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit]; // 只返回搜索到的第一条数据
    
    // 创建一个对象接受结果
    CFTypeRef keyChainData = nil ;
    NSString *result =nil;
    // 通过条件查询数据
    if (SecItemCopyMatching((__bridge CFDictionaryRef)queryDic , &keyChainData) == errSecSuccess){
        @try {
            
           NSData *resultData = (__bridge NSData *)keyChainData;

           result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        } @catch (NSException * exception){
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"No match value for the key:%@",itemId);
        }
    }
    if (keyChainData) {
        CFRelease(keyChainData); // 释放对象
    }
    queryDic = nil;
    [WISDKLog log:__func__ desc:@"Keychain Persistence get." argKeys:@[@"domain",@"itemId",@"result"] argValues:@[self.domain,itemId,result?result:@"nil"]];
    return result;
}

-(NSDictionary *)getByDomain:(NSString *)domain{
    // 获取存储的数据的条件
    NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
    [queryDic setDictionary: @{
            (id)kSecClass : (id)kSecClassKey,
            (id)kSecAttrAccessible : (id)kSecAttrAccessibleWhenUnlocked,
            (id)kSecAttrKeyType : (id)kSecAttrKeyTypeEC
    }];
    
    [queryDic setObject:[domain dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationTag];
    [queryDic setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes]; // 查询结果返回到 kSecReturnAttributes
    [queryDic setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit]; // 只返回搜索到的第一条数据
    
    NSMutableDictionary *dicRet = nil;
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDic, &result);
    if(status == errSecSuccess && result!=NULL){
        dicRet = [NSMutableDictionary dictionary];
        for (NSDictionary *dic in (__bridge NSArray *)result) {
            NSData *keyData =dic[(id)kSecAttrApplicationLabel];
            NSString *key = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
            // 查value
            NSString *value = [self p_getItemWithDomain:domain item:key];
            [dicRet setObject:value forKey:key];
        }
        return dicRet.count ==0 ? nil :dicRet;
    }else{
        return nil;
    }
}

-(NSString *) p_getItemWithDomain:(NSString *)domain item:(NSString *) itemId{
    // 获取存储的数据的条件
    NSMutableDictionary *queryDic = [self setStoreAtrribution];
    
    [queryDic setObject:[domain dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationTag];
    [queryDic setObject:[itemId dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationLabel];// 按照item 查询
    
    [queryDic setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData]; // 查询结果返回到 kSecValueData
    [queryDic setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit]; // 只返回搜索到的第一条数据
    
    // 创建一个对象接受结果
    CFTypeRef keyChainData = nil ;
    NSString *result =nil;
    // 通过条件查询数据
    if (SecItemCopyMatching((__bridge CFDictionaryRef)queryDic , &keyChainData) == errSecSuccess){
        @try {
            
           NSData *resultData = (__bridge NSData *)keyChainData;

           result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        } @catch (NSException * exception){
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"No match value for the key:%@",itemId);
        }
    }
    if (keyChainData) {
        CFRelease(keyChainData); // 释放对象
    }
    queryDic = nil;
    [WISDKLog log:__func__ desc:@"Keychain Persistence get." argKeys:@[@"itemId",@"result"] argValues:@[itemId,result?result:@"nil"]];
    return result;
}

- (int)deleteItem:(NSString *)itemId{
    // 获取删除数据的查询条件
    [WISDKLog log:__func__ desc:@"Keychain Persistence delete Item." argKeys:@[@"domain",@"itemId"] argValues:@[self.domain,itemId]];
    NSMutableDictionary * deleteDic = [self setStoreAtrribution];
    [deleteDic setObject:[self.domain dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationTag];
    [deleteDic setObject:[itemId dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationLabel];// 按照item 删除
    // 删除指定条件的数据
    OSStatus status=  SecItemDelete((__bridge CFDictionaryRef)deleteDic);
    if (status == errSecSuccess) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"The specified item was been found in the keychain, and deleted it.");
    }else{
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"The specified item could not be found in the keychain.Meaning deleted success");
    }
    deleteDic = nil ;
    return YES;
}

- (int)update:(NSString *)itemId data:(NSString *)data{
    // 获取数据更新的条件
    [WISDKLog log:__func__ desc:@"Keychain Persistence delete Item." argKeys:@[@"domain",@"itemId",@"data"] argValues:@[self.domain,itemId,data]];
    NSMutableDictionary * updataDic = [self setStoreAtrribution];
    [updataDic setObject:[self.domain dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationTag];
    [updataDic setObject:[itemId dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrApplicationLabel];// 按照item 更新
    // 创建更新数据字典
    NSDictionary * changeDic = @{
        (id)kSecValueData:[data dataUsingEncoding:NSUTF8StringEncoding]
    };
    
    // 更新存储的状态
    OSStatus  updataStatus = SecItemUpdate((__bridge CFDictionaryRef)updataDic, (CFDictionaryRef)changeDic);
    updataDic = nil;
    changeDic = nil;
    
    // 判断是否更新成功
    if (updataStatus == errSecSuccess) {
        return  YES ;
    }
    return NO;
}

-(NSMutableDictionary *) setStoreAtrribution{
    /** 字典每个key的含义
     // 构建一个存取条件，指明存储的是秘钥
     // 指定秘钥的加密算法。
     // 指定存储的是私钥
     // 指定该秘钥的访问权限，只有在解锁的时候才能够访问
     // 指定key的size
     // 指定key可以解码
     // 指定key可以编码
     */
    NSDictionary *keychainItems = @{
        (id)kSecClass : (id)kSecClassKey,
        (id)kSecAttrAccessible : (id)kSecAttrAccessibleWhenUnlocked,
        (id)kSecAttrKeyType : (id)kSecAttrKeyTypeEC,
        (id)kSecAttrKeyClass : (id)kSecAttrKeyClassPrivate,
        (id)kSecAttrKeySizeInBits : @(256),
        (id)kSecAttrCanDecrypt:(id)kCFBooleanTrue,
        (id)kSecAttrCanEncrypt:(id)kCFBooleanTrue
    };
    return keychainItems.mutableCopy;
    
    /**
     NSDictionary *keychainItems = @{
            (id)kSecClass : (id)kSecClassKey,
            (id)kSecAttrAccessible : (id)kSecAttrAccessibleWhenUnlocked,
            (id)kSecAttrKeyType : (id)kSecAttrKeyTypeEC,
            (id)kSecAttrKeyClass : (id)kSecAttrKeyClassPrivate,
            (id)kSecAttrKeySizeInBits : @(256),
            (id)kSecAttrCanDecrypt:(id)kCFBooleanTrue,
            (id)kSecAttrCanEncrypt:(id)kCFBooleanTrue
        };
     */
}

- (void)clearKeyChain {
    [WISDKLog log:__FUNCTION__ desc:@"清理 keychain."];
    
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnAttributes,
                                  (__bridge id)kSecMatchLimitAll, (__bridge id)kSecMatchLimit,
                                  nil];
    NSArray *secItemClasses = [NSArray arrayWithObjects:
                               (__bridge id)kSecClassGenericPassword,
                               (__bridge id)kSecClassInternetPassword,
                               (__bridge id)kSecClassCertificate,
                               (__bridge id)kSecClassKey,
                               (__bridge id)kSecClassIdentity,
                               nil];
    for (id secItemClass in secItemClasses) {
        [query setObject:secItemClass forKey:(__bridge id)kSecClass];
         
        CFTypeRef result = NULL;
        SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
        if (result != NULL) CFRelease(result);
         
        NSDictionary *spec = @{(__bridge id)kSecClass: secItemClass};
        SecItemDelete((__bridge CFDictionaryRef)spec);
    }
}
@end
