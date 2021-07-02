//
//  WIStringModel+WCTTableCoding.h
//  WeIdentityService
//
//  Created by tank on 2020/11/11.
//

#import "WIStringModel.h"
#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIStringModel (WCTTableCoding)<WCTTableCoding>

WCDB_PROPERTY(key)
WCDB_PROPERTY(value)


@end

NS_ASSUME_NONNULL_END
