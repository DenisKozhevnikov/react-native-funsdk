//
//  ShutDownTimeConfig.m
//  FunSDKDemo
//
//  Created by XM on 2019/3/18.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "ShutDownTimeConfig.h"

@implementation ShutDownTimeConfig


//获取设备休眠时间
-(void)getShutDownTime {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    FUN_DevCmdGeneral(self.msgHandle, SZSTR(channel.deviceMac), 1042, "System.ManageShutDown", 0, 5000, NULL, 0, -1, 2);
}

//设置休眠时间
-(void)setSutDownTime:(int)shutDownTime {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    char szCfg[512] = {0};  
    sprintf(szCfg, "{ \"Name\":\"System.ManageShutDown\",\"System.ManageShutDown\" : {\"ShutDownMode\":%d}}", shutDownTime);
    FUN_DevCmdGeneral(self.msgHandle, SZSTR(channel.deviceMac), 1040, "System.ManageShutDown", 0, 5000, szCfg, (int)strlen(szCfg), -1, 0);
}

- (void)setDeviceSleep{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    FUN_DevSleep(self.msgHandle, SZSTR(channel.deviceMac), 0);
    FUN_DevLogout(0, SZSTR(channel.deviceMac));

}

- (void)setDevicewake{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    FUN_DevWakeUp(self.msgHandle, SZSTR(channel.deviceMac), 0);

}


-(void)OnFunSDKResult:(NSNumber *)pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    if(msg->param3 == 1040) {
        if ([self.delegate respondsToSelector:@selector(getShutDownTimeConfigResult:)]) {
            [self.delegate setShutDownTimeConfigResult:msg->param1];
        }
    }
    if(msg->param3 == 1042) {
        if (msg->param1 >= 0) {
            NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
            NSError *error;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
            self.time = [jsonDic[@"System.ManageShutDown"][@"ShutDownMode"] intValue];
            if (self.time <= 0 ) {
                self.time = 15;
            }
        }
        if ([self.delegate respondsToSelector:@selector(setShutDownTimeConfigResult:)]) {
            [self.delegate getShutDownTimeConfigResult:msg->param1];
        }
    }
    if (msg->id == EMSG_DEV_SLEEP) {
        if (msg->param1 < 0)
        {
            [MessageUI ShowErrorInt:(msg->param1)];
            NSLog(@"+++设置休眠失败");
            if ([self.delegate respondsToSelector:@selector(recyleSleepAndWakeup)]) {
                [self.delegate recyleSleepAndWakeup];
            }
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"设置休眠成功"];
            if ([self.delegate respondsToSelector:@selector(recyleSleepAndWakeup)]) {
                [self.delegate recyleSleepAndWakeup];
            }
            NSLog(@"+++设置休眠成功");


        }
    }
    
    if (msg->id == EMSG_DEV_WAKE_UP) {
        if (msg->param1 < 0)
        {
            [MessageUI ShowErrorInt:(msg->param1)];
            NSLog(@"+++设置唤醒失败");
           
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"设置唤醒成功"];
            NSLog(@"+++设置唤醒成功");

        }
    }
    
//    if (msg->id == EMSG_DEV_WAKE_UP) {
//        if (msg->param1 < 0)
//        {
//            [MessageUI ShowErrorInt:(msg->param1)];
//
//        }
//        else
//        {
//            [SVProgressHUD showSuccessWithStatus:@"设置唤醒成功"];
//
//
//        }
//    }
}

@end
