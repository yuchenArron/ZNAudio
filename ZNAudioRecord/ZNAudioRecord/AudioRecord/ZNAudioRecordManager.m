
//
//  ZNAudioRecordManager.m
//  ZNAudioRecord
//
//  Created by mac on 2017/8/29.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#import "ZNAudioRecordManager.h"
#import "ZZAudioRecorderUtil.h"
#import "ZZDeviceManager.h"
#import "ZNRecordUploadNetwork.h"
#import "ZNAudioRecordTools.h"

#define PerRecordFileLimitCount  (2 * 10)
#define TheRecordPartName @"theRecordPart"


@interface ZNAudioRecordManager()<SpectrumViewDelegate>

@property (nonatomic, strong) NSTimer *totalTimer;
@property (nonatomic, assign) NSInteger totalTimeCount;
@property (nonatomic, copy) NSString *previrRecordPath;

@property (nonatomic, strong) SpectrumView *recordView;

//是否重启重新录制
@property (nonatomic, assign) BOOL isRestartApp;

@end

@implementation ZNAudioRecordManager

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setContentInit];
    }
    return self;
}

- (void)setContentInit{
    self.userName = @"YUCHEN";
    
    //获取总计数
    self.totalTimeCount = [ZNAudioRecordTools getCurrentTotalNumberUser:self.userName];
    
    //测试播放
    NSArray *filePathArr = [ZNAudioRecordTools getAllFilesWithName];
    
//    [[ZZDeviceManager shareInstance] playAudioWithPath:filePathArr.firstObject completion:^(NSError *error) {
//        
//    }];
    
    [ZNAudioPlayerUtil playAudios:filePathArr];
}

- (NSTimer *)totalTimer{
    if (!_totalTimer) {
        _totalTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordCountTimer:) userInfo:nil repeats:YES];
    }
    return _totalTimer;
}

- (SpectrumView *)recordViewWithFrame:(CGRect)frame{
    self.recordView = [[SpectrumView alloc]initWithFrame:frame];
    self.recordView.delegate  = self;
    if (self.totalTimeCount > 0) {
        [self.recordView setRecordStatus:Record_Status_Pause];
        self.recordView.text = [ZNAudioRecordTools timeStringWithTimerCount:self.totalTimeCount];
    }
    return self.recordView;
}

#pragma mark - timer
- (void)recordCountTimer:(NSTimer*)timer{
    
    [self dealRecord];
    
    self.totalTimeCount ++;
    //展示录音时长
    self.recordView.text = [ZNAudioRecordTools timeStringWithTimerCount:self.totalTimeCount];
    //保存当前时长
    [ZNAudioRecordTools setCurrentTotalNumber:self.totalTimeCount user:self.userName];
}

#pragma mark - SpectrumViewDelegate

- (void)viewDelegateStartRecord{
    [self startCount];
    
    if (self.totalTimeCount > 0 && self.totalTimeCount % PerRecordFileLimitCount != 0){
        NSString *fileName = [self fileNameWithIndex:(self.totalTimeCount) / PerRecordFileLimitCount];
        [ZNAudioRecordTools pieceFileA:fileName withFileB:TheRecordPartName];
        
        [[ZZDeviceManager shareInstance] startRecordingWithFileName:TheRecordPartName completion:^(NSError *error) {
            
        }];
        self.isRestartApp = YES;
    }
    
}

- (void)viewDelegatePauseRecord{
    [self stopCount];
    [[ZZDeviceManager shareInstance]pauseCurrentRecording];
}

- (void)viewDelegateCancelRecord{
    [self stopCount];
}

- (void)viewDelegateResumeRecord{
    [self startCount];
    [[ZZDeviceManager shareInstance] resumeCurrentRecording] ;
}

- (void)viewDelegateFinishRecord{

    [self finishRecord];
}

//结束录制
- (void)finishRecord{
    
    //停止计数
    [self stopCount];
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:FinishRecordPromptTitle message:FinishRecordPromptMessage preferredStyle:UIAlertControllerStyleAlert];
    //修改title
    NSString *titleStr = FinishRecordPromptTitle;
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:titleStr];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, titleStr.length)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, titleStr.length)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:FinishRecordPromptCancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf startCount];
    }];
    [cancelAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:FinishRecordPromptOK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //结束录制后的操作
        weakSelf.totalTimeCount = 0;
        [ZNAudioRecordTools clearRecordingMarkUserName:weakSelf.userName];
        [weakSelf.recordView setRecordStatus:Record_Status_finish];
        //上传上一段录音文件
        [self uploadLastestPerRecord];
        
    }];
    [okAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    UIViewController *viewController = [self getCurrentVC];
    [viewController presentViewController:alertController animated:YES completion:nil];
}


//获取当前屏幕显示的viewcontroller   (这里面获取的相当于rootViewController)
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

#pragma mark - private methods
- (NSString*)fileNameWithIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%@_%ld",self.userName,(long)index];
}

- (void)stopCount{
    [self.totalTimer invalidate];
    self.totalTimer = nil;
    
}

- (void)startCount{
    [self.totalTimer fire];
}

- (void)uploadLastestPerRecord{
    if (self.previrRecordPath) {
        [ZNRecordUploadNetwork uploadRecordFile:self.previrRecordPath type:@"wav" progress:^(CGFloat progress) {
            
        } success:^{
            
        } failure:^{
            
        }];
    }
}

#pragma mark - //录音 逻辑

- (void)dealRecord{
    if (self.totalTimeCount % PerRecordFileLimitCount == 0) {
        
        if (self.totalTimeCount != 0 ){
            if (self.isRestartApp){
                NSString *fileName = [self fileNameWithIndex:(self.totalTimeCount - 1) / PerRecordFileLimitCount];
                [ZNAudioRecordTools pieceFileA:fileName withFileB:TheRecordPartName];
                self.isRestartApp = NO;
            }
            //上传上一段录音文件
            [self uploadLastestPerRecord];
            
            __weak typeof(self) weakSelf = self;
            //停止录音
            [[ZZDeviceManager shareInstance] stopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //开始录音
                    NSString *fileName = [weakSelf fileNameWithIndex:weakSelf.totalTimeCount / PerRecordFileLimitCount];
                    weakSelf.previrRecordPath = [[ZZDeviceManager shareInstance] startRecordingWithFileName:fileName completion:^(NSError *error) {
                        
                    }];
                });
            }];
        }else{
            //开始录音
            NSString *fileName = [self fileNameWithIndex:self.totalTimeCount / PerRecordFileLimitCount];
            self.previrRecordPath = [[ZZDeviceManager shareInstance] startRecordingWithFileName:fileName completion:^(NSError *error) {
                
            }];
        }
    }
}



@end
