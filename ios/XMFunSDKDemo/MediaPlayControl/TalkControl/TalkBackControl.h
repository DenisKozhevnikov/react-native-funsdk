//
//  TalkBackControl.h
//  XMEye
//
//  Created by XM on 2017/6/6.
//  Copyright © 2017年 Megatron. All rights reserved.
//
/***
 
 视频预览时的对讲功能控制器，继承自 FunMsgListener
 *手机端听筒播放和扬声器播放选择需要根据自己的情况进行选择修改
* 对讲功能和双向对讲功能同一时间只能打开一个
 *
 *单向对讲功能说明
 *  1、打开对讲前需要先关闭视频中的音频  FUN_MediaSetSound(_handle, 0, 0);
 *  2、按下开始对讲时，先打开对讲接口，还需要关闭对讲音频 FUN_MediaSetSound(_hTalk, 0, 0)，只留APP端说话传递到设备端;
 *  3、松开对讲时，需要打开对讲音频 FUN_MediaSetSound(_hTalk, 100, 0)，开始播放设备端对讲音频;
 *  4、关闭对讲时，除了关闭对讲接口，还需要关闭对讲音频  FUN_MediaSetSound(_hTalk, 0, 0);
 *
 *双向对讲功能
 *  1、打开对讲前需要先关闭视频中的音频  FUN_MediaSetSound(_handle, 0, 0);
 *  2、按下开始对讲时，打开对讲接口，APP端说话传递到设备端，设备端声音同时传递到APP端;
 *  3、关闭对讲时，关闭对讲接口，关闭对讲音频;
 *
 FUN_MediaSetSound 参数说明：
 第一个参数是播放或者对讲句柄，关闭视频音频时需要传入视频播放句柄，关闭对讲音频时需要传入对讲句柄。
 第二个参数是音量，1～100为打开，0为关闭音频。
 第三个参数默认为0
 FUN_MediaSetSound(_handle, 0, 0);
 *
 *****/

typedef NS_ENUM(int,PitchSemiTonesType) { //对讲:变声类型
    PitchSemiTonesNormal =0,//无
    PitchSemiTonesWoman,//女
    PitchSemiTonesMan//男
};

#import "FunMsgListener.h"
#import "Recode.h"
@interface TalkBackControl : FunMsgListener <AudioRecordDelegate>
{
    Recode *_audioRecode;
    int _hTalk;
}

@property (nonatomic, strong) NSString *deviceMac;
@property (nonatomic) int channel;
@property (nonatomic) int handle;

@property (nonatomic, assign) PitchSemiTonesType pitchSemiTonesType; //对讲:变声类型

#pragma mark - 单向对讲
//开始对讲，停止音频
-(void)startTalk;
//松开停止对讲，播放音频
-(void)pauseTalk;
- (void)closeTalk;//关闭对讲
 //(对讲和双向对讲同时只能打开一个)
#pragma mark - 双向对讲
- (void)startDouTalk:(BOOL)needEchoCancellation;
- (void)stopDouTalk;
@end
