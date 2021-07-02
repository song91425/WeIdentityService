//
//  WIBaseModel.m
//  WeIdentityService
//
//  Created by tank on 2020/9/19.
//

#import "WIBaseModel.h"
#import <objc/runtime.h>

@implementation WIBaseModel

// model --> dictionary
- (NSDictionary *)dictionaryValue{
    NSArray *propertyKeys = [self __properties:self];
    NSDictionary *originDic = [self dictionaryWithValuesForKeys:propertyKeys];
    NSMutableDictionary *tmp = [NSMutableDictionary new];
    
    // Dictionary de duplication
    for (NSString *key in propertyKeys) {
        if (![originDic[key] isKindOfClass:[NSNull class]]) {
            if ([originDic[key] isKindOfClass:[WIBaseModel class]]) {
                tmp[key] = [(WIBaseModel *)originDic[key] dictionaryValue];
            }else if([originDic[key] isKindOfClass:[NSNumber class]] || [originDic[key] isKindOfClass:[NSString class]]|| [originDic[key] isKindOfClass:[NSDictionary class]]){
                //TODO: 重构======>>>>
                tmp[key] = originDic[key];
            }else{
                NSAssert(YES, @"HKBaseModel Parse Error");
            }
        }else{
            NSAssert(YES, @"HKBaseModel Parse Error, Empty Key.");
        }
    }
    return [NSDictionary dictionaryWithDictionary:tmp];
}

//TODO: Class object OK?
-(NSArray *)__properties:(id)obj{
    Class cls = [obj class];
    NSMutableArray *propertyKeys = [NSMutableArray array];
    while ([cls superclass]) {
        uint outCount ,i;
        objc_property_t *properties = class_copyPropertyList(cls, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char* propertyName = property_getName(property);
            if (propertyName) {
                [propertyKeys addObject:[NSString stringWithUTF8String:propertyName]];
            }
        }
        free(properties);
        cls = [cls superclass];
    }
    return [NSArray arrayWithArray:propertyKeys];
}


@end
