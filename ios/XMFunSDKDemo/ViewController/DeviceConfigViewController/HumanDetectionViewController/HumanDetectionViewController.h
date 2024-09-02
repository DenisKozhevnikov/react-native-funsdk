//
//  HumanDetectionViewController.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/12/27.
//  Copyright © 2018 wujiangbo. All rights reserved.
//
/****
 *徘徊检测报警设置界面 （DVR人形检测，另外还有一个IPC人形检测功能，不是同一个功能）
 *报警功能、报警录像、报警抓图、手机推送开关设置
 *如果错误提示：配置解析出错-11406，一般是设备不支持徘徊检测
 *
 *DVR人形检测和IPC人形检测 不是同一个功能。
 DVR人形检测主要功能包括报警开关、报警录像开关、报警抓图开关、消息推送开关等等
 IPC人形检测则主要包括报警开关、设置报警拌线、设置报警区域等等
 ***/
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HumanDetectionViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
