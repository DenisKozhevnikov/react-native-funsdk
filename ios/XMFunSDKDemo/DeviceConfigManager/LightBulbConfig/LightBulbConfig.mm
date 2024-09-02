//
//  LightBulbConfig.m
//  FunSDKDemo
//
//  Created by zhang on 2019/12/11.
//  Copyright © 2019 zhang. All rights reserved.
//

#import "LightBulbConfig.h"
#import "Camera_WhiteLight.h"

@interface LightBulbConfig ()
{
    Camera_WhiteLight config;
}
@end

@implementation LightBulbConfig

//获取灯泡配置
- (void)getDeviceConfig {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    CfgParam* paramfunctionCfg = [[CfgParam alloc] initWithName:[NSString stringWithUTF8String:config.Name()] andDevId:channel.deviceMac andChannel:-1 andConfig:&config andOnce:YES andSaveLocal:NO];//获取能力级
    [self AddConfig:paramfunctionCfg];
    [self GetConfig:[NSString stringWithUTF8String:config.Name()]];
}
- (void)setDeviceConfig {
    [self SetConfig];
}

#pragma mark 获取配置回调信息
-(void)OnGetConfig:(CfgParam *)param {
    if ([param.name isEqualToString:[NSString stringWithUTF8String:config.Name()]]) {
        if([self.delegate respondsToSelector:@selector(getWhiteLightConfigResult:)]){
            [self.delegate getWhiteLightConfigResult:param.errorCode];
        }
    }
}
#pragma mark  保存配置回调
-(void)OnSetConfig:(CfgParam *)param{
    if ([param.name isEqualToString:NSSTR(config.Name())]) {
        if ([self.delegate respondsToSelector:@selector(setWhiteLightConfigResult:)]) {
            [self.delegate setWhiteLightConfigResult:param.errorCode];
        }
    }
}

- (int)getLightBrightness { //获取亮度值
    return config.Brightness.Value();
}
- (int)getMoveTrigLightDuration { //获取自动亮灯时间
    return config.mMoveTrigLight.Duration.Value();
}
- (int)getMoveTrigLightLevel {  //获取自动亮灯灵敏度
    return config.mMoveTrigLight.Level.Value();
}
- (NSString*)getWorkMode{ //获取工作模式
    return OCSTR(config.WorkMode.Value());
}
- (BOOL)getWorkPeriodEnable{  //获取工作时间段开关
    return config.mWorkPeriod.Enable.Value();
}
- (int)getWorkPeriodSHour{  //获取工作时间段
    return config.mWorkPeriod.SHour.Value();
}
- (int)getWorkPeriodSMinute{  //获取工作时间段
    return config.mWorkPeriod.SMinute.Value();
}
- (int)getWorkPeriodEHour{  //获取工作时间段
    return config.mWorkPeriod.EHour.Value();
}
- (int)getWorkPeriodEMinute{  //获取工作时间段
    return config.mWorkPeriod.EMinute.Value();
}

- (void)setLightBrightness:(int)value { //设置亮度值
    config.Brightness = value;
}
- (void)setMoveTrigLightDuration:(int)value{ //获取自动亮灯时间
    config.mMoveTrigLight.Duration= value;
}
- (void)setMoveTrigLightLevel:(int)value {  //获取自动亮灯灵敏度
    config.mMoveTrigLight.Level = value;
}
- (void)setWorkMode:(NSString*)value{ //获取工作模式
    config.WorkMode= SZSTR(value);
}
- (void)setWorkPeriodEnable:(BOOL)value{  //获取工作时间段开关
    config.mWorkPeriod.Enable = value;
}
- (void)setWorkPeriodSHour:(int)value{  //获取工作时间段
    config.mWorkPeriod.SHour = value;
}
- (void)setWorkPeriodSMinute:(int)value{  //获取工作时间段
    config.mWorkPeriod.SMinute = value;
}
- (void)setWorkPeriodEHour:(int)value{  //获取工作时间段
    return config.mWorkPeriod.EHour = value;
}
- (void)setWorkPeriodEMinute:(int)value{  //获取工作时间段
    return config.mWorkPeriod.EMinute = value;
}
@end
