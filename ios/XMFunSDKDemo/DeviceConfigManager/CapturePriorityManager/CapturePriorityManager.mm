//
//  CapturePriorityManager.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/20.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "CapturePriorityManager.h"
#import "WorkMode_CapturePriority.h"
#import "DeviceConfig.h"

@interface CapturePriorityManager () <DeviceConfigDelegate>
{
    WorkMode_CapturePriority jWorkMode_CapturePriority;  //拍照优先配置
}
@end

@implementation CapturePriorityManager

//MARK:请求拍照优先配置
- (void)requestCapturePriorityCfg:(NSString *)devID completion:(GetCapturePriorityCallBack)callBack{
    self.getCapturePriorityCallBack = callBack;
    self.devID = devID;
    
    DeviceConfig *devCfg = [[DeviceConfig alloc] initWithJObject:&jWorkMode_CapturePriority];
    devCfg.devId = self.devID;
    devCfg.channel = -1;
    devCfg.isGet = YES;
    devCfg.delegate = self;
    [self requestGetConfig:devCfg];
}

//MAKR:保存拍照优先配置
- (void)saveCapturePriorityCfgCompletion:(SetCapturePriorityCallBack)callBack{
    self.setCapturePriorityCallBack = callBack;
    
    DeviceConfig *devCfg = [[DeviceConfig alloc] initWithJObject:&jWorkMode_CapturePriority];
    devCfg.devId = self.devID;
    devCfg.channel = -1;
    devCfg.isSet = YES;
    devCfg.delegate = self;
    [self requestSetConfig:devCfg];
}

//MARK:获取设置拍照优先配置
- (int)getCapturePriorityType{
    if (!self.requested) {
        return 0;
    }
    
    return jWorkMode_CapturePriority.Type.Value();
}

- (void)setCapturePriorityType:(int)type{
    if (!self.requested) {
        return;
    }
    
    jWorkMode_CapturePriority.Type.SetValue(type);
}

//MARK: - Delegate
- (void)getConfig:(DeviceConfig *)config result:(int)result{
    if ([config.name isEqualToString:OCSTR(JK_WorkMode_CapturePriority)])
    {
        if (result >= 0) {
            self.requested = YES;
        }
        
        if (self.getCapturePriorityCallBack) {
            self.getCapturePriorityCallBack(result);
        }
    }
}

- (void)setConfig:(DeviceConfig *)config result:(int)result{
    if ([config.name isEqualToString:OCSTR(JK_WorkMode_CapturePriority)])
    {
        if (self.setCapturePriorityCallBack) {
            self.setCapturePriorityCallBack(result);
        }
    }
}

@end
