
//
//  ZNAudioRecordTools.m
//  ZNAudioRecord
//
//  Created by mac on 2017/8/30.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#import "ZNAudioRecordTools.h"


#define RecordCurrentTotalCountKey(userName)  [NSString stringWithFormat:@"%@%@",userName,@"RecordCurrentTotalCountKey"]

#define KFILESIZE (1 * 1024 * 1024)

@implementation ZNAudioRecordTools

+ (NSString *)timeStringWithTimerCount:(NSInteger)count{
    NSInteger hour = 0;
    NSInteger min = 0;
    NSInteger second = 0;
    
    hour = count / 60 / 60;
    min = (count - hour * 60) / 60;
    second = count % 60;
    
    if (1) {
        return [NSString stringWithFormat:@"%@:%@:%@",[ZNAudioRecordTools stringWithNumber:hour],[ZNAudioRecordTools stringWithNumber:min],[ZNAudioRecordTools stringWithNumber:second]];
    }else{
        return [NSString stringWithFormat:@"%@:%@",[ZNAudioRecordTools stringWithNumber:min],[ZNAudioRecordTools stringWithNumber:second]];
    }
}

+ (void)setCurrentTotalNumber:(NSInteger)number user:(NSString *)userName{
    [[NSUserDefaults standardUserDefaults] setValue:@(number) forKey:RecordCurrentTotalCountKey(userName)];
}

+ (NSInteger)getCurrentTotalNumberUser:(NSString *)userName{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:RecordCurrentTotalCountKey(userName)] integerValue];
}

+ (void)clearRecordingMarkUserName:(NSString *)userName{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:RecordCurrentTotalCountKey(userName)];
}

+ (NSString*)filePathWithFileName:(NSString*)fileName{
    NSString *recordPath = NSHomeDirectory();
    recordPath = [NSString stringWithFormat:@"%@/Library/appdata/%@.wav",recordPath,fileName];
    return recordPath;
}

+ (NSArray *)getAllFilesWithName{
    NSString *recordPath = NSHomeDirectory();
    recordPath = [NSString stringWithFormat:@"%@/Library/appdata/",recordPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileArr = [fileManager contentsOfDirectoryAtPath:recordPath error:nil];
   
    NSMutableArray *filePathArr = [NSMutableArray new];
    for (NSString *fileName in fileArr) {
        NSString *filePath = [recordPath stringByAppendingPathComponent:fileName];
        [filePathArr addObject:filePath];
    }
    return filePathArr;
}

+ (BOOL)pieceFileA:(NSString *)filePathA
         withFileB:(NSString *)filePathB
{
    
    NSString *pathA = [ZNAudioRecordTools filePathWithFileName:filePathA];
    NSString *pathB = [ZNAudioRecordTools filePathWithFileName:filePathB];
    
    // 更新的方式读取文件A
    NSFileHandle *handleA = [NSFileHandle fileHandleForUpdatingAtPath:pathA];
    [handleA seekToEndOfFile];
    
    NSDictionary *fileBDic = [[NSFileManager defaultManager] attributesOfItemAtPath:pathB error:nil];
    long long fileSizeB    = fileBDic.fileSize;
    
    // 大于xM分片拼接xM
    if (fileSizeB > KFILESIZE) {
        
        // 分片
        long long pieces = fileSizeB /KFILESIZE;   // 整片
        long long let    = fileSizeB %KFILESIZE;   // 剩余片
        
        long long sizes = pieces;
        // 有余数
        if (let > 0) {
            // 加多一片
            sizes += 1;
        }
        
        NSFileHandle *handleB = [NSFileHandle fileHandleForReadingAtPath:pathB];
        for (int i =0; i < sizes; i++) {
            
            [handleB seekToFileOffset:i * KFILESIZE];
            NSData *tmp = [handleB readDataOfLength:KFILESIZE];
            [handleA writeData:tmp];
        }
        
        [handleB synchronizeFile];
        
        // 大于xM分片读xM(最后一片可能小于xM)
    }else{
        
        [handleA writeData:[NSData dataWithContentsOfFile:pathB]];
        
    }
    
    [handleA synchronizeFile];
    
    // 将B文件删除
    [[NSFileManager defaultManager] removeItemAtPath:pathB error:nil];
    
    return YES;
}


#pragma mark - private methods
+ (NSString *)stringWithNumber:(NSInteger)number{
    NSString *str = [NSString stringWithFormat:@"%ld",number];
    if (str.length >= 2) {
        return str;
    }else{
        return [NSString stringWithFormat:@"0%@",str];
    }
}

@end
