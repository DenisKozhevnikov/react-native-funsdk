//
//  DeviceAbilityManager.h
//  XWorld_General
//
//  Created by Tony Stark on 13/08/2019.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFunSDKObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GetDeviceAbilityCallBack)(int result);

/*
 设备能力集管理者
 */
@interface DeviceAbilityManager : CYFunSDKObject

@property (nonatomic,copy) GetDeviceAbilityCallBack callBack;

//是否支持人形检测
@property (nonatomic,assign) BOOL supportPEAInHumanPed;
//是否支持报警提示音选择
@property (nonatomic,assign) BOOL supportAlarmVoiceTipsType;
//是否支持获取4G信号强度
@property (nonatomic,assign) BOOL supportNet4GSignalLevel;
//是否支持充电时不休眠
@property (nonatomic,assign) BOOL supportChargeNoShutdown;
//是否支持强制关机
@property (nonatomic,assign) BOOL supportForceShutDownControl;
//是否支持设备呼吸灯
@property (nonatomic,assign) BOOL supportNotifyLight;

//是否支持获取WIFI信号
@property (nonatomic,assign) BOOL supportNetWiFiSignalLevel;
//是否支持多目枪球云台定位 和Android统一用来判断是否是指哪看哪设备
@property (nonatomic,assign) int iSupportGunBallTwoSensorPtzLocate;


//MARK:获取设备能力集
- (void)getSystemFunctionConfig:(GetDeviceAbilityCallBack)callBack;

@end

NS_ASSUME_NONNULL_END
