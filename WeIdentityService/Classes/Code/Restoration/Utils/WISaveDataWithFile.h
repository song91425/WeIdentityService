//
//  SaveStringWithFile.h
//  TestReadAndWriteFile
//
//  Created by lssong on 2021/1/7.
//  Copyright © 2021 龙绍松. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, FileType) {
    FileTypeString,
    FileTypeArray,
};

@interface WISaveDataWithFile : NSObject
/// 把字符串写入文件中
/// @param fileName 文件名称
/// @param content 写入文件的内容
/// @return 写入成功，返回写入文件路径，没有成功返回nil
-(NSString *) writeContentWithFileName:(NSString * _Nullable) fileName contentWithString:(NSString *) content;


/// 把数组写入文件中
/// @param fileName 文件名称
/// @param content 写入的数组内容
/// @return 写入成功，返回写入文件路径，没有成功返回nil
-(NSString *) writeContentWithFileName:(NSString *_Nullable)fileName contentWithArray:(NSArray *)content;

/// 读取文件内容
/// @param filePath 文件名称
/// @param type 读取类型
/// @return 读到内容非空，读取不到，返回为nil
-(NSArray *) readContentWithFileName:(NSString * _Nonnull) filePath fileType:(FileType) type;


///  根据指定路径删除文件
/// @param path  文件路径
- (BOOL)deleteFile:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
