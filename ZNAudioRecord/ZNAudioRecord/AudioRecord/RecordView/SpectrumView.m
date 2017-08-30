//
//  SpectrumView.m
//  GYSpectrum
//
//  Created by 黄国裕 on 16/8/19.
//  Copyright © 2016年 黄国裕. All rights reserved.
//

#import "SpectrumView.h"

#define ButtonFrameWidthAndHeight      34

@interface SpectrumView ()

@property (nonatomic, strong) NSMutableArray * levelArray;
@property (nonatomic) NSMutableArray * itemArray;
@property (nonatomic) CGFloat itemHeight;
@property (nonatomic) CGFloat itemWidth;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, assign) BOOL isRecordingPause;

@end

@implementation SpectrumView


- (id)init
{
    NSLog(@"init");
    if(self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"initWithFrame");
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    [self setup];
}

- (void)setup
{
    
    NSLog(@"setup");
    
    self.itemArray = [NSMutableArray new];
    
    self.numberOfItems = 20;//偶数
   
    self.itemColor = [UIColor colorWithRed:241/255.f green:60/255.f blue:57/255.f alpha:1.0];

    self.itemHeight = CGRectGetHeight(self.bounds);
    self.itemWidth  = CGRectGetWidth(self.bounds);
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.itemWidth*0.4, 0, self.itemWidth*0.2, self.itemHeight)];
    self.timeLabel.text = @"";
    [self.timeLabel setTextColor:[UIColor grayColor]];
    [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.timeLabel];
    self.timeLabel.hidden = YES;
    
    self.levelArray = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < self.numberOfItems/2 ; i++){
        [self.levelArray addObject:@(1)];
    }
    
    CGRect frame = CGRectMake((self.frame.size.width - ButtonFrameWidthAndHeight) / 2, (self.frame.size.height - ButtonFrameWidthAndHeight) / 2, ButtonFrameWidthAndHeight, ButtonFrameWidthAndHeight);
    
    self.finishButton = [[UIButton alloc]initWithFrame:frame];
    self.finishButton.layer.cornerRadius = ButtonFrameWidthAndHeight / 2;
    [self.finishButton setTitle:@"结束" forState:UIControlStateNormal];
    [self.finishButton addTarget:self action:@selector(finishRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.finishButton];
    self.finishButton.backgroundColor = [UIColor grayColor];
    
    self.recordButton = [[UIButton alloc]initWithFrame:frame];
    [self.recordButton addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
    self.recordButton.layer.cornerRadius = ButtonFrameWidthAndHeight / 2;
    [self addSubview:self.recordButton];
    self.recordButton.backgroundColor  = [UIColor redColor];
    
    [self setRecordStatus:Record_Status_Prepare];
}

-(void)setItemLevelCallback:(void (^)())itemLevelCallback
{
    NSLog(@"setItemLevelCallback");
    
    _itemLevelCallback = itemLevelCallback;

    [self start];
    
    for(int i=0; i < self.numberOfItems; i++)
    {
        CAShapeLayer *itemline = [CAShapeLayer layer];
        itemline.lineCap       = kCALineCapButt;
        itemline.lineJoin      = kCALineJoinRound;
        itemline.strokeColor   = [[UIColor clearColor] CGColor];
        itemline.fillColor     = [[UIColor clearColor] CGColor];
        [itemline setLineWidth:self.itemWidth*0.4/self.numberOfItems];
        itemline.strokeColor   = [self.itemColor CGColor];
        
        [self.layer addSublayer:itemline];
        [self.itemArray addObject:itemline];
    }
    
}


- (void)setLevel:(CGFloat)level
{
    //NSLog(@"setLevel:%f",level);
    level = (level+37.5)*3.2;
    if( level < 0 ) level = 0;

    [self.levelArray removeObjectAtIndex:self.numberOfItems/2-1];
    [self.levelArray insertObject:@((level / 6) < 1 ? 1 : level / 6) atIndex:0];
    
    [self updateItems];
    
}


- (void)setText:(NSString *)text{
    self.timeLabel.text = text;
}

- (void)setRecordStatus:(Record_Status)recordStatus{
    switch (recordStatus) {
        case Record_Status_Prepare:
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            break;
        case Record_Status_Pause:
            [self setPauseStatusUI];
            break;
        case Record_Status_finish:
            [self setRecordFinishStatusUI];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            break;
        default:
            break;
    }
}

- (void)setPauseStatusUI{
    [self showButtonsAnimation];
    self.recordButton.selected = NO;
}

- (void)setRecordFinishStatusUI{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = weakSelf.frame;
        frame.size.height = 0;
        weakSelf.frame = frame;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (void)updateItems
{
    //NSLog(@"updateMeters");
    
    UIGraphicsBeginImageContext(self.frame.size);
    
    int x = self.itemWidth*0.8/self.numberOfItems;
    int z = self.itemWidth*0.2/self.numberOfItems;
    int y = self.itemWidth*0.6 - z;
    
    for(int i=0; i < (self.numberOfItems / 2); i++) {
        
        UIBezierPath *itemLinePath = [UIBezierPath bezierPath];
        
        y += x;
        
        [itemLinePath moveToPoint:CGPointMake(y, self.itemHeight/2+([[self.levelArray objectAtIndex:i]intValue]+1)*z/2)];
        
        [itemLinePath addLineToPoint:CGPointMake(y, self.itemHeight/2-([[self.levelArray objectAtIndex:i]intValue]+1)*z/2)];
        
        CAShapeLayer *itemLine = [self.itemArray objectAtIndex:i];
        itemLine.path = [itemLinePath CGPath];
        
    }
    
    
    y = self.itemWidth*0.4 + z;
    
    for(int i = (int)self.numberOfItems / 2; i < self.numberOfItems; i++) {
        
        UIBezierPath *itemLinePath = [UIBezierPath bezierPath];
        
        y -= x;
        
        [itemLinePath moveToPoint:CGPointMake(y, self.itemHeight/2+([[self.levelArray objectAtIndex:i-self.numberOfItems/2]intValue]+1)*z/2)];
        
        [itemLinePath addLineToPoint:CGPointMake(y, self.itemHeight/2-([[self.levelArray objectAtIndex:i-self.numberOfItems/2]intValue]+1)*z/2)];
        
        CAShapeLayer *itemLine = [self.itemArray objectAtIndex:i];
        itemLine.path = [itemLinePath CGPath];
        
    }
    
    UIGraphicsEndImageContext();
}

- (void)start {
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:_itemLevelCallback selector:@selector(invoke)];
        self.displayLink.frameInterval = 6;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stop {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

#pragma mark - click action

- (void)finishRecord:(UIButton*)button{
    //结束录音
    if ([self.delegate respondsToSelector:@selector(viewDelegateFinishRecord)]) {
        [self.delegate viewDelegateFinishRecord];
    }
}

- (void)startRecord:(UIButton*)button{
    
    if (button.selected) {
    //暂停
        if ([self.delegate respondsToSelector:@selector(viewDelegatePauseRecord)]) {
            [self.delegate viewDelegatePauseRecord];
        }
        self.isRecordingPause = YES;
    }else{
        
        if(self.isRecordingPause){
            if ([self.delegate respondsToSelector:@selector(viewDelegateResumeRecord)]) {
                [self.delegate viewDelegateResumeRecord];
            }
            self.isRecordingPause = NO;
        }else{
            //开始
            [self showButtonsAnimation];
            if ([self.delegate respondsToSelector:@selector(viewDelegateStartRecord)]) {
                [self.delegate viewDelegateStartRecord];
            }
        }
    }
    button.selected = !button.selected;
}

//动画展开 录音和结束按钮
- (void)showButtonsAnimation{
    
    CGFloat pointX = self.frame.size.width / 3;
    CGRect frame = self.recordButton.frame;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.recordButton.frame = CGRectMake(pointX - ButtonFrameWidthAndHeight / 2, frame.origin.y, frame.size.width, frame.size.height);
        weakSelf.finishButton.frame = CGRectMake(2 * pointX - ButtonFrameWidthAndHeight / 2, frame.origin.y, frame.size.width, frame.size.height);
    } completion:^(BOOL finished) {
        self.timeLabel.hidden = NO;
    }];
}





@end
