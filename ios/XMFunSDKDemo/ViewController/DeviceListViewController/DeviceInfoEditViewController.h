//
//  DeviceInfoEditViewController.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/11/19.
//  Copyright © 2018年 wujiangbo. All rights reserved.
//
/**
 
 序列号添加设备视图控制器
 *1、输入设备名称，设备用户名，设备密码。(设备用户名也可通过接口修改，默认admin，非特殊定制设备不要改设备用户名）
 *2、设置设备名称
 *3、这个编辑方法不能修改设备密码，仅仅是设备密码保存本地，预览时不需要再输入。如果输入密码错误，则预览时需要重新设置设备本地保存的密码
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoEditViewController : UIViewController
@property (nonatomic, copy) void(^editSuccess)(void);     //编辑成功
@property(nonatomic,strong)DeviceObject *devObject;       //当前选中设备

@end

NS_ASSUME_NONNULL_END
