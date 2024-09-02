//
//  NetCustomRecordVC.h
//  XWorld_General
//
//  Created by Megatron on 2019/12/27.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//
/***
自定义报警音设置界面
分文字转语音和录制语音，点击上传直接发送语音
*****/
#import <UIKit/UIKit.h>

@interface NetCustomRecordVC : UIViewController

@property (nonatomic,copy) NSString *devID;

@property (nonatomic,assign) int fileNumber;

@end
