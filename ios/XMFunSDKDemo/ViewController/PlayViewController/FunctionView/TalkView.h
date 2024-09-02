//
//  TalkView.h
//  XMEye
//
//  Created by Wangchaoqun on 15/7/4.
//  Copyright (c) 2015年 Megatron. All rights reserved.
//
/******
 *
 *对讲界面
 单向对讲： （一方语音，另一方只能听，直到发送语音的一方停止，另一方才能说话）
 *  1、打开对讲前需要先关闭音频  FUN_MediaSetSound(_handle, 0, 0);
 *  2、按下开始对讲时，除了对讲接口，还需要关闭音频 FUN_MediaSetSound(_hTalk, 0, 0);
 *  3、松开对讲时，除了对讲接口，还需要打开音频 FUN_MediaSetSound(_hTalk, 100, 0);
 *   4、关闭对讲时，除了关闭对讲接口，还需要关闭音频  FUN_MediaSetSound(_hTalk, 0, 0);
 *
 *
 双向对讲：（类似于电话，可以同时说话）
 *1、单击开始对讲，手机端和设备端同时手机音频传递给对方
 *2、再次单击结束对讲，手机端和设备端同时结束对讲
 *
 *
       FUN_MediaSetSound 参数说明：
       第一个参数是播放或者对讲句柄，关闭视频音频时需要传入视频播放句柄，关闭对讲音频时需要传入对讲句柄。
       第二个参数是音量，1～100为打开，0为关闭音频。
       第三个参数默认为0
       FUN_MediaSetSound(_handle, 0, 0);
 *
 */

#import <UIKit/UIKit.h>

@protocol TalKViewDelegate <NSObject>
@optional
/*! @berif 打开通话视图 */
- (void)openTalkView;
/*! @berif 关闭通话视图 */
- (void)closeTalkView;

//单向对讲
/*! @berif 开始通话    */
- (void)openTalk;
/*! @berif 关闭通话    */
- (void)closeTalk;

//双向对讲
- (void)startDouTalk;
- (void)stopDouTalk;
@end

@interface TalkView : UIView

//单向对讲 （APP或设备端在讲话时，对方只能接听不能讲话）
@property (nonatomic,retain) UIButton *talkButton;

//双向对讲 （手机端和设备端可以同时讲话）  双向对讲和单向对讲不能同时开启！
@property (nonatomic,retain) UIButton *dTalkButton;

//关闭对讲
@property (nonatomic,retain) UIButton *cannelButton;


//女声对讲
@property (nonatomic,retain) UIButton *femaleButton;
//男声对讲
@property (nonatomic,retain) UIButton *maleButton;
//对讲声音
@property (nonatomic) int talkSoundType;

@property (nonatomic,retain) id<TalKViewDelegate> delegate;

/*! @berif 显示视图 */
- (void)showTheView;
- (void)cannelTheView;//隐藏视图
@end
