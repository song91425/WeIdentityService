//
//  WIDBPersistence.m
//  AFNetworking
//
//  Created by tank on 2020/11/6.
//

#import "WIDBPersistence.h"

#import <objc/runtime.h>
#import "WIHDWallet.h"
#import "WISDKLog.h"
#import <WeIdentityService/WISDKLog.h>

@interface WIDBPersistence()


@property (nonatomic, copy) NSString *cipherKey;
@property (nonatomic, copy) NSString *table;

@property (nonatomic, strong) WCTDatabase *database;

@end


@implementation WIDBPersistence

+ (instancetype)persistenceWithDomain:(NSString *)domain
                            domainPwd:(NSString *)domainPwd
{
    WIDBPersistence *persistence = [WIDBPersistence new];
    WCTDatabase *db = [self getDatabase:domain cipherKey:domainPwd];
    if ([db canOpen]) {
        [WISDKLog log:__FUNCTION__ desc:@"创建 WIDBPersistence " argKeys:@[@"domain",@"domainPwd"] argValues:@[domain,domainPwd]];
    }else{
        [WISDKLog log:__FUNCTION__ desc:@"创建 WIDBPersistence 失败: can't open" argKeys:@[@"domain",@"domainPwd"] argValues:@[domain,domainPwd]];
    }
    NSAssert([db canOpen], @"GGGGG... DB CAN'T OPEN.");
    persistence.database = db;
    persistence.cipherKey = domainPwd;
    
    return persistence;
}

+ (WCTDatabase *)getDatabase:(NSString *)domain cipherKey:(NSString *)cipherKey{
    if(WISDKLog.sharedInstance.printLog){
        NSLog(@"%s\nfilePath:%@\ncipherKey:%@",__func__,domain,cipherKey);
    }
    NSString *filePath = [self getDatabasePath:domain];
    if(WISDKLog.sharedInstance.printLog){
        NSLog(@"wChatDatapath = %@",filePath);
    }
    WCTDatabase *database = [[WCTDatabase alloc] initWithPath:filePath];
    if (cipherKey != nil) {
        NSData *password = [cipherKey dataUsingEncoding:NSUTF8StringEncoding];
        [database setCipherKey:password];
        if(WISDKLog.sharedInstance.printLog){
            NSLog(@"password = %@",password);
        }
    }
    return database;
}

+ (NSString *)getDatabasePath:(NSString *)domain{
    //获取沙盒根目录
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbName = [NSString stringWithFormat:@"wi-%@.sqlite",domain];
    // 文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:dbName];
    return filePath;
}


-(BOOL)getTableWithName:(NSString *)name cls:(Class<WCTTableCoding>)cls{
    if(WISDKLog.sharedInstance.printLog){
        NSLog(@"%s\nname:%@\ncls:%@",__func__,name,cls);
    }
    BOOL canOpen = [self.database canOpen]; // 测试数据库是否能够打开
    NSAssert(canOpen, @"数据库异常,不能打开.");
    // WCDB大量使用延迟初始化（Lazy initialization）的方式管理对象，因此SQLite连接会在第一次被访问时被打开。开发者不需要手动打开数据库。
    // 先判断表是不是已经存在
    if ([self.database isOpened]) {
        if ([self.database isTableExists:name]) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@">>>>>> 表已经存在了.");
            return YES;
        }else{
            if(WISDKLog.sharedInstance.printLog){
                NSLog(@">>>>>> 新建表.");
            }
            return [self.database createTableAndIndexesOfName:name withClass:cls.class.class];
        }
    }
    return NO;
}

-(int)add:(NSObject<WCTTableCoding>*)object{
    NSString *cls_name = NSStringFromClass(object.class);
    [self getTableWithName:cls_name cls:object.class];
    
    BOOL result = [self.database insertObject:object into:cls_name];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"insert result:%d",result);
    //NSAssert(result, @"SDK insert object failed.");
    return result;
}

-(int)batchAdd:(NSArray <NSObject<WCTTableCoding>*>*)objects{
    NSAssert(objects.count > 0, @"传入的数组不合法");
    NSObject* obj = objects[0];
    NSString *cls_name = NSStringFromClass(obj.class);
    [self getTableWithName:cls_name cls:obj.class];
    
    BOOL result = [self.database insertObjects:objects into:cls_name];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"batch insert result:%d",result);
    return result;
}

- (NSArray /* <WCTObject*> */ *)getAllObjectsOfClass:(Class)cls{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    NSArray *messages = [self.database getAllObjectsOfClass:cls.class fromTable:NSStringFromClass(cls)];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"messages:%@",messages);
    return messages;
}


- (NSArray /* <WCTObject*> */ *)get:(Class)cls
                              where:(const WCTCondition &)condition
                            orderBy:(const WCTOrderByList &)orderList
                                num:(const WCTLimit &)num
                              index:(const WCTOffset &)index
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    NSArray *messages = [self.database getObjectsOfClass:cls.class
                                               fromTable:NSStringFromClass(cls)
                                                   where:condition
                                                 orderBy:orderList
                                                   limit:num
                                                  offset:index];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"messages:%@",messages);
    return messages;
}


- (NSArray /* <WCTObject*> */ *)getObjectsOfClass:(Class)cls where:(const WCTCondition &)condition
{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%s",__func__);
    NSArray *messages = [self.database getObjectsOfClass:cls fromTable:NSStringFromClass(cls) where:condition];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"messages:%@",messages);
    return messages;
}



- (int)update:(Class)cls
   onProperty:(const WCTProperty &)property
   withObject:(WCTObject *)object
        where:(const WCTCondition &)condition{
    
    return [self.database updateRowsInTable:NSStringFromClass(cls)
                                 onProperty:property
                                 withObject:object
                                      where:condition];
}


- (BOOL)deleteAllObjectsOfClass:(Class)cls{
    return [self.database deleteAllObjectsFromTable:NSStringFromClass(cls)];
}

- (int)deleteObjectsOfClass:(Class)cls where:(const WCTCondition &)condition num:(const WCTLimit &)num index:(const WCTOffset &)index{
    return [self.database deleteObjectsFromTable:NSStringFromClass(cls)
                                           where:condition
                                           limit:num
                                          offset:index];
}

- (BOOL)deleteObjectsOfClass:(Class)cls
                       where:(const WCTCondition &)condition{
    return [self.database deleteObjectsFromTable:NSStringFromClass(cls)
                                           where:condition];
}

- (BOOL)removeDBWithError:(WCTError **)error{
    return [self.database removeFilesWithError:error];
}
@end
