
//
//  ZNAudioRecordTools.m
//  ZNAudioRecord
//
//  Created by mac on 2017/8/30.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#import "ZNAudioRecordTools.h"


#define RecordCurrentTotalCountKey(userName)  [NSString stringWithFormat:@"%@%@",userName,@"RecordCurrentTotalCountKey"]

@implementation ZNAudioRecordTools

+ (NSString *)timeStringWithTimerCount:(NSInteger)count{
    NSInteger hour = 0;
    NSInteger min = 0;
    NSInteger second = 0;
    
    hour = count / 60 / 60;
    min = (count - hour * 60) / 60;
    second = count % 60;
    
    if (hour > 0) {
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
