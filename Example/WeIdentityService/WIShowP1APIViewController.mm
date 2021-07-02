//
//  WIShowP1ViewController.m
//  WeIdentityService_Example
//
//  Created by lssong on 2020/11/11.
//  Copyright © 2020 shoutanxie@gmail.com. All rights reserved.
//

#import "WIShowP1APIViewController.h"
#import "WIDBPersistence.h"
#import <WCDB/WCDB.h>
#import "Message.h"
#import "Message+WCTTableCoding.h"
#import <objc/runtime.h>
#import "WIKVPersistence.h"
#import "WICredential.h"
#import "WICredentialService.h"
#import "WICredential+WCTTableCoding.h"
#import "WIKeychainPersistence.h"
#import "WIRestoration.h"
#import "WICryptoUtils.h"

@interface WIShowP1APIViewController (){
    WCTDatabase *database;
}

@property (nonatomic, strong) WIDBPersistence *persistence;

@end

@implementation WIShowP1APIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 验证后台的Credentials
    [self testCredentialsVerfy];
    
    // 测试 存取文件
//    [self testSaveDataWithFile];
    
    // 测试KeyChain的存储
//    [self testKeyChainBatchAdd];
//    [self removeKeyChainItemByDomain];
    
//    [self testKeyChainStorage];
    // 测试加密数据库或者非加密数据库
//    [self testDB];
    // 测试Credentials
//    [self testCredentials];
}

#pragma mark 测试 存取文件
-(void) testCredentialsVerfy{
   /*
    context=https://github.com/WeBankFinTech/WeIdentity/blob/master/context/v1,

     id=f82a1e6a-90c0-4a2e-be7f-4fa60cb202b5,
    cptId=1000,
    issuer=did:weid:199:0x2391cb82a4a79ba0806f9dff06bee0eb6f360cd8,

     issuanceDate=1612236666,
    expirationDate=1613779200,

     claim={end_date=2021-02-15 00:00:00, stamp_images=[assets/images/Demo_Cap.png, assets/images/Demo_Coat.png, assets/images/Demo_Shoes.png, assets/images/Demo_Tie.png], stamp_card_address=0x6dc9961bbf7c8a15bdb264dabca3070fac25c20d, label=XML PET 2, issuer_name=Cat Is Here, issuer_name_zh=貓在這裡, issuer_id=4, issuer_did=did:weid:199:0x2391cb82a4a79ba0806f9dff06bee0eb6f360cd8, stamp_card_image=assets/images/card_bgd_1_0.5x.png, stamp_card_logo=, last_redemption_date=2021-02-20 00:00:00, credential_id=, start_date=2021-02-01 00:00:00, status=ACTIVE},

    proof={type=Secp256k1, signatureValue=OuZqzOVGP6GD9W3FFtjz48HgWS4LwA8aaZZ+zwFoJ6co7zWJI02zqx4gCbxz9ev5Bgganeo1vGjXjE8dzcYDlwE=},

     type=[VerifiableCredential, lite1])
    */
    WICredential *credential = [[WICredential alloc] init];
    
//    credential.f = @"wrw";
   
    credential.context = @"https://github.com/WeBankFinTech/WeIdentity/blob/master/context/v1";
    credential.id =@"f82a1e6a-90c0-4a2e-be7f-4fa60cb202b5";
    credential.cptId = 100;
    credential.issuer =@"did:weid:199:0x2391cb82a4a79ba0806f9dff06bee0eb6f360cd8";
    
    credential.issuanceDate = 1612236666;
    
    credential.expirationDate=1613779200;
    credential.claim= @{@"end_date":@"2021-02-15 00:00:00",
                        @"stamp_images":@[@"assets/images/Demo_Cap.png", @"assets/images/Demo_Coat.png", @"assets/images/Demo_Shoes.png", @"assets/images/Demo_Tie.png"],
                        @"stamp_card_address":@"0x6dc9961bbf7c8a15bdb264dabca3070fac25c20d",
                        @"label":@"XML PET 2",
                        @"issuer_name":@"Cat Is Here",
                        @"issuer_name_zh":@"貓在這裡",
                        @"issuer_id":@4,
                        @"issuer_did":@"did:weid:199:0x2391cb82a4a79ba0806f9dff06bee0eb6f360cd8",
                        @"stamp_card_image":@"assets/images/card_bgd_1_0.5x.png",
                        @"stamp_card_logo":[NSNull null],
                        @"last_redemption_date":@"2021-02-20 00:00:00",
                        @"credential_id":[NSNull null],
                        @"start_date":@"2021-02-01 00:00:00",
                        @"status":@"ACTIVE"
                        
    };
    credential.proof = @{@"type":@"Secp256k1",
                         @"signatureValue":@"OuZqzOVGP6GD9W3FFtjz48HgWS4LwA8aaZZ+zwFoJ6co7zWJI02zqx4gCbxz9ev5Bgganeo1vGjXjE8dzcYDlwE="};
    credential.type = @"lite1";
    
    BOOL res = [WICryptoUtils wedprSecp256k1VerifySign:@"4y126U1dBlrANKMa9VoJEUHGItXqH/kSbc2mfT09am0S8Y1npSrmBPY6xO/ucB3GuWCRwPtRn2hdbW12xo2s9g==" message:[credential getHash] signature:@"OuZqzOVGP6GD9W3FFtjz48HgWS4LwA8aaZZ+zwFoJ6co7zWJI02zqx4gCbxz9ev5Bgganeo1vGjXjE8dzcYDlwE="];
    NSLog(@"验证结果：%@",res);
}


#pragma mark 测试 存取文件
-(void) testSaveDataWithFile{
//    NSLog(@"开始写如数据。");
//    WIRestoration *restoration = [WIRestoration new];
//    [restoration exportCredentialList:@"todo" restorePwd:@"todo" destFilePath:@"filePath"];
//    NSLog(@"写文件完成。\n开始读取文件");
//    [restoration restoreCredentialListByFile:@"todo" restorePwd:@"todo" destFilePath:@"filePath"];
//    NSLog(@"读取完成。");
//    
}

#pragma mark 测试 WICredential
//-(void)testCredentials{
//    self.persistence = [WIDBPersistence persistenceWithDomain:@"credential" cipherKey:nil];
//    [self testCredentialBatchAdd];
//    [self testAddCredential];
//    [self testFindCredential];
//    [self testUpdateCredential];
//    NSLog(@"更新之后再查找");
//    [self testFindCredential];
////    [self testDeleteCrential];
//    NSLog(@"删除之后再查找");
//    [self testFindCredential];
//
//}

-(void) testAddCredential{
     
    WICredential *credential = [[WICredential alloc] init];
    credential.issuer =@"wq";
//    credential.f = @"wrw";
    credential.claim= @{@"key":@2};
//    credential.context = @"fsdg";
//    credential.credentialId = @"1234";
    credential.expirationDate=132244;
    credential.issuanceDate = 23435345;
    credential.issuer = @"sdfsdf";
//    credential.proof = @"werade";
//    credential.type = @[@"detsv",@3];
    credential.cptId = 1;
    [self.persistence add:credential];
    
    credential.issuer =@"wq";
//    credential.f = @"wrw";
    credential.claim= @{@"key":@2};
//    credential.context = @"fsdg";
//    credential.credentialId = @"1235";
    credential.expirationDate=132244;
    credential.issuanceDate = 23435345;
    credential.issuer = @"sdfsdf";
//    credential.proof = @"werade";
//    credential.type = @[@"detsv",@3];
    credential.cptId = 2;
    [self.persistence add:credential];
}

-(void) testCredentialBatchAdd{
    NSMutableArray *objects = [NSMutableArray array];
    WICredential *credential = [[WICredential alloc] init];
    credential.issuer =@"wq";
//    credential.f = @"wrw";
    credential.claim= @{@"key":@2};
//    credential.context = @"fsdg";
//    credential.credentialId = @"1234";
    credential.expirationDate=132244;
    credential.issuanceDate = 23435345;
    credential.issuer = @"sdfsdf";
//    credential.proof = @"werade";
//    credential.type = @[@"detsv",@3];
    credential.cptId = 1;
    
    [objects addObject:credential];
    
    WICredential *cre = [[WICredential alloc] init];
    cre.issuer =@"1";
//    cre.f = @"2";
    cre.claim= @{@"key":@2};
//    cre.context = @"3";
//    cre.credentialId = @"4";
    cre.expirationDate=5;
    cre.issuanceDate = 6;
    cre.issuer = @"7";
//    cre.proof = @"8";
//    cre.type = @[@"detsv",@3];
    cre.cptId = 2;
    [objects addObject:cre];
    [self.persistence batchAdd:objects];
}
-(void) testFindCredential{
    NSArray * arr =  [self.persistence get:WICredential.class
                    where:WICredential.cptId.isNotNull()
                  orderBy:WICredential.issuanceDate.order(WCTOrderedAscending)
                    num:1000
                 index:0];
    for (WICredential *cre in arr) {
        NSLog(@"find reslut:%@", [cre dictionaryValue]);
    }
}

-(void) testUpdateCredential{
    WICredential *credential= [WICredential new];
//    credential.context = @" after update";
//    [self.persistence update:WICredential.class
//                             onProperty:WICredential.context
//                             withObject:credential
//                                  where: WICredential.cptId ==1];
}

-(void) testDeleteCrential{
    BOOL success;
    success = [self.persistence
               deleteObjectsOfClass:WICredential.class
                              where:WICredential.cptId == @"2"
                              num:1000
                              index:0];
    NSLog(@"delete result:%d",success);
}


#pragma mark - DB Test Code
-(void) testDB{
//    self.persistence = [WIDBPersistence persistenceWithDomain:@"message" cipherKey:nil];
//    
////    [self testBatchAdd];
//    [self testSellectAll];
////    [self testDelete];
//    [self testADD];
//    [self testUpdate];
//    [self testSelect];
//    [self testDelete];
//    [self testSellectAll];
}

- (void) testADD{
    for (int i = 0; i < 300; i++) {
        [self.persistence add:[self generateTestMsg]];
    }
    [self testSellectAll];
}

- (void) testSellectAll{
    [self.persistence get:Message.class
                    where:Message.content.isNotNull()
                  orderBy:Message.localID.order(WCTOrderedAscending)
                      num:1000
                    index:0];
}
- (void) testSelect{
    // 查询所有 content不为空的数据
    NSLog(@">>>>>>>>>> Select createTime == 999");
    [self.persistence get:Message.class
                    where:Message.createTime == 999
                  orderBy:Message.localID.order(WCTOrderedAscending)
                      num:1000
                    index:0];
}

- (void) testUpdate{
    NSLog(@">>>>>>>>>> Update createTime from 1 to 999");
    // 数据更新,
    Message *msg = [self generateTestMsg];
    msg.createTime = 888;
    [self.persistence update:Message.class
                  onProperty:Message.createTime
                  withObject:msg
                       where:Message.createTime == 2];
    [self testSellectAll];
}

- (void)testDelete{
     [self testSellectAll];
    NSLog(@">>>>>>>>>> Delete localID 为奇数的数据");
    [self.persistence deleteObjectsOfClass:Message.class
                                     where:Message.localID % 2 == 1
                                     num:1000
                                     index:0];
    [self testSellectAll];
}


- (Message *)generateTestMsg{
    Message *message = [[Message alloc] init];
    message.localID = arc4random()%100;
    message.content = [NSString stringWithFormat:@"Hello-%ld",time(NULL)];;
    message.createTime   = arc4random()%3;
    message.modifiedTime = [[NSDate alloc] init];
    return message;
}

#pragma mark 测试KeyChain。

-(void) removeKeyChainItemByDomain{
    // 查询domai
    
    NSDictionary *dic = @{@"11weId":@"22lo公司",@"33bank1":@"44东方闪电",@"55sdg":@"66ertee"};
    WIKeychainPersistence *pers = [WIKeychainPersistence keyChainPersistenceWithDomain:@"w77"];
    int success = [pers batchAdd:dic];
    
    WIKeychainPersistence *pers1 = [WIKeychainPersistence keyChainPersistenceWithDomain:@"i77"];
    success = [pers1 batchAdd:dic];
    NSLog(@"添加数据之前查询w77：%@",[pers getByDomain:@"w77"]);
    NSLog(@"添加数据之前查询i77：%@",[pers getByDomain:@"i77"]);
    
    [pers deleteKeyChainPersistenceWithDomain:@"w77"];
    NSLog(@"删除w77后查询：%@",[pers getByDomain:@"w77"]);
    
    [pers1 deleteItem:@"11weId"];
    NSLog(@"删除一条数据的i77：%@",[pers1 getByDomain:@"i77"]);
    NSLog(@"添加数据之前查询i77：%@",[pers1 getByDomain:@"i77"]);
    [pers1 deleteKeyChainPersistenceWithDomain:@"i77"];
    
    NSLog(@"删除后查询w77：%@",[pers getByDomain:@"w77"]);
    NSLog(@"删除后查询i77：%@",[pers1 getByDomain:@"i77"]);
}


-(NSMutableDictionary *) setStoreAtrribution{
    /** 字典每个key的含义
     // 构建一个存取条件，指明存储的是秘钥
     // 指定秘钥的加密算法。
     // 指定存储的是私钥
     // 指定该秘钥的访问权限，只有在解锁的时候才能够访问
     // 指定key的size
     // 指定key可以解码
     // 指定key可以编码
     */
    NSDictionary *keychainItems = @{
        (id)kSecClass : (id)kSecClassKey,
        (id)kSecAttrAccessible : (id)kSecAttrAccessibleWhenUnlocked,
        (id)kSecAttrKeyType : (id)kSecAttrKeyTypeEC,
        (id)kSecAttrKeyClass : (id)kSecAttrKeyClassPrivate,
        (id)kSecAttrKeySizeInBits : @(256),
        (id)kSecAttrCanDecrypt:(id)kCFBooleanTrue,
        (id)kSecAttrCanEncrypt:(id)kCFBooleanTrue
    };
    return keychainItems.mutableCopy;
}

-(void) testKeyChainStorage{
    WIKeychainPersistence *pers = [WIKeychainPersistence keyChainPersistenceWithDomain:@"i77"];
     [pers add:@"dd" data:@"sasf3"];
    for(int i = 0 ; i < 3 ;i++){
        NSString *result = nil;
          BOOL success ;
          success = [pers add:@"lusong" data:@"sasfs发丰的123"];
          if(success){
              NSLog(@"insert success.");
          }else{
              NSLog(@"insert failure.");
          }
          
          
          result = [pers get:@"lusong"];
          NSLog(@"find result: %@", result);
          
          success = [pers update:@"lusong" data:@"fsfssfs胜多负少的是防辐射！！~~"];
          
          if(success){
              NSLog(@"update success.");
          }else{
              NSLog(@"update failure.");
          }
          result = [pers get:@"lusong"];
          NSLog(@"update result: %@", result);
          
          success = [pers deleteItem:@"lusong"];
          if(success){
              NSLog(@"delete success.");
          }else{
              NSLog(@"delete failure.");
          }
          result = [pers get:@"lusong"];
          NSLog(@"after deleter to find, its result is %@", result);
    }
  
}

-(void) testKeyChainBatchAdd{
    NSDictionary *dic = @{@"11weId":@"22lo公司",@"33bank1":@"44东方闪电",@"55sdg":@"66ertee"};
    WIKeychainPersistence *pers = [WIKeychainPersistence keyChainPersistenceWithDomain:@"w77"];
    int success = [pers batchAdd:dic];

    NSLog(@"批量添加的结果%d", success);
    NSString *result=nil;
    result = [pers get:@"weId"];
    NSLog(@"batchAdd result: %@", result);
    
    result = [pers get:@"bank1"];
    NSLog(@"batchAdd result: %@", result);
    
}
- (void)testInsertStringToDB{
    WIKVPersistence *pers = [WIKVPersistence persistenceWithDomain:@"message" cipherKey:nil];
    [pers deleteAll];
    for (int i = 0; i < 100; i++) {
        NSString *domain = [NSString stringWithFormat:@"domain-%d",i/10];
        NSString *itemID = [NSString stringWithFormat:@"index-%d",i % 10];
        NSString *obj = [NSString stringWithFormat:@"obj-%d",i];
        [pers add:domain itemId:itemID data:obj];
    }
    
    NSLog(@">>>>>");
    NSString*item1 = [pers get:@"domain-0" itemId:@"index-0"];
    NSString*item2 = [pers get:@"domain-5" itemId:@"index-5"];
    NSString*item3 = [pers get:@"domain-9" itemId:@"index-9"];
    NSLog(@"item1:%@",item1);
    NSLog(@"item2:%@",item2);
    NSLog(@"item3:%@",item3);
}
@end

