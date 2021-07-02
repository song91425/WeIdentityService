//
//  WIViewController.m
//  WeIdentityService
//
//  Created by shoutanxie@gmail.com on 09/11/2020.
//  Copyright (c) 2020 shoutanxie@gmail.com. All rights reserved.
//

#import "WIViewController.h"
#import "WIShowP1APIViewController.h"
#import "WIShowP0APIViewController.h"

#import "WIHDWalletUtils.h"
#import "WIHDWallet.h"
#import "WIManager.h"
#import "WIWeIdentityService.h"
#import "WICryptoUtils.h"

#import "WICredentialService.h"

#import "WIKeychainPersistence.h"

#import "WIHDWalletUtils.h"

#import <CommonCrypto/CommonDigest.h>
#import "WISDKLog.h"

#import "WIWalletManager.h"


@interface WIViewController ()

@property (nonatomic, strong)WeIdInfo *info;
@end

@implementation WIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //   设置是否输出log
    WISDKLog.sharedInstance.printLog = NO;
    
    [[NSUserDefaults standardUserDefaults] setInteger:12 forKey:@"xxxx"];
    NSInteger value = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xxxx"] intValue];
    
    id value1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"x"];
    
    [WISDKLog log:__FUNCTION__ desc:@"xxxxxxxxx" argKeys:@[@"KEY1",@"KEY2"] argValues:@[@"VALUE1",@"VALUE2"]];
}
- (IBAction)skipToP0API:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainP0" bundle:[NSBundle mainBundle]];
    WIShowP0APIViewController *vc = [story instantiateViewControllerWithIdentifier:@"WIShowP0APIViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
    
    
}
- (IBAction)skipToP1API:(id)sender {
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainP1" bundle:[NSBundle mainBundle]];
//    WIShowP1APIViewController *vc = [story instantiateViewControllerWithIdentifier:@"WIShowP1APIViewController"];
//    [self.navigationController pushViewController:vc animated:YES];
    
    
    WIKeychainPersistence *per = [WIKeychainPersistence keyChainPersistenceWithDomain:@"_wi_wallet"];
//    [per clearKeyChain];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"wallet_status"];
    
    WIWalletManager *manager = [WIWalletManager manager];
    NSString* current = [manager getCurrentWallet];
    
    for (int i = 0; i < 10; i++) {
        NSString *current = [NSString stringWithFormat:@"_wi_wallet_%d",i];
        NSArray *test = [per getByDomain:current].allKeys;
        NSLog(@"%@:%@",current,test);
    }
    
    
    
    NSDictionary *userdefault = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSLog(@"userdefaults:%@",userdefault);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
}


- (NSData *)dataFromHexString:(NSString *)hexStr{
    if (hexStr.length%2 != 0) {
        return nil;
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    for (int i = 0 ; i<hexStr.length/2; i++) {
        NSString *str = [hexStr substringWithRange:NSMakeRange(i*2,2)];
        NSScanner *scanner = [NSScanner scannerWithString:str];
        int intValue;
        [scanner scanInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

//- (void)test{
//    WIKeyPair *keyPair = [WICryptoUtils generateKeyPair];
//    NSString *pubKey = [keyPair publicKeyString];
//    NSString *hexP = [WICryptoUtils hexStringFromString:@"xxxxxxxxx"];
//    NSString *res = [WICryptoUtils eciesSecp256k1Encrypt:pubKey hexPlainText:hexP];
//    NSLog(@"||||>>>>>>>>>%@",pubKey);
//    NSLog(@"||||>>>>>>>>>%@",hexP);
//    NSLog(@"||||>>>>>>>>>%@",res);
//    NSLog(@"||||>>>>>>>>>dddddd");
//}


- (void)testInitWallet{
//    WIKeychainPersistence *per = [WIKeychainPersistence keyChainPersistenceWithDomain:@"_wi_wallet"];
//    [per clearKeyChain];
    
   
}

//
-(void)testCWeid{
    
    if (self.info) {
        NSLog(@"有 info......");
        [self testCredential:self.info.weId keyId:self.info.keyId];
    }else{
        NSLog(@"没有 info......");
       
    }

   
}

-(void)testGetCredential{
    WICredentialService *service = [WICredentialService sharedService];
    [service getCredentialById:@"46E0C811-30DD-4D31-A35F-160852034027"
                      callback:^(BOOL getSuccess, WICredential * _Nonnull cr1, NSString * _Nonnull msg1) {
        if (getSuccess) {
            NSLog(@"get成功\n%@",cr1);
        }else{
            NSLog(@"get失败");
        }
    }];
    
}

//"566C9146-C879-466D-86D6-A9F5FEE101D7:",
//"FA0AB595-7008-40F8-8C39-09C7CD81DFEA:did:weid:101:0x39492816b7f064167a9ce9efdb743fff557aa944",
- (void)testCredential:(NSString *)weid keyId:(NSString *)keyId{

    WICredentialService *service = [WICredentialService sharedService];
    [service createCredentialWithCptId:102
                        credentialType:@"type"
                            issuerWeId:weid
                                 keyId:keyId
                              transPwd:@"456"
                          issuanceDate:(int)time(NULL)
                        expirationDate:(int)time(NULL)
                                 claim:@{
                                     @"q":@"ddd",
                                     @"c":@"ddd"
                                 }
                              callback:^(BOOL success, WICredential * credential, NSString * _Nonnull msg) {
        if (success) {
            NSLog(@"create 成功");
            [service saveCredential:credential
                           callback:^(BOOL s, NSString * _Nonnull m) {
                NSLog(@"========>seve res\nweid:%@\nkeyid:%@\ncredential:%@",weid,keyId,[credential toJson]);
                if (s) {
                    NSLog(@"save成功");
                    
                    [service getCredentialById:credential.id
                                      callback:^(BOOL getSuccess, WICredential * _Nonnull cr1, NSString * _Nonnull msg1) {
                        if (success) {
                            NSLog(@"get成功");
                        }else{
                            NSLog(@"get失败");
                        }
                    }];
                }else{
                    NSLog(@"save失败");
                }
            }];
        }else{
            NSLog(@"create 失败");
        }
        
    }];
}


- (void)testCrypt:(WIKeyPairModel *)keyPair{
    NSString *pubKeyB64 = [keyPair publicKeyString];
    NSString *priKeyB64 = [keyPair privateKeyString];
    
    NSString *hash2 = [WICryptoUtils hashTwice:@"xxxxxx"];
    NSString *res = [WICryptoUtils eciesSecp256k1Encrypt:[WICryptoUtils hexStringFromB64String:pubKeyB64] hexPlainText:hash2];
    NSString *res1 = [WICryptoUtils eciesSecp256k1Decrypt:[WICryptoUtils hexStringFromB64String:priKeyB64] hexCipherText:res];
    
    NSLog(@">>>>>>>>>>>>>>>|||||||%@",hash2);
    NSLog(@">>>>>>>>>>>>>>>|||||||%@",res);
    NSLog(@">>>>>>>>>>>>>>>|||||||%@",res1);
}

//
//private_key:3p9Ngpvxl9WbyWjI/D1e3kSAJVrMN+FfAGqEOtHawwE=
//public_key:BDVL7abVtOl6kCQWgIMr+AHBNValR/vvOkifrmfaJqDDylhz3RPd68kzVI2y0NxyVDt86qYA1uk/Su2mt1eIzbA=
//普通字符串转换为十六进制的。
   
- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

- (NSData *)dataFromHexadecimalString:(NSString*)hex
{
    // in case the hexadecimal string is from `NSData` description method (or `stringWithFormat`), eliminate
    // any spaces, `<` or `>` characters

    NSString *hexadecimalString = [hex stringByReplacingOccurrencesOfString:@"[ <>]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [hex length])];

    NSMutableData * data = [NSMutableData dataWithCapacity:[hexadecimalString length] / 2];
    for (NSInteger i = 0; i < [hexadecimalString length]; i += 2) {
        NSString *hexChar = [hexadecimalString substringWithRange: NSMakeRange(i, 2)];
        int value;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        uint8_t byte = value;
        NSLog(@">>>>> %@",hexChar);
        [data appendBytes:&byte length:1];
    }

    return data;
}

- (void)testB64ToHex{
    //    ===key pair===
    //    private_key:X6C3BwYBqkbQpNwWYv/R3QFKxX1U9xVHX8PYhIZwQXQ=
    //    public_key:BLBn/sKn6l8EQfnXJVmqYHP0LeYUok1wlz0NFT8WWlwG1lafesGzpRzISmCyOxGjDaGdjtF2gyouj+sWRTmRQb8=
        
        NSString *b64 = @"BLBn/sKn6l8EQfnXJVmqYHP0LeYUok1wlz0NFT8WWlwG1lafesGzpRzISmCyOxGjDaGdjtF2gyouj+sWRTmRQb8=";
        int padding = fmod([b64 length], 4);
        if (padding == 1) {
            b64 = [NSString stringWithFormat:@"%@===",b64];
        }else if (padding == 2) {
            b64 = [NSString stringWithFormat:@"%@==",b64];
        }else if (padding == 3) {
            b64 = [NSString stringWithFormat:@"%@=",b64];
        }
        NSString *hex = [WICryptoUtils hexStringFromB64String:b64];
        NSString *bb = [WICryptoUtils b64StringFromHexString:hex];


        NSLog(@"b64:%@",b64);
        NSLog(@"hex:%@",hex);
        NSLog(@" bb:%@",bb);
        
}

@end

