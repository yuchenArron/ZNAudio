//
//  ZNRecordUploadNetwork.h
//  ZNAudioRecord
//
//  Created by mac on 2017/8/29.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef void(^progress)(CGFloat progress);
typedef void(^successful)();
typedef void(^failure)();

@interface ZNRecordUploadNetwork : NSObject

+ (void)uploadRecordFile:(NSString*)filePath type:(NSString*)type progress:(progress)progress success:(successful)success failure:(failure)failure;

//

@end
