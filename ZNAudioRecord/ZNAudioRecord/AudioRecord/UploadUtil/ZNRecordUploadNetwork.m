//
//  ZNRecordUploadNetwork.m
//  ZNAudioRecord
//
//  Created by mac on 2017/8/29.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#import "ZNRecordUploadNetwork.h"
#import <AFHTTPSessionManager.h>

static ZNRecordUploadNetwork *recordUploadNet = nil;

@interface ZNRecordUploadNetwork()



@end

@implementation ZNRecordUploadNetwork

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recordUploadNet = [[ZNRecordUploadNetwork alloc]init];
    });
    return recordUploadNet;
}

+ (void)uploadRecordFile:(NSString *)fileName type:(NSString *)type progress:(progress)progress success:(successful)success failure:(failure)failure{
    
    __weak NSString *weakFilePath = fileName;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/jpeg", nil];
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"action"] = @"999";
    [manager POST:@"http://push.hjourney.cn/api.php?c=Index2" parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //              application/octer-stream   audio/mpeg video/mp4   application/octet-stream
        
        /* url      :  本地文件路径
         * name     :  与服务端约定的参数
         * fileName :  自己随便命名的
         * mimeType :  文件格式类型 [mp3 : application/octer-stream application/octet-stream] [mp4 : video/mp4]
         */
        [formData appendPartWithFileURL:[NSURL URLWithString:weakFilePath] name:@"video" fileName:@"xxx.mp3" mimeType:@"application/octet-stream" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        float progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        NSLog(@"上传进度-----   %f",progress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"上传成功 %@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败 %@",error);
    }];
    
}

@end
