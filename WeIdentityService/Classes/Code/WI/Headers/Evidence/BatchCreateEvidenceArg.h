//
//  BatchCreateEvidenceArg.h
//  Pods
//
//  Created by lssong on 2020/11/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BatchCreateEvidenceArg : NSObject
@property (nonatomic, copy) NSString *hash;
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, copy) NSString *log;

@end

NS_ASSUME_NONNULL_END
