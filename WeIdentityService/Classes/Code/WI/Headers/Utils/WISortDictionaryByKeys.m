//
//  SortDictionaryByKeys.m
//  AFNetworking
//
//  Created by lssong on 2020/10/26.
//

#import "WISortDictionaryByKeys.h"
#import "WISDKLog.h"
@implementation WISortDictionaryByKeys

+(NSString*)jsonStringWithDict:(NSDictionary*)dict ascend:(NSString *)asc{
    
    NSArray*keys = [dict allKeys];
    if (keys.count==0) {
        return nil;
    }
    
    int flag=0;// 在拼接json的时候判断是不是字典来判断是不要双引号
    NSArray*sortedArray;
    NSString*str =@"{\"";// 拼接json的转换的结果
    
    // 自定义比较器来比较key的ASCII码
    sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
        return[obj1 compare:obj2 options:NSNumericSearch];//升序排序
    }];
    
    // 逐个取出key和value，然后拼接json
    for (int i=0; i<sortedArray.count; i++) {
        
        NSString *categoryId;
        
        if ([asc isEqualToString:@"YES"]) {// 升序排序
            categoryId = sortedArray[i];
        }else{ // 降序排序
            categoryId = sortedArray[sortedArray.count-1-i];
        }
        id value = [dict objectForKey:categoryId];
        
        if([value isKindOfClass:[NSDictionary class]]) {
            flag=1;
            value = [WISortDictionaryByKeys jsonStringWithDict:value ascend:asc];
        }
        
        // 拼接json串的分割符
        if([str length] !=2) {
            str = [str stringByAppendingString:@",\""];
        }
        // 对数组类型展开处理
        if([value isKindOfClass:[NSArray class]]){
            str = [str stringByAppendingFormat:@"%@\":[",categoryId];
            str = [WISortDictionaryByKeys sortInner:value jsonString:str];
            // 因为在 处理完数组类型后，json已经拼接好，直接拼接下一个串
            continue;
        }
        
        if (flag==1) {
            str = [str stringByAppendingFormat:@"%@\":%@",categoryId,value];
            flag=0;
        }else{
            if(![value isKindOfClass:[NSString class]]){// 如果是number类型，value不需要加双引号
                // 如果是BOOl类型则转化为false和true
                Class c = [value class];
                NSString * s = [NSString stringWithFormat:@"%@", c];
                if([s isEqualToString:@"__NSCFBoolean"]){
                    
                    if ([value isEqualToNumber:@YES]) {
                        str = [str stringByAppendingFormat:@"%@\":%@",categoryId,@"true"];
                        
                    }else{
                        str = [str stringByAppendingFormat:@"%@\":%@",categoryId,@"false"];
                    }
                }else{
                    str = [str stringByAppendingFormat:@"%@\":%@",categoryId,value];
                }
            }else{
                str = [str stringByAppendingFormat:@"%@\":\"%@\"",categoryId,value];
            }
        }
    }
    str = [str stringByAppendingString:@"}"];
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"str = %@", str);
    return str;
}

+(NSString *) sortInner:(NSArray *) array jsonString:(NSString *)json{
    NSString *string =@"";
    NSInteger location = 0;
    for (int i=0; i< array.count; i++) {
        
        if(i!=0&&i< array.count) {
            json = [json stringByAppendingString:@","];
        }
        
        id arr = [array objectAtIndex:i];
        if([arr isKindOfClass:[NSDictionary class]]){// 如果数组里包含字典，则对该字典递归排序
            location = i;
            string=[WISortDictionaryByKeys jsonStringWithDict:arr ascend:@"YES"];
            json = [json stringByAppendingFormat:@"%@",string];
        }else{
            if([arr isKindOfClass:[NSString class]]){
                json = [json stringByAppendingFormat:@"\"%@\"",arr];
            }else{
                // 如果是BOOl类型则转化为false和true
                Class c = [arr class];
                NSString * s = [NSString stringWithFormat:@"%@", c];
                if([s isEqualToString:@"__NSCFBoolean"]){
                    
                    if ([arr isEqualToNumber:@YES]) {
                        json = [json stringByAppendingFormat:@"%@",@"true"];
                        
                    }else{
                        json = [json stringByAppendingFormat:@"%@",@"false"];
                    }
                }else{
                    json = [json stringByAppendingFormat:@"%@",arr];
                }
                
            }
        }
    }
    
    json = [json stringByAppendingString:@"]"];
    return json;
}

+(NSString *) __jsonFromDic:(NSDictionary *)dict{
    if(WISDKLog.sharedInstance.printLog){
        NSLog(@"%s",__func__);
        NSLog(@"==> in %@",dict);
    }
    NSError *error = nil;
    
    NSData *jsonData ;
    NSString *jsonString ;
    
    if (@available(iOS 11.0, *)) {
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingSortedKeys error:&error];
        NSString *tempString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [tempString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    } else {
        // Fallback on earlier versions
        jsonString = [WISortDictionaryByKeys jsonStringWithDict:dict ascend:@"YES"];
    }
    
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"==> out %@",jsonString);
    return jsonString;
}

//转换分隔符
//-(NSDictionary *)__delete
@end
