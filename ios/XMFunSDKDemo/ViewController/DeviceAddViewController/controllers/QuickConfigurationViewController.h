//
//  QuickConfigurationViewController.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/11/15.
//  Copyright © 2018年 wujiangbo. All rights reserved.
//
/**
 
 快速配置视图控制器
 *1、输入wifi名称和密码，
 *2、点击开始配置，开始倒计时（点取消停止快速配置）
 *3、设备配置成功，显示设备按钮
 *4、点击设备按钮通过序列号添加设备
 *5、因为苹果官方限制，iOS14.5以后的系统，需要申请广播权限才能配网，申请地址：https://developer.apple.com/contact/request/networking-multicast
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QuickConfigurationViewController : UIViewController

#pragma mark  从网络配置界面跳转到这里并直接开始快速配置 （正常快速配置功能不会调用这个方法）
-(void)otherStartWay:(NSString *)ssid psw:(NSString *)password;
@end

NS_ASSUME_NONNULL_END
