//
//  HumanDetectionConfig.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/12/27.
//  Copyright © 2018 wujiangbo. All rights reserved.
//

#import "AlarmPIRConfig.h"
#import "Alarm_PIR.h"

@implementation AlarmPIRConfig
{
    JObjArray <Alarm_PIR> jAlarm_PIR; //徘徊检测录像时长
}
#pragma mark - 获取徘徊检测配置
-(void)getAlarmPIRConfig{
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    jAlarm_PIR.SetName(JK_Alarm_PIR);
     CfgParam* param = [[CfgParam alloc] initWithName:[NSString stringWithUTF8String:JK_Alarm_PIR] andDevId:channel.deviceMac andChannel:-1 andConfig:&jAlarm_PIR andOnce:YES andSaveLocal:NO];
    [self AddConfig:param];
    [self GetConfig];
}

#pragma mark - 获取配置回调
-(void)OnGetConfig:(CfgParam *)param{
    [super OnGetConfig:param];
    if ([param.name isEqualToString:[NSString stringWithUTF8String:JK_Alarm_PIR]]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(AlarmPIRConfigGetResult:)]) {
            [self.delegate AlarmPIRConfigGetResult:param.errorCode];
        }
    }
}

#pragma mark 保存配置回调
- (void)OnSetConfig:(CfgParam *)param {
     if ([param.name isEqualToString:[NSString stringWithUTF8String:JK_Alarm_PIR]]){
         if (self.delegate && [self.delegate respondsToSelector:@selector(AlarmPIRConfigSetResult:)]) {
             [self.delegate AlarmPIRConfigSetResult:param.errorCode];
         }
     }
}

#pragma mark - 读取徘徊检测报警功能开关状态
-(BOOL)getAlarmPIREnable{
    if (jAlarm_PIR.Size() >0) {
        return jAlarm_PIR[0].Enable.Value();
    }
    return 0;
}

#pragma mark - 读取徘徊检测时间长度
-(int)getAlarmPIRCheckTime{
    if (jAlarm_PIR.Size() >0) {
        return jAlarm_PIR[0].PIRCheckTime.Value();
    }
    return 0;
}

//MARK: 取出徘徊检测灵敏度（PIR灵敏度）
- (int)getAlarmPirSensitive{
    if (jAlarm_PIR.Size() > 0) {
        return jAlarm_PIR[0].PirSensitive.Value();
    }
    return 0;
}

//MARK: 取出徘徊检测录像时长
- (int)getAlarmRecordLength{
    if (jAlarm_PIR.Size() > 0) {
        return jAlarm_PIR[0].mEventHandler.RecordLatch.Value();
    }
    return 0;
}

#pragma mark - 设置徘徊检测报警功能开关状态
-(void)setAlarmPIREnable:(BOOL)enable{
    if (jAlarm_PIR.Size() >0) {
         jAlarm_PIR[0].Enable = enable;
    }
}

#pragma mark - 设置徘徊检测时间长度
-(void)setAlarmPIRCheckTime:(int)enable{
    if (jAlarm_PIR.Size() >0) {
        jAlarm_PIR[0].PIRCheckTime = enable;
    }
    //设置默认录像时长30秒
    [self setAlarmRecordLength:30];
}

#pragma mark - 设置徘徊检测灵敏度
-(void)setAlarmPirSensitive:(int)enable{
    //灵敏度 1是最低的 5是最高的
    if (jAlarm_PIR.Size() >0) {
        jAlarm_PIR[0].PirSensitive = enable;
    }
}

//MARK: 设置徘徊检测录像时长
- (void)setAlarmRecordLength:(int)lenght{
    if (jAlarm_PIR.Size() > 0) {
        jAlarm_PIR[0].mEventHandler.RecordLatch.SetValue(lenght);
    }
}

@end
