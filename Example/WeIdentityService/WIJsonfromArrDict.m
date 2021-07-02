//
//  WIJsonfromArrDict.m
//  WeIdentityService_Example
//
//  Created by lssong on 2020/10/27.
//  Copyright © 2020 shoutanxie@gmail.com. All rights reserved.
//

#import "WIJsonfromArrDict.h"
#import "WIBaseModel.h"
#import "WISDKLog.h"
@implementation WIJsonfromArrDict

+ (NSString *)jsonStringFromArrDic:(id)model{
    
    NSString *jsonString=@"";
    if([model isKindOfClass:[NSArray class]]){
        for (WIBaseModel *m in model) {
            jsonString = [jsonString stringByAppendingFormat:@"%@", [WIJsonfromArrDict __jsonStringFromModel:[m dictionaryValue]]];
        }
    }else{
         jsonString = [jsonString stringByAppendingFormat:@"%@", [WIJsonfromArrDict __jsonStringFromModel:[model dictionaryValue]]];
    }
    if(WISDKLog.sharedInstance.printLog){
        NSLog(@"解析model得到的结果：%@",jsonString);
    }
    return jsonString;
}

+(NSString *) __jsonStringFromModel:(WIBaseModel *) model{
    NSError *error = nil;
    NSData *jsonData ;
     NSString *jsonString;
    if (@available(iOS 11.0, *)) {
        if(WISDKLog.sharedInstance.printLog){
            NSLog(@"开始转json************");
        }
        jsonData = [NSJSONSerialization dataWithJSONObject:model options:NSJSONWritingSortedKeys error:&error];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        if(WISDKLog.sharedInstance.printLog){
            NSLog(@"开始转json");
        }
        jsonData = [NSJSONSerialization dataWithJSONObject:model options:0 error:&error];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
@end
