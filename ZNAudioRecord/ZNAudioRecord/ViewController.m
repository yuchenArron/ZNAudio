//
//  ViewController.m
//  ZNAudioRecord
//
//  Created by mac on 2017/8/29.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#import "ViewController.h"

#import "ZNAudioRecordManager.h"

@interface ViewController ()

@property (nonatomic, strong) ZNAudioRecordManager *recordManager;

@end

@implementation ViewController

- (ZNAudioRecordManager *)recordManager{
    if (!_recordManager) {
        _recordManager   = [[ZNAudioRecordManager alloc]init];
    }
    return _recordManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView *recordView = [self.recordManager recordViewWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 60)];
    [self.view addSubview: recordView];
    
    recordView.backgroundColor = [UIColor greenColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
