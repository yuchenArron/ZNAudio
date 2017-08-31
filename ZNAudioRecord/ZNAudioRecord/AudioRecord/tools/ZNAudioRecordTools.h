//
//  ZNAudioRecordTools.h
//  ZNAudioRecord
//
//  Created by mac on 2017/8/30.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZNAudioRecordTools : NSObject

//计数  转时间字符串
+ (NSString*)timeStringWithTimerCount:(NSInteger)count;

//处理宕机的标记信息
+ (void)setCurrentTotalNumber:(NSInteger)number user:(NSString*)userName;
+ (NSInteger)getCurrentTotalNumberUser:(NSString*)userName;
//结束录音 清除标记信息
+ (void)clearRecordingMarkUserName:(NSString*)userName;

//拼接录音文件
+ (BOOL)pieceFileA:(NSString *)fileA
         withFileB:(NSString *)fileB;
//获取录音文件路径
+ (NSString*)filePathWithFileName:(NSString*)fileName;

+ (NSArray*)getAllFilesWithName;

@end
