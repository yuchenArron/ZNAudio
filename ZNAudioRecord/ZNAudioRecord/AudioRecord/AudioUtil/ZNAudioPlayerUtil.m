//
//  ZNAudioPlayerUtil.m
//  ZNAudioRecord
//
//  Created by mac on 2017/8/31.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#import "ZNAudioPlayerUtil.h"
#import <AVFoundation/AVFoundation.h>

@interface ZNAudioPlayerUtil()

@property (nonatomic, strong) AVQueuePlayer *queuePlayer;

@end

@implementation ZNAudioPlayerUtil

+ (instancetype)shareInstance{
    static ZNAudioPlayerUtil *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[ZNAudioPlayerUtil alloc]init];
    });
    return player;
}

+ (void)playAudios:(NSArray<NSString *> *)audioArr{
    ZNAudioPlayerUtil *audioPlayer = [ZNAudioPlayerUtil shareInstance];
    NSArray *items = [ZNAudioPlayerUtil playerItemsWithStr:audioArr];
    
    [audioPlayer clearQueuePlayer];
    
    [audioPlayer playItems:items];
}

+ (NSArray<AVPlayerItem*>*)playerItemsWithStr:(NSArray<NSString*>*)audioArr{
    NSMutableArray *itemArr = [NSMutableArray new];
    for (NSString *urlStr in audioArr) {
        NSURL *url = [NSURL URLWithString:urlStr];
        AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:url];
        [itemArr addObject:item];
    }
    return itemArr;
}

+ (void)pausePlayer{
    [[ZNAudioPlayerUtil shareInstance] pausePlayer];
}

+ (void)resumePlayer{
    [[ZNAudioPlayerUtil shareInstance] resumePlayer];
}

- (void)clearQueuePlayer{
    if (self.queuePlayer) {
        [self.queuePlayer removeAllItems];
        self.queuePlayer = nil;
    }
}

- (void)playItems:(NSArray*)items{
    if (!self.queuePlayer) {
        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:items];
    }
    [self.queuePlayer play];
}

- (void)pausePlayer{
    if (self.queuePlayer) {
        [self.queuePlayer pause];
    }
}

- (void)resumePlayer{
    if (self.queuePlayer) {
        [self.queuePlayer play];
    }
}

- (void)seekToTime:(int64_t)time timeScale:(int32_t)timeScale{
    if (self.queuePlayer) {
        CMTime cmtime = CMTimeMake(time, timeScale);
        [self.queuePlayer seekToTime:cmtime];
    }
}

@end
