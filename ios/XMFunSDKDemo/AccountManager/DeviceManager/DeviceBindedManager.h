//
//  CYDeviceBindedManager.h
//  XWorld_General
//
//  Created by SaturdayNight on 2018/9/11.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYFunSDKObject.h"

// 支持读取设备恢复出厂状态，如果是恢复出厂状态下，添加设备（用户登录情况下），设置此用户为主联系人
// 需要提供设备读取和设置恢复出厂设置状态标志的接口
// 序列号 或者 本地搜索方式添加设备时
// 先判断是否有这个能力集
// 如果有再去获取这个配置
// 如果配置是非绑定 设置为绑定 清空订阅 设置为主账号 如果是绑定 普通添加
// 快速配置添加设备时
// 先判断是否有这个能力集
// 如果有再去获取这个配置
// 如果是绑定 使用普通添加 否则 设置为绑定 清空订阅 设置为主账号

typedef NS_ENUM(NSInteger,AddDeviceStyle){
    AddDeviceStyleNormal,
    AddDeviceStyleSpecial
};

// 返回时不同添加还是特殊模式添加
typedef void (^AddDeviceStyleCallBack)(AddDeviceStyle style);
// 返回是否绑定
typedef void (^DeviceBindedCallBack)(BOOL ifBinded);

@interface DeviceBindedManager : CYFunSDKObject

@property (nonatomic,copy) AddDeviceStyleCallBack addDeviceStyleCallBack;
@property (nonatomic,copy) DeviceBindedCallBack deviceBindedCallBack;

- (void)getBindConfig:(AddDeviceStyleCallBack)result bindResult:(DeviceBindedCallBack)bindResult;
// 获取设备的绑定标识能力集
- (void)jf_queryDevSupportAppBindValueWithDevId:(NSString *)devId completion:(void(^)(BOOL bindEnable, BOOL bindFinished, NSInteger errCode))completion;

#pragma mark - 预览界面判断是否需要设置为绑定
- (void)setDeviceBindInCamera;

@end
