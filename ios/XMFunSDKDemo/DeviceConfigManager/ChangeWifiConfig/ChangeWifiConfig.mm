//
//  ChangeWifiConfig.m
//  FunSDKDemo
//
//  Created by zhang on 2019/6/12.
//  Copyright © 2019 zhang. All rights reserved.
//

#import "ChangeWifiConfig.h"
#import <FunSDK/FunSDK.h>
#import "NetWork_Wifi.h"
@interface ChangeWifiConfig ()
{
    NetWork_Wifi networkWifi;
    NSMutableArray *wifiArray;
}
@end
@implementation ChangeWifiConfig

#pragma mark 获取设备Wi-Fi信息
- (void)getNetWorkWifiConfig {
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    networkWifi.SetName(JK_NetWork_Wifi);
    CfgParam* param = [[CfgParam alloc] initWithName:[NSString stringWithUTF8String:JK_NetWork_Wifi] andDevId:channel.deviceMac andChannel:-1 andConfig:&networkWifi andOnce:YES andSaveLocal:NO];
    [self AddConfig:param];
    [self GetConfig];
}

#pragma mark 获取设备Wi-Fi列表
- (void)getWifiListArrayConfig {
    if (wifiArray == nil) {
        wifiArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    FUN_DevCmdGeneral(self.MsgHandle, SZSTR(channel.deviceMac), 1020, "WifiAP", 0, 20000, NULL, 0, -1, 0);
}

#pragma mark 把设备设置成AP模式
- (void)changeToAPModel {
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    char szParam[128] = {0};
    sprintf(szParam, "{\"Name\":\"OPNetModeSwitch\",\"OPNetModeSwitch\":{\"Action\":\"ToAP\"}}");
    FUN_DevCmdGeneral(self.MsgHandle, SZSTR(channel.deviceMac), 1450, "OPNetModeSwitch", 0, 5000, szParam, 0);
}

#pragma mark 获取设备Wi-Fi信息回调
- (void)OnGetConfig:(CfgParam *)param {
    if ([param.name isEqualToString:[NSString stringWithUTF8String:JK_NetWork_Wifi]]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(getNetWorkWifiConfigResult:)]) {
            [self.delegate getNetWorkWifiConfigResult:param.errorCode];
        }
    }
}


-(void)OnFunSDKResult:(NSNumber *)pParam{
    [super OnFunSDKResult:pParam];
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN: {
            
            if (strcmp(msg->szStr, "WifiAP") == 0){
                if (msg->param1<0) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(getWifiArrayConfigResult:)]) {
                        [self.delegate getWifiArrayConfigResult:msg->param1];
                    }
                    return;
                }
                char *result = (char *)msg->pObject;
                if (result == nil || strlen(result) == 0) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(getWifiArrayConfigResult:)]) {
                        [self.delegate getWifiArrayConfigResult:msg->param1];
                    }
                    return;
                }
                // 2.0 将c的jason字符串转化为NSData
                NSData *resultData = [NSData dataWithBytes:result length:strlen(result)];
                if (resultData == nil) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(getWifiArrayConfigResult:)]) {
                        [self.delegate getWifiArrayConfigResult:msg->param1];
                    }
                    return;
                }
                // 3.0 将NSData转化为字典
                NSError *error;
                NSMutableDictionary *socketInfoDic = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
                if ([socketInfoDic objectForKey:@"WifiAP"]) {
                    NSDictionary *wifiInfo = [socketInfoDic objectForKey:@"WifiAP"];
                    if (wifiInfo) {
                        NSArray *wifiMessage = [wifiInfo   objectForKey:@"WifiAP"];
                        
                        for (int i = 0; i<wifiMessage.count; i++) {
                            NSDictionary *wifiObj = [wifiMessage objectAtIndex:i];
                            WifiConfigDataSource *datasource = [[WifiConfigDataSource alloc] init];
                            datasource.SSID = [wifiObj objectForKey:@"SSID"];
                            datasource.RSSI = [[wifiObj objectForKey:@"RSSI"] intValue];
                            datasource.Auth = [wifiObj objectForKey:@"Auth"];
                            datasource.EncrypType = [wifiObj objectForKey:@"EncrypType"];
                            datasource.NetType = [wifiObj objectForKey:@"NetType"];
                            datasource.Channel = [[wifiObj objectForKey:@"Channel"] intValue];
                            [wifiArray addObject:datasource.SSID];
                        }
                    }
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(getWifiArrayConfigResult:)]) {
                    [self.delegate getWifiArrayConfigResult:msg->param1];
                }
            }
            
            if (strcmp(msg->szStr, "OPNetModeSwitch") == 0){
                if (msg->param1>=0) {
                    //设置AP模式成功
                }else{
                    //失败
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(setAPModelConfigResult:)]) {
                    [self.delegate setAPModelConfigResult:msg->param1];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (NSString*)getWifiSSID {
    return NSSTR(networkWifi.SSID.Value());
}
- (NSString*)getWifiPassword {
    return NSSTR(networkWifi.Keys.Value());
}

#pragma mark 读取请求到的设备附近Wi-Fi列表信息
- (NSMutableArray *)getWifiArray {
    return wifiArray;
}
@end
