
//
//  ZNAudioRecordMacro.h
//  ZNAudioRecord
//
//  Created by mac on 2017/8/30.
//  Copyright © 2017年 Netposa. All rights reserved.
//

#ifndef ZNAudioRecordMacro_h
#define ZNAudioRecordMacro_h

#define ImageNamed(name) [UIImage imageNamed:name]
#define RGBA(r, g, b, a)          [UIColor colorWithRed:(r)/255.f    green:(g)/255.f    blue:(b)/255.f    alpha:(a)]

#define SystemThemeColor RGBA(237,98,52,1)

#define FinishRecordPromptMessage  @"结束录音将把录音文件上传至服务器，结束后本次面试不能继续录音，确定结束么？"

#define FinishRecordPromptTitle           @"提示信息"
#define FinishRecordPromptCancel    @"取消"
#define FinishRecordPromptOK             @"确定"


#endif /* ZNAudioRecordMacro_h */
