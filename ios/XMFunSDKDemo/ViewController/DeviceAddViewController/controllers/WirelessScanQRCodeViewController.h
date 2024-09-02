//
//  WirelessScanQRCodeViewController.h
//  FunSDKDemo
//
//  Created by P on 2020/8/11.
//  Copyright © 2020 P. All rights reserved.
//

/**

使用二维码配置设备Wi-Fi
*1、输入wifi名称和密码，
*2、点击确定 出现二维码
*3、把二维码放在开始配网的摄像头前
*4、APP循环向服务端查询当前设备是否配网成功
*5、配网成功，把设备添加到当前账号下，返回到设备列表并刷新
*/
/*
 备注:二维码配网可以和快速配网（FUN_DevStartAPConfig接口）功能合并到一个逻辑中，两种配网逻辑只要有一种逻辑配网成功，设备就配网成功，可以提高配网成功率。设备配网成功后，停止配网时，两种配网方法也要同时停止
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WirelessScanQRCodeViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
