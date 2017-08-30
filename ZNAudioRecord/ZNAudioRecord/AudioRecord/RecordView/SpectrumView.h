//
//  SpectrumView.h
//  GYSpectrum
//
//  Created by 黄国裕 on 16/8/19.
//  Copyright © 2016年 黄国裕. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    Record_Status_Prepare,
    Record_Status_Pause,
    Record_Status_finish,
} Record_Status;

@protocol   SpectrumViewDelegate<NSObject>

@optional

//开始录音
- (void)viewDelegateStartRecord;
//暂停录音
- (void)viewDelegatePauseRecord;
//恢复录音
- (void)viewDelegateResumeRecord;
//取消录音
- (void)viewDelegateCancelRecord;
//停止录音
- (void)viewDelegateFinishRecord;


@end

@interface SpectrumView : UIView

@property (nonatomic, copy) void (^itemLevelCallback)();

//

@property (nonatomic, weak) id<SpectrumViewDelegate>delegate;

@property (nonatomic) NSUInteger numberOfItems;

@property (nonatomic) UIColor * itemColor;

@property (nonatomic) CGFloat level;

@property (nonatomic) UILabel *timeLabel;

@property (nonatomic) NSString *text;

//当前录音机状态
@property (nonatomic, assign) Record_Status recordStatus;

- (void)start;
- (void)stop;

@end
