//
//  ZNAudioRecordManager.h
//  ZNAudioRecord
//
//  Created by mac on 2017/8/29.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SpectrumView.h"

@interface ZNAudioRecordManager : NSObject

@property (nonatomic, strong) NSString *userName;

- (SpectrumView*)recordViewWithFrame:(CGRect)frame;

@end
