//
//  PlayMenuView.h
//  XMEye
//
//  Created by Levi on 2016/6/22.
//  Copyright © 2016年 Megatron. All rights reserved.
//

/******
 *
 *功能栏界面，包含切换清晰度、云台控制、回放入口、获取预览YUV数据等
 *
 *
 */


#import <UIKit/UIKit.h>

@protocol PlayMenuViewDelegate <NSObject>

//显示云台控制
-(void)showPTZControl;

//切换码流
-(void)changeStreamType;

//回放
-(void)presentPlayBackViewController;

//获取视频 YUV数据
- (void)playYUVBtnClick;

//跳转到控制view
-(void)changeToControlVC;

//设备抓图
-(void)storeSnapEvent;

//走廊模式
-(void)corridorModelEvent;

//全屏
- (void)fullScreenEvent;


@end

@interface PlayMenuView : UIView

//云台控制按钮
@property (nonatomic, strong) UIButton *PTZBtn;

//切换码流按钮
@property (nonatomic, strong) UIButton *streamBtn;

//跳转到回放界面
@property (nonatomic, strong) UIButton *playBackBtn;

//预览按钮（自己处理视频YUV数据）
@property (nonatomic, strong) UIButton *playYUVBtn;

//报警按钮
@property (nonatomic, strong) UIButton *alarmBtn;

//预览控制按钮
@property (nonatomic, strong) UIButton *controlBtn;

//设备抓图按钮
@property (nonatomic, strong) UIButton *StoreSnapBtn;

//走廊模式按钮
@property (nonatomic, strong) UIButton *corridorModelBtn;

@property (nonatomic, weak) id <PlayMenuViewDelegate> delegate;

//获取当前app版本语言
@property (nonatomic, strong) NSString *localLanguage;

//切换码流成功后，改变码流按钮状态，0为高清，1位标清
@property (nonatomic, assign) int streamType;

//MARK: - 全屏按钮
@property (nonatomic, strong) UIButton *btnFull;

@end
