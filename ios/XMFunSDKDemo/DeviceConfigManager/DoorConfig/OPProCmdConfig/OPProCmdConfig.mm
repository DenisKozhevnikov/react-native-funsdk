//
//  OPProCmdConfig.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/12.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "OPProCmdConfig.h"
#import "Consumer_DoorLock.h"

@interface OPProCmdConfig ()
{
    JObjArray<Consumer_DoorLock> config;        //获取门锁信息配置
}
@end

@implementation OPProCmdConfig
- (BOOL)checkConfig {
    if (config.Size()  == 0) {
        return NO;         }
    return YES;
}
#pragma mark - 获取门锁统计开关信息
- (void)getOPProCmdConfig {
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    config.SetName(JK_Consumer_DoorLock);
    [self AddConfig:[CfgParam initWithName:channel.deviceMac andConfig:&config andChannel:-1 andCfgType:CFG_GET_SET]];
    
    [self GetConfig];
}
#pragma mark 设置门锁统计开关信息
- (void)setOPProCmdConfig {
    [self SetConfig];
}


#pragma mark - 获取配置回调
-(void)OnGetConfig:(CfgParam *)param{
    [super OnGetConfig:param];                                                                       
    if ([param.name isEqualToString:[NSString stringWithUTF8String:config.Name()]]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(OPProCmdConfigGetResult:)]) {
            [self.delegate OPProCmdConfigGetResult:param.errorCode];
        }
    }
}
#pragma mark  保存配置回调
-(void)OnSetConfig:(CfgParam *)param{
    if ([param.name isEqualToString:NSSTR(config.Name())]) {
        if ([self.delegate respondsToSelector:@selector(OPProCmdConfigSetResult:)]) {
            [self.delegate OPProCmdConfigSetResult:param.errorCode];
        }
    }
}
#pragma mark - 读取门锁信息中，消息统计开关
- (BOOL)getMessageCmdValue {
    return config[0].mMessageStatistics.Enable.Value();
}

#pragma mark 设置门锁信息中，消息统计开关
- (void)setMessageCmdValue:(BOOL)enable {
    config[0].mMessageStatistics.Enable = enable;
}
@end
