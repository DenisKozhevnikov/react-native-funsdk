//
//  IPCHumanDetectionConfig.m
//  FunSDKDemo
//
//  Created by zhang on 2019/7/4.
//  Copyright © 2019 zhang. All rights reserved.
//

#import "IPCHumanDetectionConfig.h"
#import "Detect_HumanDetection.h"

@interface IPCHumanDetectionConfig ()
{
    Detect_HumanDetection humanDetection; //人形检测 IPC
}
@end

@implementation IPCHumanDetectionConfig

#pragma mark - 获取人形检测配置
- (void)getHumanDetectionConfig {
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    humanDetection.SetName(JK_Detect_HumanDetection);
    [self AddConfig:[CfgParam initWithName:channel.deviceMac andConfig:&humanDetection andChannel:channel.channelNumber andCfgType:CFG_GET_SET]];
    
    [self GetConfig];
}

#pragma mark - 获取配置回调
-(void)OnGetConfig:(CfgParam *)param{
    [super OnGetConfig:param];
    if ([param.name isEqualToString:[NSString stringWithUTF8String:humanDetection.Name()]]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(IPCHumanDetectionConfigGetResult:)]) {
            [self.delegate IPCHumanDetectionConfigGetResult:param.errorCode];
        }
    }
}

#pragma mark 保存配置回调
- (void)OnSetConfig:(CfgParam *)param {
    if ([param.name isEqualToString:[NSString stringWithUTF8String:humanDetection.Name()]]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(IPCHumanDetectionConfigSetResult:)]) {
            [self.delegate IPCHumanDetectionConfigSetResult:param.errorCode];
        }
    }
}

#pragma mark - 读取人形检测报警功能开关状态
-(int)getHumanDetectEnable{
    return humanDetection.Enable.Value();
}

#pragma mark 读取人形检测报警轨迹开关状态
-(int)getHumanDetectShowTrack{
    return humanDetection.ShowTrack.Value();
}

#pragma mark 读取人形检测报警规则开关状态
-(int)getHumanDetectShowRule{
    return humanDetection.ShowRule.Value();
}

#pragma mark - 设置人形检测报警功能开关状态
-(void)setHumanDetectEnable:(int)enable{
    humanDetection.Enable = enable;
}

#pragma mark 设置人形检测报警轨迹开关状态
-(void)setHumanDetectShowTrack:(int)ShowTrack{
    humanDetection.ShowTrack = ShowTrack;
}

#pragma mark 设置人形检测报警规则开关状态
-(void)setHumanDetectShowRule:(int)showrule{
    humanDetection.ShowRule = showrule;
}
@end
