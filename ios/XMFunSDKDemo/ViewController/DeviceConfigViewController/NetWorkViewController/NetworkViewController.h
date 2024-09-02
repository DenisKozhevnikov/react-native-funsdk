//
//  NetworkViewController.h
//  FunSDKDemo
//
//  Created by zhang on 2019/6/13.
//  Copyright © 2019 zhang. All rights reserved.
//

/************
 
 设备网络设置
 1、获取设备网络信息 （Wi-Fi的ssid，Wi-Fi密码，加密方式等）
 2、获取设备附近的Wi-Fi列表
 3、把设备设置成AP模式 （非AP->AP）（AP模式和非AP模式，AP模式下，设备会开启一个热点，手机连接设备的热点，之后就可以正常操作设备。手机热点默认密码：1234567890）
 4、设置设备Wi-Fi，根据设备附近的Wi-Fi列表，选择其中一个Wi-Fi堆设备进行配网
 
 **********/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
