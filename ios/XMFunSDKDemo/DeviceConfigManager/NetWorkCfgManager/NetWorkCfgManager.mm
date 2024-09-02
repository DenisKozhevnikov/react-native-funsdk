//
//  NetWorkCfgManager.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/20.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "NetWorkCfgManager.h"
#import "NetWork_SetEnableVideo.h"
#import "DeviceConfig.h"

@interface NetWorkCfgManager () <DeviceConfigDelegate>
{
    NetWork_SetEnableVideo jNetWork_SetEnableVideo;  //录像本地开关配置
}

@end

@implementation NetWorkCfgManager

//MARK:请求录像本地开关配置
- (void)requestNetWorkSetEnableVideoCfg:(NSString *)devID completion:(GetNetWorkCfgSetEnableVideoCallBack)callBack{
    self.getNetWorkCfgSetEnableVideoCallBack = callBack;
    self.devID = devID;
    
    DeviceConfig *devCfg = [[DeviceConfig alloc] initWithJObject:&jNetWork_SetEnableVideo];
    devCfg.devId = self.devID;
    devCfg.channel = -1;
    devCfg.isGet = YES;
    devCfg.delegate = self;
    [self requestGetConfig:devCfg];
}

//MAKR:保存录像本地开关配置
- (void)saveNetWorkSetEnableVideoCfgCompletion:(SetNetWorkCfgSetEnableVideoCallBack)callBack{
    self.setNetWorkCfgSetEnableVideoCallBack = callBack;
    
    DeviceConfig *devCfg = [[DeviceConfig alloc] initWithJObject:&jNetWork_SetEnableVideo];
    devCfg.devId = self.devID;
    devCfg.channel = -1;
    devCfg.isSet = YES;
    devCfg.delegate = self;
    [self requestSetConfig:devCfg];
}

//MARK:获取设置本地录像开关状态
- (BOOL)getNetWorkSetEnableVideoEnabled{
    if (!self.requested) {
        return NO;
    }
    return jNetWork_SetEnableVideo.Enable.Value();
}

- (void)setNetWorkSetEnableVideoEnable:(BOOL)enable{
    if (!self.requested) {
        return;
    }
    jNetWork_SetEnableVideo.Enable.SetValue(enable);
}

//MARK: - Delegate
- (void)getConfig:(DeviceConfig *)config result:(int)result{
    if ([config.name isEqualToString:OCSTR(JK_NetWork_SetEnableVideo)])
    {
        if (result >= 0) {
            self.requested = YES;
        }
        
        if (self.getNetWorkCfgSetEnableVideoCallBack) {
            self.getNetWorkCfgSetEnableVideoCallBack(result);
        }
    }
}

- (void)setConfig:(DeviceConfig *)config result:(int)result{
    if ([config.name isEqualToString:OCSTR(JK_NetWork_SetEnableVideo)])
    {
        if (self.setNetWorkCfgSetEnableVideoCallBack) {
            self.setNetWorkCfgSetEnableVideoCallBack(result);
        }
    }
}

@end
