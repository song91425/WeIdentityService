//
//  WIStringPersistence.m
//  WeIdentityService
//
//  Created by tank on 2020/11/9.
//

#import "WIKVPersistence.h"
#import "WIDBPersistence.h"
#import "WIStringModel.h"
#import "WIStringModel+WCTTableCoding.h"
#import "WIKeychainPersistence.h"

@interface WIKVPersistence()

@property (nonatomic, strong) WIDBPersistence *dbPersistence;
@end

@implementation WIKVPersistence

+ (instancetype)persistenceWithDomain:(NSString *)domain cipherKey:(NSString *)cipherKey{
    WIKVPersistence *persistence = [WIKVPersistence new];
//     persistence.dbPersistence = [WIDBPersistence persistenceWithDomain:domain cipherKey:cipherKey];
    return persistence;
}

- (int)add:(NSString *)domain itemId:(NSString *)itemId data:(NSString *)data{
    
        WIStringModel *model = [[WIStringModel alloc] initWithDomain:domain itemID:itemId content:data];
        return [self __insert:model];
}
// TODO: 这个借口没有给出去，KeyChain不太适合这个查询全部的表
- (NSArray *)getAllObjects{
    return [self.dbPersistence getAllObjectsOfClass:WIStringModel.class];
}

- (NSString *)get:(NSString *)domain itemId:(NSString *)itemId{
    NSString *key = [WIStringModel generateKey:domain itemID:itemId];
    NSArray *arr = [self.dbPersistence
                    get:WIStringModel.class
                    where:WIStringModel.key == key
                    orderBy:WIStringModel.key.order(WCTOrderedAscending)
                    num:100
                    index:0];
    if (arr && arr.count > 0) {
        WIStringModel *model = arr[0];
        return model.value;
    }
    return nil;
}

- (int)deleteObject:(NSString *)domain itemId:(NSString *)itemId{
    return NO;
}

- (int)update:(NSString *)domain itemId:(NSString *)itemId object:(NSString *)object{
    return NO;
}

- (int)deleteAll{
//    return [self.dbPersistence deleteAllObjectsOfClass:WIStringModel.class];
     return NO;
}

- (int)__insert:(WIStringModel*) model{
    BOOL ret =[self.dbPersistence add:model];
    [self getAllObjects];
    return ret;
}


@end
/**
 WIDBPersistence
 WIDBStringPersistence
 // dbPer
 
 WIKeychainPersistence
 // keychainPer
 */
