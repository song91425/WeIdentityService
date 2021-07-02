//
//  Message+WCTTableCoding.h
//  WeIdentityService_Example
//
//  Created by tank on 2020/11/9.
//  Copyright © 2020 shoutanxie@gmail.com. All rights reserved.
//

#import "Message.h"
#import <WCDB/WCDB.h>


@interface Message (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(localID)
WCDB_PROPERTY(content)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(modifiedTime)

@end
