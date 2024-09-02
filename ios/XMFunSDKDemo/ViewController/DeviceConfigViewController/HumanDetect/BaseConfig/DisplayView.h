//
//  DisplayView.h
//  XMUtils
//
//  Created by liuguifang on 05/20/16.
//  Copyright (c) 2016 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayViewDelegate.h"
typedef enum DisplayViewStatus
{
    DisplayViewStatusStop,
    DisplayViewStatusBuffering,
    DisplayViewStatusPlaying,
    DisplayViewStatusPause,
    DisplayViewStatusRetrying,
    DisplayViewStatusNoVideo
}DisplayViewStatus;


@interface DisplayView : UIView


@property (nonatomic,strong) UIButton *ctlBtn;                       //中间控制按钮及状态显示
@property (nonatomic,strong) UILabel *lableTip;                      //右下角提示（码率）
@property (nonatomic) DisplayViewStatus dispStatus;                  //当前状态
@property (nonatomic) UIColor* backColor;                            //停止状态的背景色
@property (nonatomic) UIImage* backImage;                            //停止状态的背景色
//几个状态的按钮图片
@property (nonatomic) UIImage* stopImage;                            //停止状态的按钮图片
@property (nonatomic) UIImage* bufferingImage;                       //缓冲状态的按钮图片
@property (nonatomic) UIActivityIndicatorView* activityIndicatorView; //加载图标
@property (nonatomic) UILabel* labelStatus;
@property (nonatomic) UIImage* playingImage;                         //正在播放状按钮态的图片
@property (nonatomic) UIImage* pauseImage;                           //暂停状态的按钮图片
@property (nonatomic) id<DisplayViewDelegate> delegateCtl;              //按钮控制代理和手势滑动代理
//云台功能
@property (nonatomic) CGPoint moveFrom;//手势滑动出发点
@property (nonatomic) CGPoint moveTo;//手势滑动结束点


@end
