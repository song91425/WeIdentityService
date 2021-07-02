//  WITestAPIViewController.m
//  WeIdentityService_Example
//
//  Created by lssong on 2020/10/27.
//  Copyright © 2020 shoutanxie@gmail.com. All rights reserved.
//

#import "WITestAPIViewController.h"
#import "WIBAC004AssetService.h"
#import "SortDictionaryByKeys.h"
#import "WIJsonfromArrDict.h"
#import "WIWeIdentityService.h"
#import "WICryptoUtils.h"
#import "WICredentialService.h"
#import "CocoaSecurity.h"
#import "WIEvidenceService.h"
#import "BatchCreateEvidenceArg.h"

static WIKeyPairModel * keyPairs;
static WICredential *credential;
@interface WITestAPIViewController ()
@property(nonatomic,strong) UITextView *text;

@end


@implementation WITestAPIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    keyPairs = [WICryptoUtils generateKeyPair];
    NSLog(@"所属组：%ld，所在行：%ld",self.indexPath.section,self.indexPath.item);
    switch (self.indexPath.section) {
        case 0:
            [self testPayment:self.indexPath.item];
            break;
        case 1:
            [self testWeId:self.indexPath.item];
            break;
        case 2:
            [self testCredential:self.indexPath.item];
            break;
        case 3:
            [self testEvidence:self.indexPath.item];
            break;
        default:
            break;
    }
    
}

-(void) initView{
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    text.allowsEditingTextAttributes= false;
    [text setFont:[UIFont systemFontOfSize:12 weight:0.2]];
    self.text = text;
    [self.view addSubview:text];
    
}

-(void) testEvidence:(NSInteger) index{
    switch (index) {
           case 0:
           {
               WIEvidenceService *evidence = [WIEvidenceService new];
               credential = [self createCredential];
               [evidence createEvidenceWithHash:[credential getHash] sign:[credential getSignature] log:@"zcxv" callback:^(int status, BOOL succeed, NSError * error) {
                   if (succeed) {
                       [self showText:@"createEvidenceWithHash" model:@"success" error:nil];
                   }else{
                       [self showText:@"createEvidenceWithHash" model:nil error:error];
                   }
               }];
               
              break;
           }
           case 1:
           {
                WIEvidenceService *evidence = [WIEvidenceService new];
               [self createCredential];
               [evidence createEvidenceWithCredential:credential log:@"dgsd" callback:^(int status, BOOL succeed, NSError * error) {
                   if (succeed) {
                       [self showText:@"createEvidenceWithCredential" model:@"success" error:nil];
                   }else{
                       [self showText:@"createEvidenceWithCredential" model:nil error:error];
                   }
               }];
               
               break;
           }
           case 2:
           {
               WIEvidenceService *evidence = [WIEvidenceService new];
               credential = [self createCredential];
               BatchCreateEvidenceArg *arg = [BatchCreateEvidenceArg new];
               arg.hash  = [credential getHash];
               arg.sign = [credential getSignature];
               arg.log = @"change args";
               
               [evidence createEvidenceBatchWithArr:@[arg] callback:^(int status, BOOL succeed, NSError * error) {
                   if (succeed) {
                       [self showText:@"createEvidenceBatchWithArr" model:@"success" error:nil];
                   }else{
                       [self showText:@"createEvidenceBatchWithArr" model:nil error:error];
                   }
               }];
               break;
           }
           case 3:
           {
              WIEvidenceService *evidence = [WIEvidenceService new];
               credential = [self createCredential];
               [evidence getEvidence:[credential getHash] callback:^(BOOL succeed, WIEvidence * evidence, NSError *  error) {
                   if (succeed) {
                       [self showText:@"getEvidence" model:evidence error:nil];
                   }else{
                      [self showText:@"getEvidence" model:nil error:error];
                   }
               }];
               
            break;
           }
           default:
               break;
       }
}

-(void) testCredential:(NSInteger) index{
    switch (index) {
        case 0:
        {
            credential = [self createCredential];
            if (credential != nil) {
                 [self showText:@"createCredentialWithType" model:credential error:nil];
            }else{
                NSLog(@"createCredentialWithType invoke failure.");
            }
           break;
        }

        case 1:
        {
            credential = [self createCredential];
            BOOL result = [[WICredentialService sharedService] verify:credential
                                                  issuerWeIdPublicKey:keyPairs.publicKey];
            if (result) {
                [self showText:@"verify:issuerWeIdPublicKey:" model:@"True" error:nil];
            }else{
                [self showText:@"verify:issuerWeIdPublicKey:" model:@"验证不通过" error:nil];
            }
            break;
        }
        case 2:
        {
            NSString *issuerWeId = [self __base64EncodeString:@"did:weid:1000:0xce00282e71bcce84146d7489baf17cf3783febe7"];
            issuerWeId = [self __hexStringFromBase64String:issuerWeId];
            [[WICredentialService sharedService] verify:credential issuerWeId:issuerWeId
                  callback:^(BOOL succeed, NSError *  error) {
                if (succeed) {
                    [self showText:@"verify:issuerWeId:" model:@"True" error:nil];
                }else{
                    [self showText:@"verify:issuerWeId:" model:@"验证不通过" error:nil];
                }
            }];
            break;
        }
//        case 3:
//        {
//            credential = [self createCredential];
//            [[WICredentialService sharedService] verify:credential issuerWeId:@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38" issuerWeIdKeyId:@"did:weid:1000:0x4a7061e04270c27e9a2a31cc8fb92084432b4eaf" callback:^(int status, BOOL succeed, NSError * error) {
//                if (succeed) {
//                    [self showText:@"verify:issuerWeId:" model:@"True" error:nil];
//                }else{
//                    [self showText:@"verify:issuerWeId:" model:@"验证不通过" error:nil];
//                }
//            }];
//            break;
//        }
        default:
            break;
    }
}

-(WICredential *) createCredential{
    return  [[WICredentialService sharedService]
     createCredentialWithType:@"1001"
     cptId:2000001
     issuerWeId:@"did:weid:1000:0xce00282e71bcce84146d7489baf17cf3783febe7"
     WIKeyPair:keyPairs claim:@{
        @"branchWeId" : @"did:weid:1000:0x0915fe22505b6dde2d80d79a2a3e7e779ddc0308",
        @"extra" : @"sss"
    }
     expirationDate:12
     issuanceDate:14
     credentialId:@"fb71e9c4-0d17-4f2a-b0c1-b88ed23d5227" ];
}

-(void) testWeId:(NSInteger) index{
    switch (index) {
        case 0:
        {   // 不需要传公钥
            [[WIWeIdentityService sharedService] createWeIdWithKeyPair:[WICryptoUtils generateKeyPair]  publicKeyRSA:@"NO" callback:^(BOOL succeed, NSString * weid, NSError * error) {
                if (succeed) {
                    [self showText:@"createWeIdWithPubKey" model:weid error:nil];
                }else{
                    [self showText:@"createWeIdWithPubKey" model:nil error:error];
                }
            }];
           break;
        }
        case 1:
        {
            [[WIWeIdentityService sharedService] createWeIdWithInvokerWeId:@"admin" callback:^(BOOL succeed, NSString *  weid, NSError * error) {
                if (succeed) {
                    [self showText:@"createWeIdWithInvokerWeId" model:weid error:nil];
                }else{
                    [self showText:@"createWeIdWithInvokerWeId" model:nil error:error];
                }
            }];
            break;
        }
        case 2:
        {
            // weid did:weid:298:0xffa9a0e4c79950cd2264db070196950b473d4f11
            [[WIWeIdentityService sharedService] getWIDocumentByWeId:@"did:weid:1000:0xf2e21810448dd19ab9f1d6e2453ab16152c4ace9" callback:^(BOOL succeed, WIDocument * document, NSError * error) {
                if (succeed) {
                    [self showText:@"getWIDocumentByWeId" model:[NSString stringWithFormat:@"id=%@,\n 持有者owner：%@, \n公钥publicKey:%@",document.id, document.publicKey.firstObject.owner,document.publicKey.firstObject.publicKey] error:nil];
                }else{
                    [self showText:@"getWIDocumentByWeId" model:nil error:error];
                }
            }];
            break;
        }
        default:
            break;
    }
}
-(void )testPayment:(NSInteger) index{
    WIBAC004AssetService *bAC004AssetService = [WIBAC004AssetService new];
    switch (index) {
        case 0:
        {
            //invokerWeId:
            //              did:weid:1000:0x4a7061e04270c27e9a2a31cc8fb92084432b4eaf
            //              did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38
            //              did:weid:1000:0x33c2e104d29b0c21710709697057aaa96d4efccb
            //assetAddress:
            //             0x9e1d963be79e5121480ccc3823f484ad6c542d2e
            //             0xbc6132187c3ac2e2a53e1cef54b5d234c71e6f1c
           //              0x7e3655657a67b3eed864a4a18108abd0f83c049b
            
            [bAC004AssetService
                                construct:@"did:weid:1000:0x33c2e104d29b0c21710709697057aaa96d4efccb"
                                WIKeyPair:[WICryptoUtils generateKeyPair] shortName:@"RMB"
                              description:@"人民币"
                                 callback:^(BOOL succeed, NSString * assetAddress, NSError * error) {
                if (succeed) {
                    [self showText:@"construct" model:assetAddress  error:nil];
                }else{
                    [self showText:@"construct" model:nil error:error];
                }
            }];
            break;
        }
        
        case 1:
        {
            // recipient:did:weid:1000:0x9f19ebd1bdc7b8f7eaeeedb6f2a296ad47d4f47a
            //         (case 0的第一个生成的weid)
            // issue: @"0x7e3655657a67b3eed864a4a18108abd0f83c049b"
            //         (case 0的第三个生成的weid返回结果的合约地址address)
            //invokerWeId:@"did:weid:1000:0x33c2e104d29b0c21710709697057aaa96d4efccb"
            //         (case 0的第三个生成的weid)
            // case 0 第三个weid先生成一个合约地址，使用这个地址，然后在给第一个weid发送资产

            [bAC004AssetService  issue:@"did:weid:1000:0x33c2e104d29b0c21710709697057aaa96d4efccb"
                            WIKeyPair:[WICryptoUtils generateKeyPair]
                         assetAddress:@"0x7e3655657a67b3eed864a4a18108abd0f83c049b"
                            recipient:@"did:weid:1000:0x9f19ebd1bdc7b8f7eaeeedb6f2a296ad47d4f47a"
                               amount:1000
                                 data:@""
                             callback:^(BOOL succeed, NSError * error) {
                if (succeed) {
                    [self showText:@"getBalance" model:@"true"  error:nil];
                }else{
                    [self showText:@"getBalance" model:nil error:error];
                }
            }];
            break;
        }
        
        case 2:
        {
            // case 0 经过case 1 让第一个让did:weid:1000:0x4a7061e04270c27e9a2a31cc8fb92084432b4eaf拥有1000，资产，现在让did:weid:1000:0x4a7061e04270c27e9a2a31cc8fb92084432b4eaf给did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38发送100个资产。成功返回合约地址0x6ee56272a7894f07592956017ea03eab5db6b065（每次交易都不一样，这是某一次合约地址）
            [bAC004AssetService constructAndIssue:@"did:weid:1000:0x4a7061e04270c27e9a2a31cc8fb92084432b4eaf"
                                        WIKeyPair:[WICryptoUtils generateKeyPair]
                                        shortName:@"RMB" description:@"人民币"
                                        recipient:@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38"
                                           amount:10
                                             data:@""
                                         callback:^(BOOL succeed, NSString * assetAddress, NSError * _Nonnull error) {
                if (succeed) {
                    [self showText:@"constructAndIssue" model:assetAddress  error:nil];
                }else{
                    [self showText:@"constructAndIssue" model:nil error:error];
                }
            }];
            break;
        }
            
            
        case 3:
        {
            // 根据weid：did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38查询合约地址0x6ee56272a7894f07592956017ea03eab5db6b065的资产，
            [bAC004AssetService getBalance:@"0x6ee56272a7894f07592956017ea03eab5db6b065" userWeId:@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38" callback:^(BOOL succeed, WIAssetBalanceModel * _Nonnull model, NSError * _Nonnull error) {
                if (succeed) {
                    [self showText:@"getBalance" model:model  error:nil];
                }else{
                    [self showText:@"getBalance" model:nil error:error];
                }
            }];
            break;
        }
        case 4:
        {
            // 根据weid：did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c3查它的多个合约地址@[@"0xabf4ffc12eff2d9353983d81876c0ea8483aa976", @"0x36ad1d7341c05dadffd6158ae38ffd2233957e6b"]的资产
            [bAC004AssetService getBatchBalance:@[@"0xabf4ffc12eff2d9353983d81876c0ea8483aa976", @"0x36ad1d7341c05dadffd6158ae38ffd2233957e6b"] userWeId:@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38" callback:^(BOOL succeed, NSArray<WIAssetBalanceModel *> * _Nonnull models, NSError * _Nonnull error) {
                if (succeed) {
                    [self showText:@"getBatchBalance" model:models error:nil];
                }else{
                    [self showText:@"getBatchBalance" model:nil error:error];
                }
            }];
            
            break;
        }
        case 5:
        {
            [bAC004AssetService
              getBalanceByWeId:@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38"
                         index:0
                      pageSize:10
                      callback:^(BOOL succeed, NSArray<WIAssetBalanceModel *> * _Nonnull models, NSError * _Nonnull error) {
                if (succeed) {
                    [self showText:@"getBalanceByWeId" model:models error:nil];
                }else{
                    [self showText:@"getBalanceByWeId" model:nil error:error];
                }
            }];
            break;
        }
        case 6:
        {
            // 资产持有者，@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38"，持有资产地址：0x8b3d2a1ed894c2f1358f9bb938a3d82e8390ac8f，把资产发给did:weid:1000:0x4a7061e04270c27e9a2a31cc8fb92084432b4eaf
            WISendAssetArgsModel *model = [WISendAssetArgsModel new];
            [model setRecipient:@"did:weid:1000:0x4a7061e04270c27e9a2a31cc8fb92084432b4eaf"];
            [model setAmount:1];
            [model setRemark:@"房租"];
            
            [bAC004AssetService
                send:@"0xabf4ffc12eff2d9353983d81876c0ea8483aa976"
            userWeId:@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38"
           WIKeyPair:[WICryptoUtils generateKeyPair]
         invokerWeId:@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38"
       sendAssetArgs:model
            callback:^(BOOL succeed, NSError * _Nonnull error) {
                if (succeed) {
                    [self showText:@"send" model:@"发送成功true" error:nil];
                }else{
                    [self showText:@"send" model:nil error:error];
                }
            }];
            break;
        }
        case 7:
        {
            NSMutableArray *array = [NSMutableArray array];
            for (int i=0; i<1; i++) {
                WISendAssetArgsModel *model = [WISendAssetArgsModel new];
                [model setRecipient:@"did:weid:1000:0x4a7061e04270c27e9a2a31cc8fb92084432b4eaf"];
                [model setAmount:1];
                [model setRemark:@"房租232"];
                [array addObject:model];
            }
            
            [bAC004AssetService batchSend:@"0xabf4ffc12eff2d9353983d81876c0ea8483aa976"
                                 userWeId:@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38"
                                WIKeyPair:[WICryptoUtils generateKeyPair]
                              invokerWeId:@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38"
                            sendAssetArgs:array callback:^(BOOL succeed, NSArray<WISendAssetResponseModel *> * _Nonnull models, NSError * _Nonnull error) {
                if (succeed) {
                    [self showText:@"batchSend" model:models error:nil];
                }else{
                    [self showText:@"batchSend" model:nil error:error];
                }
            }];
            break;
        }
        case 8:
        {
            [bAC004AssetService getBaseInfo:@[@"0xabf4ffc12eff2d9353983d81876c0ea8483aa976", @"0x36ad1d7341c05dadffd6158ae38ffd2233957e6b",@"0x9e1d963be79e5121480ccc3823f484ad6c542d2e"] callback:^(BOOL succeed, NSArray<WIBAC004AssetModel *> * _Nonnull models, NSError * _Nonnull error) {
                if (succeed) {
                    [self showText:@"getBaseInfo" model:models error:nil];
                }else{
                    [self showText:@"getBaseInfo" model:nil error:error];
                }
            }];
            break;
        }
        case 9:
        {
            // 有效weid：did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38
            //          did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38
            [bAC004AssetService
                getBaseInfoByWeId:@"did:weid:1000:0x526dd03eba496e1ea62ceca3532d14fd78a11c38"
                           index:0
                        pageSize:10
                        callback:^(BOOL succeed, NSArray<WIBAC004AssetModel *> * _Nonnull models, NSError * _Nonnull error) {
                if (succeed) {
                    [self showText:@"getBaseInfoByWeId" model:models error:nil];
                }else{
                    [self showText:@"getBaseInfoByWeId" model:nil error:error];
                }
            }];
            break;
        }
            
        default:
            break;
    }
}


-(void) showText:(NSString *) apiName model:(id) model error:(NSError *) error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error!=nil) {
            self.text.text = [NSString stringWithFormat:@"接口%@调用失败！\n失败原因是:%@",apiName, error];
        }else{
            NSString *temp;
            if([model isKindOfClass:[NSString class]]){
                temp = model;
            }else{
                temp = [WIJsonfromArrDict jsonStringFromArrDic:model];
            }
            self.text.text =[NSString stringWithFormat:@"接口%@调用成功！\n返回结果是:%@",apiName,temp];
        }
    });
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma 编码成16进制


- (NSString *)__base64EncodeString:(NSString *)string{
    NSLog(@"%s",__func__);
    NSLog(@"string:%@",string);
    NSData *data = [self __dataFromHexString:string];
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    return base64;
}

- (NSData *)__dataFromHexString:(NSString *)originalHexString{
    NSString *hexString = [originalHexString stringByReplacingOccurrencesOfString:@"[ <>]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [originalHexString length])]; // strip out spaces (between every four bytes), "<" (at the start) and ">" (at the end)
    NSMutableData *data = [NSMutableData dataWithCapacity:[hexString length] / 2];
    for (NSInteger i = 0; i < [hexString length]; i += 2){
        NSString *hexChar = [hexString substringWithRange: NSMakeRange(i, 2)];
        int value;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        uint8_t byte = value;
        [data appendBytes:&byte length:1];
    }
    return data;
}


- (NSString *)__hexStringFromBase64String:(NSString *)base64{
    CocoaSecurityDecoder *decoder = [CocoaSecurityDecoder new];
    NSData *myD = [decoder base64:base64];
    
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
//    NSLog(@"base 64:%@",base64);
//    NSLog(@"hex    :%@",hexStr);
    return hexStr;
        
}
@end
