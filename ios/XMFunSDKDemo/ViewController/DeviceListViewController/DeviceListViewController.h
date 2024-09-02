//
//  DeviceListViewController.h
//  FunSDKDemo
//
//  Created by Levi on 2018/5/18.
//  Copyright © 2018年 Levi. All rights reserved.
//

/**
 
 设备列表视图控制器
 1、设备在线状态刷新 （包括门铃休眠状态刷新。设备在线状态获取完成之后，再去获取休眠状态比较准确）
 2、长按列表编辑删除设备 (修改设备名称、设备密码以及设备用户名。 用户名需要慎重修改，一般来说都是默认admin)
 3、点击设备获取设备通道信息，进入预览 （单通道设备可以不用获取通道信息，直接进入预览设备第一个通道）
 */

#import <UIKit/UIKit.h>

@interface DeviceListViewController : UIViewController

@end
