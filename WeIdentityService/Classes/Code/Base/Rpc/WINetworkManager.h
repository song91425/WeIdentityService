//
//  WINetworkManager.h
//  WeIdentityService-WeIdentityService
//
//  Created by tank on 2020/9/22.
//

#import <Foundation/Foundation.h>
typedef NSString *WIFunctionName NS_EXTENSIBLE_STRING_ENUM;



NS_ASSUME_NONNULL_BEGIN

extern WIFunctionName const WIFunctionName_CreateWeIdWithPubKey;
extern WIFunctionName const WIFunctionName_GetWIDocument;
extern WIFunctionName const WIFunctionName_GetWIDocumentByOrgId;
extern WIFunctionName const WIFunctionName_GetEvidence;
extern WIFunctionName const WIFunctionName_DelegateCreateEvidence;
extern WIFunctionName const WIFunctionName_DelegateCreateEvidenceBatch;

# pragma Payment functionName
extern WIFunctionName const WIFunctionName_Construct;
extern WIFunctionName const WIFunctionName_Issue;
extern WIFunctionName const WIFunctionName_ConstructAndIssue;
extern WIFunctionName const WIFunctionName_GetBalance;
extern WIFunctionName const WIFunctionName_GetBatchBalance;
extern WIFunctionName const WIFunctionName_GetBalanceByWeId;
extern WIFunctionName const WIFunctionName_Send;
extern WIFunctionName const WIFunctionName_BatchSend;
extern WIFunctionName const WIFunctionName_GetBaseInfo;
extern WIFunctionName const WIFunctionName_GetBaseInfoByWeId;
extern WIFunctionName const WIFunctionName_GetWeIdListByPubKeyList;

#pragma Payment bac005 functionName
extern WIFunctionName const WIFunctionName_QueryOwnedAssetList;

@interface WINetworkManager : NSObject

+ (instancetype) manager;

@property (nonatomic, assign) int groupId;

- (void)requestWithFuncName:(WIFunctionName)functionName
                        url:(NSString *)url
                      param:(NSDictionary *)functionArgParam
                    success:(void (^)( id _Nullable))success
                    failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;

-(NSDictionary *)functionParam:(NSDictionary *)arg functionName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
