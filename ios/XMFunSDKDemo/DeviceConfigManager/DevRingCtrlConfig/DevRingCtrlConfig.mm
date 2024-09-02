//
//  DevRingCtrlConfig.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/5/7.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "DevRingCtrlConfig.h"
#import <FunSDK/FunSDK.h>

@interface DevRingCtrlConfig ()

@property (nonatomic,assign) int msgHandle;

@property (nonatomic,assign) BOOL devRingControlEnable;

@end

@implementation DevRingCtrlConfig

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
    }
    
    return self;
}

- (void)myGetConfig{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    FUN_DevGetConfig_Json(self.msgHandle, [channel.deviceMac UTF8String], "Consumer.DevRingControl", 1024);
}

- (void)mySetConfig{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    NSDictionary* jsonDic = @{@"Enable":[NSNumber numberWithBool:self.devRingControlEnable]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, [channel.deviceMac UTF8String], "Consumer.DevRingControl", [pCfgBufString UTF8String], (int)(strlen([pCfgBufString UTF8String]) + 1), -1, 10000, self.devRingControlEnable ? 1 : 0);
}

//MARK: 获取开关状态
- (BOOL)getEnable{
    return self.devRingControlEnable;
}

//AMRK: 设置开关状态
- (void)setEnable:(BOOL)enable{
    self.devRingControlEnable = enable;
}

-(void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_SET_CONFIG_JSON:
        {
            if ([[NSString stringWithUTF8String:(msg->szStr)] isEqualToString:@"Consumer.DevRingControl"]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(setDevRingCtrlConfigResult:)]) {
                    [self.delegate setDevRingCtrlConfigResult:msg->param1];
                }
            }
        }
            break;
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if ([[NSString stringWithUTF8String:(msg->szStr)] isEqualToString:@"Consumer.DevRingControl"]) {
                if (msg->param1 >= 0) {
                    NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    
                    NSError *error;
                    NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                    if (!retDic) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(getDevRingCtrlConfigResult:)]) {
                            [self.delegate getDevRingCtrlConfigResult:-1];
                        }
                        return;
                    }
                    
                    NSDictionary *dic = [retDic objectForKey:@"Consumer.DevRingControl"];
                    self.devRingControlEnable = [[dic objectForKey:@"Enable"] boolValue];
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(getDevRingCtrlConfigResult:)]) {
                    [self.delegate getDevRingCtrlConfigResult:msg->param1];
                }
            }
        }
            break;
            default:
            break;
    }
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

@end
