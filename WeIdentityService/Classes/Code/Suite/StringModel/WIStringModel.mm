//
//  WIStringModel.m
//  WeIdentityService
//
//  Created by tank on 2020/11/11.
//

#import "WIStringModel.h"
#import <WCDB/WCDB.h>

@implementation WIStringModel

WCDB_IMPLEMENTATION(WIStringModel)
WCDB_SYNTHESIZE(WIStringModel, key)
WCDB_SYNTHESIZE(WIStringModel, value)

WCDB_PRIMARY(WIStringModel, key)
+ (NSString *)generateKey:(NSString *)domain itemID:(NSString *)itemID{
    return [NSString stringWithFormat:@"%@w-i%@",domain,itemID];
}

-(instancetype)initWithDomain:(NSString*)domain itemID:(NSString *)itemID content:(NSString*)content{
    if (self = [super init]) {
        self.key = [NSString stringWithFormat:@"%@w-i%@",domain,itemID];
        self.value = content;
    }
    return self;
}

- (NSString *)description
{
    NSArray*arr = [self.key componentsSeparatedByString:@"w-i"];
    return [NSString stringWithFormat:@"domain:%@ itemId:%@ content:%@", arr[0],arr[1],self.value];
}

@end
