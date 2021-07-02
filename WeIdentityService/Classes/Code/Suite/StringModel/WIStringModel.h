//
//  WIStringModel.h
//  WeIdentityService
//
//  Created by tank on 2020/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIStringModel : NSObject

//@property (nonatomic, copy) NSString *domain;
//@property (nonatomic, copy) NSString *itemID;
//@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;

+ (NSString *)generateKey:(NSString *)domain itemID:(NSString *)itemID;
-(instancetype)initWithDomain:(NSString*)domain itemID:(NSString *)itemID content:(NSString*)content;

@end

NS_ASSUME_NONNULL_END
