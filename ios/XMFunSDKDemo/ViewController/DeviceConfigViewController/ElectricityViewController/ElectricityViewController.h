//
//  ElectricityViewController.h
//  FunSDKDemo
//
//  Created by zhang on 2019/5/10.
//  Copyright © 2019 zhang. All rights reserved.
//

/******
 *
 *设备状态上报：打开开关，设备开始上报，关闭开关，设备停止上报，目前包括电量上报和存储状态上报
 * 获取低功耗设备剩余电量
 * 设备存储卡状态
 */
/**
 *
 * 目前只有一部分设备支持设备上报功能，例如门铃门锁和低功耗设备等等 XM_DEV_DOORBELL  XM_DEV_CAT  CZ_DOORBELL  XM_DEV_LOW_POWER
 *
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ElectricityViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
