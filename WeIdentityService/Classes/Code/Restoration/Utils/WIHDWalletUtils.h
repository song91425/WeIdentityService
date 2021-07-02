//
//  WIHDWalletUtils.h
//  WeIdentityService
//
//  Created by tank on 2020/12/23.
//

#import <Foundation/Foundation.h>

#import "WIKeyPairModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WIHDWalletUtils : NSObject

+ (NSString *)wedpr_create_master_key:(NSString *)passwd mnemonic:(NSString *)mnemonic;

+ (NSString *)wedpr_hdw_create_mnemonic:(unsigned char )word_count;

+ (WIKeyPairModel *)wedpr_extended_key:(NSString *)master_key
                    purpose_type:(int)purpose_type
                       coin_type:(int)coin_type
                         account:(int)account
                          change:(int)change
                   address_index:(int)address_index;
@end

NS_ASSUME_NONNULL_END
