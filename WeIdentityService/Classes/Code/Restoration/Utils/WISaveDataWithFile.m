//
//  SaveStringWithFile.m
//  TestReadAndWriteFile
//
//  Created by lssong on 2021/1/7.
//  Copyright © 2021 龙绍松. All rights reserved.
//

#import "WISaveDataWithFile.h"
#import "WISDKLog.h"
@implementation WISaveDataWithFile

-(NSString *)writeContentWithFileName:(NSString *)fileName contentWithString:(NSString *) content{
    // 文件的完整路径
    NSString *filePath = [self getFilePath: fileName];
    // 判断给定的文件
    if(WISDKLog.sharedInstance.printLog)
        NSLog(@"文件路径：%@", filePath);
    // 创建文件
    if([self createFileWithPath:filePath]){
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if (fileHandle == nil) {
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"写入失败");
            return nil;
        }else{
            [fileHandle seekToEndOfFile];
            if ([self getFileSize:filePath]>0) {
                [fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle closeFile];
        }
    }
    return filePath;
}

-(NSString *) writeContentWithFileName:(NSString *)fileName contentWithArray:(NSArray *)content{
    NSString *filePath = [self getFilePath:fileName];
    NSError *error=nil;
    BOOL result=NO;
    if (@available(iOS 11.0, *)) {
        [content writeToURL:[NSURL fileURLWithPath:filePath] error:&error];
    }else{
        result = [content writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    }
    if (error == nil || result) {
        return  filePath;
    }
    return nil;
}

-(NSArray *)readContentWithFileName:(NSString *)filePath fileType:(FileType)type{
    if (filePath == nil) {
        return nil;
    }
    NSError *error= nil;
    NSArray *array =nil;
    switch (type) {
        case FileTypeString:
        {
            NSString *content = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:&error];
            if (error == nil) {
                // 读取成功，移除文件
                 array= [content componentsSeparatedByString:@"\n"];
            }
            break;
        }
        case FileTypeArray:
        {
            array = [[NSArray alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
            break;
        }
    }
    return array;
}

- (BOOL)deleteFile:(NSString *)path{
    if (path==nil) {
        return YES;
    }
    NSRange range =[path rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *fileName = [path substringFromIndex:range.location+1];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSError *error= nil;
        if([[NSFileManager defaultManager] removeItemAtPath:path error:&error]){
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"删除文件:%@，状态成功",fileName);
            return YES;
        }else{
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"删除文件:%@，状态失败",fileName);
            return NO;
        }
    }else{
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"在路径不存在该文件");
        return YES;
    }
}

// 给定文件名称
-(NSString *) getFilePath:(NSString *) fileName{
    // fileName 不为空，并去除左右空格
    if (fileName != nil &&[fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length>0 ) {
        return [[self getDomainPath] stringByAppendingPathComponent:fileName];
    }else{
        return [[self getDomainPath] stringByAppendingPathComponent:[self getCurrentTimeStringToMilliSecond]];
    }
}

// 得到当前时间相对1970时间的字符串，精度到毫秒，返回13位长度字符串
-(NSString *)getCurrentTimeStringToMilliSecond {
    double currentTime =  [[NSDate date] timeIntervalSince1970]*1000000;
    NSString *strTime = [NSString stringWithFormat:@"%.0f",currentTime];
    return strTime;

}

/// 获取录音文件存放的主目录，即获取~/Documents/wi-crdential路径
-(NSString *) getDomainPath{
    NSString * mainPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dic = [mainPath stringByAppendingPathComponent:@"wi-credentials"];
    bool isDirectory= YES;
    if(![[NSFileManager defaultManager] fileExistsAtPath:dic isDirectory:&isDirectory]){
        // 创建文件夹
        if(![[NSFileManager defaultManager] createDirectoryAtPath:dic withIntermediateDirectories:YES attributes:nil error:NULL]){
            // 创建文件夹失败
            return nil;
        }
    }
    return dic;
}

-(BOOL) createFileWithPath:(NSString *) path{
    // 如果文件存在不需要创建直接返回
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }else{
        return YES;
    }
}

-(long long) getFileSize:(NSString *) filePath{
   NSDictionary *dic =  [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
    if (dic.count>0) {
//        long size =(long)dic[NSFileSize];
        return [dic[NSFileSize] longLongValue];
    }else{
        return 0;
    }
}

// 删除文件夹和文件夹下面的所有文件
-(BOOL)deleteDirectory:(NSString *)dirPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:dirPath error:nil];
}
@end
