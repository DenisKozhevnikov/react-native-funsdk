//
//  DeviceAbilityManager.m
//  XWorld_General
//
//  Created by Tony Stark on 13/08/2019.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "DeviceAbilityManager.h"
#import "SystemFunction.h"
#import "DeviceConfig.h"

@interface DeviceAbilityManager () <DeviceConfigDelegate>
{
    SystemFunction systemFunction;
}

@end

@implementation DeviceAbilityManager

//MARK:获取设备能力集
- (void)getSystemFunctionConfig:(GetDeviceAbilityCallBack)callBack{
    self.callBack = callBack;
    
    systemFunction.SetName(JK_SystemFunction);
    DeviceConfig* systemFunctionCfg = [[DeviceConfig alloc] initWithJObject:&systemFunction];
    systemFunctionCfg.devId = self.devID;
    systemFunctionCfg.channel = -1;
    systemFunctionCfg.isSet = NO;
    systemFunctionCfg.delegate = self;
    systemFunctionCfg.isGet = YES;
    [self requestGetConfig:systemFunctionCfg];
}

//MARK: - 获取配置返回
-(void)getConfig:(DeviceConfig*)config result:(int)result{
    if ([config.name isEqualToString:OCSTR(JK_SystemFunction)]) {
        if (result >= 0) {
            self.supportPEAInHumanPed = systemFunction.mAlarmFunction.PEAInHumanPed.Value();
            self.supportChargeNoShutdown = systemFunction.mOtherFunction.SupportForceShutDownControl.Value();
            self.supportNotifyLight = systemFunction.mOtherFunction.SupportNotifyLight.Value();
            self.iSupportGunBallTwoSensorPtzLocate = systemFunction.mOtherFunction.SupportGunBallTwoSensorPtzLocate.Value()?1:0;
            self.supportNetWiFiSignalLevel = systemFunction.mNetServerFunction.WifiRouteSignalLevel.Value()?1:0;
        }
        
        if (self.callBack) {
            self.callBack(result);
        }
    }
}

@end
