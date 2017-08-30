
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

#define PerRecordFileLimitCount  (2 * 60)

@interface ZNAudioRecordManager()<SpectrumViewDelegate>

@property (nonatomic, strong) NSTimer *totalTimer;
@property (nonatomic, assign) NSInteger totalTimeCount;
@property (nonatomic, copy) NSString *previrRecordPath;

@property (nonatomic, strong) SpectrumView *recordView;

@end

@implementation ZNAudioRecordManager

- (NSTimer *)totalTimer{
    if (!_totalTimer) {
        _totalTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordCountTimer:) userInfo:nil repeats:YES];
    }
    return _totalTimer;
}

- (SpectrumView *)recordViewWithFrame:(CGRect)frame{
    self.recordView = [[SpectrumView alloc]initWithFrame:frame];
    self.recordView.delegate  = self;
    
    return self.recordView;
}

#pragma mark - timer
- (void)recordCountTimer:(NSTimer*)timer{
    
    if (self.totalTimeCount % PerRecordFileLimitCount == 0) {
        
        //上传上一段录音文件
        [self uploadLastestPerRecord];
        
        //停止录音
        [[ZZDeviceManager shareInstance] stopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
            
        }];
        //开始录音
        NSString *fileName = [self fileNameWithIndex:self.totalTimeCount / PerRecordFileLimitCount];
        self.previrRecordPath = [[ZZDeviceManager shareInstance] startRecordingWithFileName:fileName completion:^(NSError *error) {
            
        }];
    }
    
    self.totalTimeCount ++;
}

#pragma mark - SpectrumViewDelegate

- (void)viewDelegateStartRecord{
    [self startCount];
}

- (void)viewDelegatePauseRecord{
    [self stopCount];
}

- (void)viewDelegateCancelRecord{
    [self stopCount];
}

- (void)viewDelegateResumeRecord{
    [self startCount];
}

- (void)viewDelegateFinishRecord{

    [self finishRecord];
}

//结束录制
- (void)finishRecord{
    
    //停止计数
    [self stopCount];
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf startCount];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //结束录制后的操作
        weakSelf.totalTimeCount = 0;
        
    }];
    
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
    return [NSString stringWithFormat:@"%@_%ld",self.userName,index];
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

@end
