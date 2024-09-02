//
//  ChannelTitleConfig.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2020/10/26.
//  Copyright © 2020 wujiangbo. All rights reserved.
//

#import "ChannelTitleConfig.h"
#import "DeviceConfig.h"

@implementation ChannelTitleConfig
{
    AVEnc_VideoWidget widgetCfg;//通道名称
}

#pragma mark - 获取设置
- (void)getLogoConfigWithChannel:(int)channel{
    //获取通道
    ChannelObject *channelObject = [[DeviceControl getInstance] getSelectChannel];
    
    [self AddConfig:[CfgParam initWithName:channelObject.deviceMac andConfig:&widgetCfg andChannel:channel andCfgType:CFG_GET_SET]];
    
    [self GetConfig];
}

#pragma mark - 保存设置
- (void)setLogoConfig{
    //发送保存配置的请求
    [SVProgressHUD show];
    [self SetConfig];
}

#pragma mark 获取配置回调信息
-(void)OnGetConfig:(CfgParam *)param {
    [SVProgressHUD dismiss];
    if ([param.name isEqualToString:[NSString stringWithUTF8String:widgetCfg.Name()]]){
        if ([self.delegate respondsToSelector:@selector(getChannelTitleConfigResult:)]) {
            [self.delegate getChannelTitleConfigResult:param.errorCode];
        }
    }
}

#pragma mark 保存配置回调信息
- (void)OnSetConfig:(CfgParam *)param {
    [SVProgressHUD dismiss];
    if ([param.name isEqualToString:[NSString stringWithUTF8String:widgetCfg.Name()]]){
       if ([self.delegate respondsToSelector:@selector(setChannelTitleConfigResult:)]) {
           [self.delegate setChannelTitleConfigResult:param.errorCode];
       }
    }
}


#pragma mark - 读取通道名称
- (NSString*)readLogoTitle {
    return NSSTR(widgetCfg.mChannelTitle.Name.Value());
}

#pragma mark 设置通道名称
- (void)setLogoTitle:(NSString *)title{
    const char *name = [title UTF8String];
    widgetCfg.mChannelTitle.Name = name;
}

@end
