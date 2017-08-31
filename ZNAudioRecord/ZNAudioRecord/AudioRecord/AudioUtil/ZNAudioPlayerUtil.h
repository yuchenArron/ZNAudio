//
//  ZNAudioPlayerUtil.h
//  ZNAudioRecord
//
//  Created by mac on 2017/8/31.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZNAudioPlayerUtil : NSObject

//播放一组网络音频文件
+ (void)playAudios:(NSArray<NSString*>*)audioArr;

//暂停播放
+ (void)pausePlayer;
//恢复播放
+ (void)resumePlayer;

@end
