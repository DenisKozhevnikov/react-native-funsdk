//
//  PlayViewController.h
//  FunSDKDemo
//
//  Created by XM on 2018/5/23.
//  Copyright © 2018年 XM. All rights reserved.
//

/*****
 *
 * 预览界面视图控制器，包括下面几部分
 *单通道预览
 *多通道预览（包含4个以上通道的NVR等设备，可以打开前4个通道进行预览（代码中注释了），预览时的各种抓图录像等操作，默认选中第一个通道。4通道预览时，各初始化了4个控制器MediaplayerControl和4个播放画面PlayView，想要操作哪一个通道，就传递对应MediaplayerControl和PlayView的参数）
 *打开和停止预览
 *暂停和恢复预览
 *音频和对讲
 *抓图和录像
 *云台控制
 *清晰度切换
 *app进入后台时，可以把视频暂停，也可以直接停止，重新唤醒app时，再恢复播放
*****/

#import <UIKit/UIKit.h>

@interface PlayViewController : UIViewController

@end
