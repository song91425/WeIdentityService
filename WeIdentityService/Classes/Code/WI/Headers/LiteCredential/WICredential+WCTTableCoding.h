//
//  WICredential+WCTTableCoding.h
//  Pods
//
//  Created by lssong on 2020/11/12.
//

#import <WeIdentityService/WICredential.h>
//#import <WCDB/WCDB.h>

@interface WICredential (WCTTableCoding)<WCTTableCoding>

WCDB_PROPERTY(issuer)
//WCDB_PROPERTY(context)
WCDB_PROPERTY(claim)
WCDB_PROPERTY(cptId)
WCDB_PROPERTY(issuanceDate)
WCDB_PROPERTY(expirationDate)
WCDB_PROPERTY(f)
WCDB_PROPERTY(id)
WCDB_PROPERTY(proof)
WCDB_PROPERTY(type)

@end
