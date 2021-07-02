//
//  WISendAssetResponseModel.h
//  WeIdentityService
//
//  Created by tank on 2020/10/26.
//

#import "WIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WISendAssetResponseModel : WIBaseModel

@property (nonatomic, copy)NSString *recipient;
@property (nonatomic, copy)NSString *errorCode;
@property (nonatomic, assign)BOOL result;

@end

NS_ASSUME_NONNULL_END


//{
//    "respBody": [
//        {
//            "recipient": "0x16c8a21456d2d59061a1cefceb111fd76008a795",
//            "result": true,
//            "errorCode": "SUCCESS"
//        }
//    ],
//    "errorCode": 0,
//    "errorMessage": "success"
//}
