//
//  WeIdDocument.m
//  HKard
//
//  Created by Junqi on 2020/9/8.
//  Copyright © 2020 tank. All rights reserved.
//

#import "WIDocument.h"
#import "YYModel.h"
#import "WICryptoUtils.h"
#import "WISDKLog.h"

@implementation WIDocument

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"publicKey":[WIDocumentPublicKey class],
             @"authentication":[WIDocumentAuthentication class]
    };
}

+ (instancetype) fromJson:(NSString*)weIdDocumentJson{
    WIDocument *document = [WIDocument yy_modelWithJSON:weIdDocumentJson];
    return document;
}

-(NSString *)getKeyId{
    NSArray *arr = [self.id componentsSeparatedByString:@"#"];
    NSString *keyId = [[arr[1] componentsSeparatedByString:@"-"] objectAtIndex:1];
    NSAssert(keyId != nil, @"WIDocument invalid public id");
    return keyId;
}

/**
 publicKey =  (
        {
         id = "did:weid:101:0xf45e693097c41afda2743afa50b9d7ed8fcc54c5#keys-0";
         owner = "did:weid:101:0xf45e693097c41afda2743afa50b9d7ed8fcc54c5";
         publicKey = "vLzKyo8PD9HR0dEEBMnJyS8hISEGDg4OCgp6enp6enrMr0JCvg8PD68NDQ0=";
         revoked = 0;
         type = Secp256k1;
     }
 );
 */
- (WIDocumentPublicKey *)getPublicKeyByKeyId:(NSString *)keyId;{
    for (WIDocumentPublicKey *model in self.publicKey) {
        if ([keyId isEqualToString:[model getKeyId]]) {
            return model;
        }
    }
    return nil;
}

- (NSString *)getKeyIdByPublicKey:(NSString *)hexPubKey isHexDocument:(BOOL)isHex{
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"%@",hexPubKey);
    
    for (WIDocumentPublicKey *model in self.publicKey) {
        NSString* hex = nil;
        if (!isHex) {
            // 后台返回的结果, document 中都是 B64 String
            hex = [WICryptoUtils hexStringFromB64String:model.publicKey];
            
        }else{
            // document 中是 hex string
            hex = model.publicKey;
        }
        if(WISDKLog.sharedInstance.printLog){
            NSLog(@"%@",model.publicKey);
            NSLog(@"%@",hex);
        }
        if ([hex isEqualToString:hexPubKey]) {
            NSString *keyId = [model getKeyId];
            return keyId;
        }
    }
    return nil;
}

-(NSString*) toJson{
    return  [self yy_modelToJSONString];
}
@end


//{
//    errorCode = 0;
//    errorMessage = success;
//    loopback = "<null>";
//    respBody =     {
//        "@context" = "https://github.com/WeBankFinTech/WeIdentity/blob/master/context/v1";
//        authentication =         (
//                        {
//                publicKey = "did:weid:101:0xf45e693097c41afda2743afa50b9d7ed8fcc54c5#keys-0";
//                revoked = 0;
//                type = Secp256k1;
//            }
//        );
//        created = 1609845240;
//        id = "did:weid:101:0xf45e693097c41afda2743afa50b9d7ed8fcc54c5";
//        publicKey =         (
//                        {
//                id = "did:weid:101:0xf45e693097c41afda2743afa50b9d7ed8fcc54c5#keys-0";
//                owner = "did:weid:101:0xf45e693097c41afda2743afa50b9d7ed8fcc54c5";
//                publicKey = "vLzKyo8PD9HR0dEEBMnJyS8hISEGDg4OCgp6enp6enrMr0JCvg8PD68NDQ0=";
//                revoked = 0;
//                type = Secp256k1;
//            }
//        );
//        service =         (
//        );
//        updated = "<null>";
//    };
//}
