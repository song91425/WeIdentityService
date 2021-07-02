//
//  WIShowP0APIViewController.m
//  WeIdentityService_Example
//
//  Created by lssong on 2020/11/11.
//  Copyright © 2020 shoutanxie@gmail.com. All rights reserved.
//

#import "WIShowP0APIViewController.h"
#import "WITestAPIViewController.h"
#import "WIConfig.h"

#import "WIHDWallet.h"
#import "WIManager.h"

#import "WIWeIdentityService.h"
#import "WICredentialService.h"
#import "WIEvidenceService.h"

#import "WIBAC004AssetService.h"
#import "WIRestoration.h"
#import "WICryptoUtils.h"
#import "WISortDictionaryByKeys.h"
#import "WIBAC005AssetService.h"
@interface WIShowP0APIViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, copy) NSDictionary *data;
@property(nonatomic, copy) NSArray *header;

@property (nonatomic, copy) NSString *unlockPwd;
@property (nonatomic, copy) NSString *transPwd;
@property (nonatomic, copy) NSString *restorePwd;

@property (nonatomic, copy) NSString *weId;
@property (nonatomic, copy) NSString *keyId;
@property (nonatomic, copy) NSString *credentialId;

@property (nonatomic, assign) BOOL isWalletInited;

@end

@implementation WIShowP0APIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initView];
    // 验证后台的Credentials
    [self testCredentialsVerfy];
    [self testLocalInfo];
    // 初始化钱包
    [self initWallet];
    
    
    
}

#pragma mark 测试 存取文件
-(void) testCredentialsVerfy{
    WICredential *credential = [[WICredential alloc] init];
    //    credential.context = @"https://github.com/WeBankFinTech/WeIdentity/blob/master/context/v1";
    credential.id =@"071671e1-1995-4f30-b3c3-b5b103bc1694";
    credential.cptId = 1000;
    credential.issuer =@"did:weid:199:0x2391cb82a4a79ba0806f9dff06bee0eb6f360cd8";
    
    credential.issuanceDate = 1612344201;
    
    credential.expirationDate=1613779200;
    credential.claim= @{
        @"credential_id":@"071671e1-1995-4f30-b3c3-b5b103bc1694",
        @"end_date":@"2021-02-15 00:00:00",
        @"issuer_did":@"did:weid:199:0x2391cb82a4a79ba0806f9dff06bee0eb6f360cd8",
        @"issuer_id":@4,
        @"issuer_name":@"Cat Is Here",
        @"issuer_name_zh":@"貓在這裡",
        @"label":@"XML PET 2",
        @"last_redemption_date":@"2021-02-20 00:00:00",
        @"stamp_card_address":@"0x47124defe8a83c2845ab5790470c526c1d03fb25",
        @"stamp_card_image":@"assets/images/card_bgd_1_0.5x.png",
        @"stamp_card_logo":@"assets/images/card_dflt_logo_0.5x.png",
        @"stamp_images":@[
                         @"assets/images/Demo_Cap.png",
                         @"assets/images/Demo_Coat.png",
                         @"assets/images/Demo_Shoes.png",
                         @"assets/images/Demo_Tie.png"
                        ],
        @"start_date":@"2021-02-01 00:00:00",
        @"status":@"ACTIVE"
    };
    credential.proof = @{@"proof":@"2z5lL9f3xMRLm2nDhaM59GwrJsTN6JOAWeupBnhuveYpktBl86F+t9sZxLIaVbncOb0CZWE1F9dZawBFS8a9TQE="};
    credential.type = @"lite1";
//    credential.f=@"1";
    NSString *hash = [credential  getHash];
    NSString *sign = [credential getSignature];
    
    NSString *publicKey = @"4y126U1dBlrANKMa9VoJEUHGItXqH/kSbc2mfT09am0S8Y1npSrmBPY6xO/ucB3GuWCRwPtRn2hdbW12xo2s9g==";
    BOOL res = [WICryptoUtils wedprSecp256k1VerifySign:@"04120b47e6e6770c0aca74ceb16a78e13ab1604587bbc723cde78f3dc803ae17a085ddefa17dd448bad47cc6b65f41dde29ac7c17d977050ab2f7a43654ce699c8"
                                               message:@"e009bb50220c7dabb5d4ba14295bf736f30cf132ff2e0dcc802ae3e3935bae0f"
                                             signature:[WICryptoUtils hexStringFromString:@"4y126U1dBlrANKMa9VoJEUHGItXqH/kSbc2mfT09am0S8Y1npSrmBPY6xO/ucB3GuWCRwPtRn2hdbW12xo2s9g=="]];
    //    BOOL res = [WICryptoUtils wedprSecp256k1VerifySign:[WICryptoUtils hexStringFromB64String:publicKey]
    //                                               message:message
    //                                             signature:[WICryptoUtils hexStringFromString:signature]];
    NSLog(@"验证结果：%d",res);
}

-(void) testLocalInfo{
    WIKeyPairModel * keypair = [WICryptoUtils generateKeyPair];
    NSString *msg = [WICryptoUtils wedpr_keccak256:@"12345" isHex:NO];
    NSString *sign = [WICryptoUtils wedprCryptoSecp256k1Sign:keypair.privateKey.privateKey message:msg];
    BOOL res= [WICryptoUtils wedprSecp256k1VerifySign:keypair.publicKey.publicKey message:msg signature:sign];
    NSLog(@"%d",res);
    
}

-(void) initWallet{
    // 初始化 wallet
    WIHDWallet *wallet = [WIHDWallet sharedInstance];
    [wallet initHDWallet:self.unlockPwd callback:^(BOOL res, NSError * error) {
        self.isWalletInited = res;
        if (res) {
            NSLog(@"init succeed.");
            [WIManager managerWithName:@"weid.managerdomain" encryptDB:YES callback:^(WIManager * manager, NSError * err) {
                if (err) {
                    NSLog(@"err: %@",err);
                }
            }];
            //                [WIManager managerWithName:@"weid.managerdomain" encryptDB:YES];
        }else{
            NSLog(@"init failed.");
        }
    }];
    
    WIConfig *config = [WIConfig SDKConfig];
    [config setWeIdURL:@"http://18.166.65.175:6001/weid/api/invoke"];
    [config setBac004URL:@"http://18.166.65.175:6001/payment/bac004/api/invoke"];
    [WIConfig SDKConfig].bac005URL=@"https://www.baidu.com";
}
- (void)configSDK{
    WIConfig *config = [WIConfig SDKConfig];
    [config setRequestType:WISDKRequestWeIDBySDK];
    //    [[WIConfig SDKConfig] setRequestURL:@"http://18.166.65.175:6001/weid/api/invoke"];
}

-(void) initData{
    
    self.unlockPwd = @"123";
    self.transPwd = @"456";
    self.restorePwd = @"789";
    self.data = @{@"== PayMent ==":@[@"construct",
                                     @"issue",
                                     @"constructAndIssue",
                                     @"getBalance",
                                     @"getBatchBalance",
                                     @"getBalanceByWeId",
                                     @"send",
                                     @"batchSend",
                                     @"getBaseInfo",
                                     @"getBaseInfoByWeId",
                                     @"bac005_queryOwnedAssetList",
                                     @"bac005_send",
                                     @"bac005_batchSend"],
                  @"== WeId ==":@[@"create weid",
                                  @"create credential && save",
                                  @"get credential && create Evidence",
                                  @"create evidence.",
                                  @"constructAndIssue",
                                  @"getBalance",
                                  @"transfer"],
                  
                  @"== 导入导出 ==":@[@"文件-钱包导出 && 导入",
                                  @"通过助记词-钱包导出 && 导入",
                                  @"credential 导出 && 导入",
                                  @"钱包 && credential 导出导入",
                                  @"打印 NSUserDefault",
                                  @"打印 key chain"],
                  @"== Evidence ==":@[@"createEvidenceWithHash:sign:log",
                                      @"createEvidenceWithCredential:log",
                                      @"createEvidenceBatchWithArr",
                                      @"getEvidence"
                  ]
    };
    self.header = @[@"== PayMent ==",@"== WeId ==",@"== 导入导出 ==",@"== Evidence =="];
}
-(void) initView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.isWalletInited) {
        NSLog(@"============> ERROR Wallet init failed.");
        return ;
    }
    
    if(indexPath.section == 0){
        // weid
        switch (indexPath.row) {
            case 0:
            {
                // create weid
                [self __test_createWeID];
                break;
            }
            case 1:
            {
                // create credential
                [self __test_createCredentialAndSave];
                break;
            }
            case 2:
                [self __test_getCredentialAndCreateEvidence];
                break;
            case 3:
            {
                [self __test3];
                break;
            }
            case 10:
            {
                [self __test_queryOwnedAssetList];
                break;
            }
            case 11:
            {
                [self __test3];
                break;
            }
            case 12:
            {
                [self __test3];
                break;
            }
            default:
                break;
        }
    }else if(indexPath.section == 1){
        // weid
        switch (indexPath.row) {
            case 0:
            {
                // create weid
                [self __test_createWeID];
                break;
            }
            case 1:
            {
                // create credential
                [self __test_createCredentialAndSave];
                break;
            }
            case 2:
                [self __test_getCredentialAndCreateEvidence];
                break;
            case 3:
            {
                [self __test3];
                break;
            }
            default:
                break;
        }
        
    }else if(indexPath.section == 2){
        // 导入导出
        switch (indexPath.row) {
            case 0:
                // 钱包导入导出
                //                [self __test_wallet_restoration];
                break;
                
            case 1:
                // credential 导入导出
                //                [self __test1];
                break;
            case 2:
                // 钱包 && credential 导入导出
                [self __test2];
                break;
            default:
                break;
        }
        
        
    }else if(indexPath.section == 3){
        
    }
    //    WITestAPIViewController *vc = [WITestAPIViewController new];
    //    vc.indexPath = indexPath;
    //    [self.navigationController pushViewController:vc animated:YES];
    NSLog(@"你点击了%ld",indexPath.item);
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.data.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *arr =self.data[self.header[section]];
    NSInteger rows = arr.count;
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell  *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSArray *arr =self.data[self.header[indexPath.section]];
    NSString *text = arr[indexPath.item];
    cell.textLabel.text = text;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.header[section];
}


/*
 - (void)__test_wallet_restoration_1{
 WIHDWallet *wallet = [WIHDWallet sharedInstance];
 BOOL res = [wallet initHDWallet:self.unlockPwd];
 if (res) {
 NSLog(@"==>init wallet succees.");
 NSString *fileName = [NSString stringWithFormat:@"wi-hdwallet-%d-%ld",arc4random()%1000,time(NULL)];
 
 [wallet exportRestorationFile:fileName restorePwd:self.restorePwd callback:^(BOOL success, NSString * _Nonnull msg) {
 //TODO: 从文件中读取助记词
 }];
 }else{
 NSLog(@"==>init wallet failed.");
 }
 }
 
 - (void)__test_wallet_restoration{
 WIHDWallet *wallet = [WIHDWallet sharedInstance];
 BOOL res = [wallet initHDWallet:self.unlockPwd];
 if (res) {
 NSLog(@"==>init wallet succees.");
 NSString *fileName = [NSString stringWithFormat:@"wi-hdwallet-%d-%ld",arc4random()%1000,time(NULL)];
 
 [wallet exportRestorationFile:fileName restorePwd:self.restorePwd callback:^(BOOL success, NSString * _Nonnull msg) {
 NSLog(@"res msg:%@",msg);
 if (success) {
 NSLog(@"export to file success.\npath:%@",msg);
 BOOL res1 = [wallet initHDWalletWithFile:msg
 restorePwd:self.restorePwd
 unlockPwd:self.unlockPwd];
 if (res1) {
 NSLog(@"init wallet success.");
 
 }else{
 NSLog(@"init wallet failed.");
 }
 }else{
 NSLog(@"export to file failed.\npath:%@",msg);
 }
 }];
 }else{
 NSLog(@"==>init wallet failed.");
 }
 }
 */
- (void)__test_createWeID{
    [self test_createWeID:^(BOOL success, WeIdInfo *info, NSError *error) {
        // 创建 weid 成功
        if (success) {
            NSLog(@"创建 weid 成功.");
            [[NSUserDefaults standardUserDefaults] setObject:info.weId forKey:@"weid"];
            [[NSUserDefaults standardUserDefaults] setObject:info.keyId forKey:@"keyid"];
        }else{
            NSLog(@"创建 weid 失败.");
            NSLog(@"error:%@",error);
        }
    }];
}

- (void)__test_createCredentialAndSave{
    WICredentialService *service = [WICredentialService sharedService];
    for(int i = 0;i < 5;i++){
        [service createCredentialWithCptId:102
                            credentialType:@"type"
                                issuerWeId:self.weId
                                     keyId:self.keyId
                                  transPwd:self.transPwd
                              issuanceDate:(int)time(NULL)
                            expirationDate:(int)time(NULL)
                                     claim:@{
                                         @"q":@"ddd",
                                         @"c":@"ddd"
                                     }
                                  callback:^(BOOL success, WICredential * _Nonnull credential, NSString * _Nonnull msg) {
            if (success) {
                NSLog(@"create credential success.");
                self.credentialId = credential.id;
                [service saveCredential:credential callback:^(BOOL saveSuccess, NSString * _Nonnull saveMsg)  {
                    NSLog(@"msg:%@",saveMsg);
                    if (saveSuccess) {
                        NSLog(@"save credential success.");
                    }else{
                        NSLog(@"create credential success.");
                    }
                }];
            }else{
                NSLog(@"create credential failed.");
            }
        }];
    }
}

- (void)test_createWeID:(void(^)(BOOL,WeIdInfo *,NSError * ))callback{
    if (!self.weId) {
        [[WIWeIdentityService sharedService] createWeIdWithTransPwd:self.transPwd
                                                           callback:callback];
    }
}

- (void)__test_getCredentialAndCreateEvidence{
    if (self.credentialId == nil) {
        NSLog(@"credentialId = nil.");
        return;
    }
    [[WICredentialService sharedService] getCredentialById:self.credentialId
                                                  callback:^(BOOL success, WICredential * _Nonnull credential, NSString * _Nonnull res) {
        if (success) {
            NSLog(@"get credential 成功.\n%@",credential);
            WIHashInfo *info = [WIHashInfo new];
            info.sign = [credential getSignature];
            info.hash_ = [credential getHash];
            info.log = @"log";
            
            [[WIEvidenceService alloc] createEvidenceWithGroupId:2
                                                        hashInfo:info
                                                        callback:^(int status, BOOL succeed, NSError * _Nonnull error) {
                if (success) {
                    NSLog(@"create evidence success.");
                }else{
                    NSLog(@"create evidence failed.\nerror:%@",error);
                    
                }
                NSAssert(success, @"create evidence failed.");
            }];
        }else{
            NSLog(@"get credential 失败.");
        }
        NSAssert(success, @"get credential failed.");
    }];
}

- (void)__test2{
    //    [[WIRestoration new] exportCredentialList:<#(nonnull NSString *)#>
    //                                   restorePwd:<#(nonnull NSString *)#>
    //                                 destFilePath:<#(nonnull NSString *)#>
    //                                     callback:<#^(BOOL success, NSArray * _Nonnull credentials, NSString * _Nonnull filePath, NSString * _Nonnull errMsg)callback#>]
    
}

-(void) __test_queryOwnedAssetList{
    WIBAC005AssetService *service = [WIBAC005AssetService new];
    [service queryOwnedAssetList:@"wetw" assetHolder:@"sgdsg" index:0 num:2 callback:^(NSInteger code, NSArray<WIQueryOwnedAssetModel *> * _Nonnull result, NSError * _Nonnull error) {
       NSLog(@"%lu",code);
    }];
}

-(void) __test_send{
    WIBAC005AssetService *service = [WIBAC005AssetService new];
    WIBAC005SendArgsModel *model = [WIBAC005SendArgsModel new];
    [model setRecipient:@"dfdsfs"];
    [model setAssetId:104];
    [model setData:@"data"];
    [service send:@"sdfsdfsd" sendAssetArgs:nil callback:^(BOOL succeed, NSError * _Nonnull error) {
        NSLog(@"%d",succeed);
    }];
}

-(void) __test_batch_send{
    WIBAC005AssetService *service = [WIBAC005AssetService new];
    NSMutableArray *args = [NSMutableArray array];
    for (int i=0; i<2; i++) {
        WIBAC005SendArgsModel *model = [WIBAC005SendArgsModel new];
        [model setRecipient:@"dfdsfs"];
        [model setAssetId:100+i];
        [model setData:@"data"];
        [args addObject:model];
    }
    [service batchSend:@"sss" invokerWeid:@"fsd" sendAssetArgs:args  callback:^(BOOL succeed, NSError * _Nonnull error) {
        NSLog(@"%d",succeed);
    }];
}
- (void)__test3{
    if (!self.weId) {
        NSLog(@"请创建 weid.");
        return;
    }
    WIBAC004AssetService *service = [WIBAC004AssetService new];
    [service constructAndIssue:@"admin"
                         keyId:nil
                      transPwd:nil
                     shortName:@"RMB"
                   description:@"人民币"
                     recipient:self.weId
                        amount:100
                          data:nil
                      callback:^(BOOL succeed, NSString * _Nonnull assetAddress, NSError * _Nonnull error) {
        if (succeed) {
            NSLog(@"constructAndIssue succeed.");
            NSLog(@"%@",assetAddress);
            [service getBalance:assetAddress
                       userWeId:self.weId
                       callback:^(BOOL succ, WIAssetBalanceModel * _Nonnull model, NSError * _Nonnull error) {
                if (succ) {
                    NSLog(@"===> \nweid:%@\nassetAddress:%@\nbalance:%@",self.weId,assetAddress,model.balance);
                    WISendAssetArgsModel *model = [WISendAssetArgsModel new];
                    [model setRecipient:self.weId];
                    [model setAmount:10];
                    [model setRemark:@"房租"];
                    [service send:assetAddress
                         userWeId:self.weId
                            keyId:nil
                         transPwd:nil
                      invokerWeId:@"admin"
                    sendAssetArgs:model
                         callback:^(BOOL succeed, NSError * _Nonnull error) {
                        if (succeed) {
                            NSLog(@"send succees.");
                        }else{
                            NSLog(@"send error.");
                        }
                    }];
                }else{
                    NSLog(@"error:%@",error);
                }
            }];
        }else{
            NSLog(@"constructAndIssue failed.");
        }
    }];
    
    
}

- (NSString *)weId{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"weid"];
}

- (NSString *)keyId{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"keyid"];
}

@end
