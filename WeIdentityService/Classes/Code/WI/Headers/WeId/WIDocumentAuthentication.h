//
//  WIDocumentAuthentication.h
//  WeIdentityService
//
//  Created by tank on 2020/9/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIDocumentAuthentication : NSObject

@property (nonatomic, copy)NSString *publicKey;
@property (nonatomic, copy)NSString *type;
@property (nonatomic, assign)BOOL revoked;

@end

NS_ASSUME_NONNULL_END
