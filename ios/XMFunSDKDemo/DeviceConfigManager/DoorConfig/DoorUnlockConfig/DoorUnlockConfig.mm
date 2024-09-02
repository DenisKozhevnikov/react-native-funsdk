//
//  DoorUnlockConfig.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/9.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "DoorUnlockConfig.h"
#import "Consumer_IsDoorLockAdded.h"
#import "FunSDK/FunSDK.h"

@interface DoorUnlockConfig ()
{
    Consumer_IsDoorLockAdded doorConfig;   //远程开锁
}
@end

@implementation DoorUnlockConfig

//获取门锁远程开锁的doorUnlockID，调用前需要先判断远程开锁能力级
- (void)getDoorUnlockIDConfig {
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    [self AddConfig:[CfgParam initWithName:channel.deviceMac andConfig:&doorConfig andChannel:-1 andCfgType:CFG_GET_SET]];
    
    [self GetConfig];
}

//远程开锁
- (void)setDoorUnlock:(NSString*)password {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    char cfg[1024];
    sprintf(cfg, "{ \"Name\" : \"OPDoorLockProCmd\", \"SessionID\" : \"0x00000002\", \"OPDoorLockProCmd\" : {\"Cmd\" : \"RemoteUnlock\", \"Arg1\" : \"%s\", \"Arg2\" : \"%s\"} }", doorConfig.DoorLockID[0].Value(), SZSTR(password));
    FUN_DevCmdGeneral(self.MsgHandle, SZSTR(channel.deviceMac), 2046, "RemoteUnlock", 4096, 15000, (char *)cfg, (int)strlen(cfg) + 1, -1, 0);
}
#pragma mark - 获取配置回调
-(void)OnGetConfig:(CfgParam *)param{
    [super OnGetConfig:param];
    if ([param.name isEqualToString:[NSString stringWithUTF8String:doorConfig.Name()]]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(DoorUnlockConfigGetResult:)]) {
            [self.delegate DoorUnlockConfigGetResult:param.errorCode];
        }
    }
}

#pragma mark - FUNSDK 回调
-(void)OnFunSDKResult:(NSNumber *) pParam{
    [super OnFunSDKResult:pParam];
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:{
            if ([self.delegate respondsToSelector:@selector(DoorUnlockConfigSetResult:)]) {
                [self.delegate DoorUnlockConfigSetResult:msg->param1];
            }
        }
            break;
    }
}
@end
