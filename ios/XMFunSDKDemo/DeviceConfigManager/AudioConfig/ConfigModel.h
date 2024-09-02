//
//  ConfigModel.h
//  XWorld
//  设备配置相关model
//  Created by liuguifang on 16/5/23.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import "FunMsgListener.h"
#import "DeviceConfig.h"

@interface ConfigModel : FunMsgListener

@property (nonatomic) int getTimeout;
@property (nonatomic) int setTimeout;

+(instancetype) sharedConfigModel;

#pragma mark 向设备获取配置
-(int)requestGetConfig:(DeviceConfig*)config;

#pragma mark 向设备获取配置 (带超时时间)
-(int)requestGetConfig:(DeviceConfig*)config withTimeout:(int)timeout;

#pragma mark 将配置保存至设备
-(int)requestSetConfig:(DeviceConfig*)config;

#pragma mark 将配置保存至设备
-(int)requestSetConfig:(DeviceConfig*)config withTimeout:(int)timeout;

#pragma mark 取消某个配置的结果接收
-(void)cancelConfig:(int)cfgId;

@end
