//
//  SensorConfig.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/4/10.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "SensorConfig.h"
#import <FunSDK/FunSDK.h>

@implementation SensorConfig

#pragma mark - get sensor list
- (void)getSensorList{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    /*
    请求传感器列表
    get sensor list from camera
    */
    
    char cfg[1024];
    sprintf(cfg, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"GetAllDevList\", \"Arg1\" : \"\", \"Arg2\" : \"\"} }");
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 2046, "GetAllDevList", 0, \
                      20000, (char *)cfg, (int)strlen(cfg) + 1, -1, 0);
}

#pragma mark - begin adding sensor
- (void)beginAddSensor{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    /*
     使摄像机进入配对状态(此时需要连按传感器设置按钮5次 具体次数看说明书)
     make camera into receive sensor config state(you need to fast click button on sensor ,for more detail check on Instruction manual)
     */
    
    char cfg[1024];
    sprintf(cfg, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"StartAddDev\", \"Arg1\" : \"60000\", \"Arg2\" : \"\"} }");
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 2046, "StartAddDev", 4096, \
                      60000, (char *)cfg, (int)strlen(cfg) + 1, -1, 0);
}

#pragma mark - stop adding sensor
- (void)stopAddSensor{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    /*
     使摄像机停止配对状态
     make camera deny receive sensor config state
     */
    
    char cfg[] = "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"StopAddDev\", \"Arg1\" : \"\", \"Arg2\" : \"\"} }";
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 2046, "StopAddDev", 4096, \
                      5000, (char *)cfg, (int)strlen(cfg) + 1, -1, 0);
}

#pragma mark - delete added sensor
- (void)beginDeleteSensor:(NSString *)devID{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    /*
     删除已经添加的传感器
     delete added sensor
    */
    
    char cfg[1024];
    sprintf(cfg, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"DeleteDev\", \"Arg1\" : \"%s\", \"Arg2\" : \"\"} }", [devID UTF8String]);
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 2046, "DeleteDev", 4096, 5000, (char *)cfg, (int)strlen(cfg) + 1, -1, 0);
}

#pragma mark - change sensor name in list
- (void)changeSensorName:(NSString *)name sensorID:(NSString *)devID{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    /*
     修改传感器在列表中的名字
     change sensor name in list
     */
    
    char cfg[1024];
    sprintf(cfg, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"ChangeDevName\", \"Arg1\" : \"%s\", \"Arg2\" : \"%s\"} }", [devID UTF8String], [name UTF8String]);
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 2046, "ChangeDevName", 4096, 5000, (char *)cfg, (int)strlen(cfg) + 1, -1, 0);
}

#pragma mark - control sensor push status
- (void)beginChangeStatueOpen:(BOOL)ifOpen devID:(NSString *)devID{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    /*
     控制传感器是否退消息给摄像机,关闭不会触发报警消息.
     control sensor push status(this value meas alarm message will send to camera .Only keep it open (Status = 1) ,you can get push message.)
     */
    
    [SVProgressHUD showWithStatus:@"Changing sensor statue...."];
    char cfg[1024];
    sprintf(cfg, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"ChangeDevStatus\", \"Arg1\" : \"%s\", \"Arg2\" : {\"sceneId\":\"%s\", \"status\":%d}} }", [devID UTF8String], [devID UTF8String], ifOpen ? 1 : 0);
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 2046, "ChangeDevStatus", 4096, 5000, (char *)cfg, (int)strlen(cfg) + 1, -1, 0);
}

#pragma mark - get camera scene mode
- (void)beginGetSceneMode{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    /*
     获取摄像机支持的场景模式(例如：在家 离家，不同模式处理不同事件标准不一样，在家就不会触发一些报警)
     Get the camera scene mode supported (for example: at home or away from home, different modes handle different event standards, and will not trigger some alarms at home)
     */
    char cfg3[1024];
    sprintf(cfg3, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"GetModeConfig\", \"Arg1\" : \"\", \"Arg2\" : \"\"} }");
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 2046, "GetModeConfig", 0, \
                      20000, (char *)cfg3, (int)strlen(cfg3) + 1, -1, 0);
}

#pragma mark - change camera scene mode
- (void)beginChangeMode:(NSString *)modeID{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    /*
     切换摄像机场景模式
     exchange camera scene mode
     */
    
    char cfg[1024];
    sprintf(cfg, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"ChangeMode\", \"Arg1\" : \"%s\", \"Arg2\" : \"\"} }", [modeID UTF8String]);
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 2046, "ChangeMode", 4096, 5000, (char *)cfg, (int)strlen(cfg) + 1, -1, 0);
}

#pragma mark - get sensor online status
- (void)requestSensorState:(NSString *)sensorID{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    /*
     获取传感器在线状态（相对于摄像机来说，只有在线了才可以进一步请求具体状态信息）
     Get sensor online status(Compared to the camera, only the online can request further status information)
     */
    
    char cfg[1024];
    sprintf(cfg, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"GetLinkState\", \"Arg1\" : \"%s\", \"Arg2\" : \"%s\"} }", [channel.deviceMac UTF8String], [sensorID UTF8String]);
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 2046, "GetLinkState", 4096, 5000, (char *)cfg, (int)strlen(cfg) + 1, -1, 0);
}

#pragma mark - get detail status
- (void)requestSensorDetailStatus:(NSString *)sensorID{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    /*
     requestSensorState 回调在线后才能获取这个具体状态,根据这个在界面上显示是否在线
     The requestSensorState callback is online to get this specific status. According to this, it is displayed online on the interface.
     */
    char cfg2[1024];
    sprintf(cfg2, "{ \"Name\" : \"OPConsumerProCmd\", \"SessionID\" : \"0x00000002\", \"OPConsumerProCmd\" : {\"Cmd\" : \"InquiryStatus\", \"Arg1\" : \"%s\", \"Arg2\" : \"\"} }", [sensorID UTF8String]);
    FUN_DevCmdGeneral(self.msgHandle, [channel.deviceMac UTF8String], 2046, "InquiryStatus", 4096, 5000, (char *)cfg2, (int)strlen(cfg2) + 1, -1, 0);
}

@end
