//
//  AlarmVoiceChoseVC.h
//  XWorld_General
//
//  Created by Megatron on 2019/3/27.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//
/***
自定义报警音列表
 voiceEnum == 550 //表示支持自定义语音
*****/
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlarmVoiceChoseVC : UIViewController

@property (nonatomic,copy) NSString *devID;
@property (nonatomic,strong) NSMutableArray *arrayDataSource;
@property (nonatomic,assign) int selectedVoiceTypeIndex;
@property (nonatomic,copy) void (^AlarmVoiceChoseVoiceTypeAction)(int voiceType);

@end

NS_ASSUME_NONNULL_END
