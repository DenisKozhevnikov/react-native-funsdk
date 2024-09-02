//
//  NoDisturbingConfig.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/15.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "NoDisturbingConfig.h"
#import "Consumer_NoDisturbing.h"

@interface NoDisturbingConfig ()
{
    Consumer_NoDisturbing config; //免打扰管理
}
@end

@implementation NoDisturbingConfig

#pragma mark - 获取免打扰管理信息
- (void)getNoDisturbingConfig {
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    [self AddConfig:[CfgParam initWithName:channel.deviceMac andConfig:&config andChannel:-1 andCfgType:CFG_GET_SET]];
    
    [self GetConfig];
}
#pragma mark 设置免打扰管理信息
- (void)setNoDisturbingConfig {
    [self SetConfig];
}


#pragma mark - 获取配置回调
-(void)OnGetConfig:(CfgParam *)param{
    [super OnGetConfig:param];
    if ([param.name isEqualToString:[NSString stringWithUTF8String:config.Name()]]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(NoDisturbingConfigGetResult:)]) {
            [self.delegate NoDisturbingConfigGetResult:param.errorCode];
        }
    }
}
#pragma mark  保存配置回调
-(void)OnSetConfig:(CfgParam *)param{
    if ([param.name isEqualToString:NSSTR(config.Name())]) {
        if ([self.delegate respondsToSelector:@selector(NoDisturbingConfigSetResult:)]) {
            [self.delegate NoDisturbingConfigSetResult:param.errorCode];
        }
    }
}


#pragma mark - 读取免打扰开关
- (BOOL)getNoDisturbingEnable {
    return config.EnableDnd.Value();
}
#pragma mark  读取消息推送开关
- (BOOL)getMessageEnable {
    return config.MessageDnd.Value();
}
#pragma mark  读取深度休眠开关
- (BOOL)getSleepEnable {
    return config.DeepSleepDnd.Value();
}
#pragma mark  读取免打扰开始时间
- (NSString*)getStartTime {
    return NSSTR(config.StartTime.Value()) ;
}
#pragma mark  读取免打扰结束时间
- (NSString*)getEndTime {
    return NSSTR(config.EndTime.Value()) ;
}

#pragma mark - 设置免打扰开关
- (void)setNoDisturbingEnable:(BOOL)enable {
    config.EnableDnd = enable;
}
#pragma mark  设置消息推送开关
- (void)setMessageEnable:(BOOL)enable {
    config.MessageDnd = enable;
}
#pragma mark  设置深度休眠开关
- (void)setSleepEnable:(BOOL)enable {
    config.DeepSleepDnd = enable;
}
#pragma mark  设置免打扰开始时间
- (void)setStartTime:(NSString*)time {
    config.StartTime = SZSTR(time);
}
#pragma mark  设置免打扰结束时间
- (void)setEndTime:(NSString*)time {
    config.EndTime = SZSTR(time);
}
@end
