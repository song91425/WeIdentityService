//
//  WIDocumentPublicKey.m
//  WeIdentityService
//
//  Created by tank on 2020/9/19.
//

#import "WIDocumentPublicKey.h"
#import "YYModel.h"

@implementation WIDocumentPublicKey

- (NSString *)getKeyId{
//    id = "did:weid:101:0xf45e693097c41afda2743afa50b9d7ed8fcc54c5#keys-0";
    NSArray *arr = [self.id componentsSeparatedByString:@"#"];
    if (arr && [arr isKindOfClass:[NSArray class]] && arr.count == 2) {
        NSString *keys = arr[1];
        
        NSArray *arr1 = [keys componentsSeparatedByString:@"-"];
        if (arr1 && [arr1 isKindOfClass:[NSArray class]] && arr1.count == 2) {
            NSString *keyId = arr1[1];
            return keyId;
        }
    }
    return nil;
}
@end
