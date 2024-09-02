//
//  ConfigModel.m
//  XWorld
//
//  Created by liuguifang on 16/5/23.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import "ConfigModel.h"
#import <FunSDK/FunSDK.h>

#import "GTMNSString+HTML.h"
#import "SVProgressHUD.h"

static int seq = 0;

@interface  ConfigModel()

//key格式： configname[channelno][seq]
//value:   DeviceConfig*
@property (nonatomic, strong) NSMutableDictionary* dicConfig;

@end

@implementation ConfigModel
+(instancetype) sharedConfigModel{
    static ConfigModel *sharedConfigModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfigModel = [[ConfigModel alloc] init];
    });
    return sharedConfigModel;
}

-(instancetype)init{
    id obj = [super init];
    self.setTimeout = 10000;
    self.getTimeout = 10000;
    self.dicConfig = [[NSMutableDictionary alloc] initWithCapacity:20];
    return obj;
}

#pragma mark 向设备获取配置
-(int)requestGetConfig:(DeviceConfig*)config{
    return [self requestGetConfig:config withTimeout:self.getTimeout];
}

#pragma mark 向设备获取配置 (带超时时间)
-(int)requestGetConfig:(DeviceConfig*)config withTimeout:(int)timeout{
    NSString* sCfgId = [NSString stringWithFormat:@"%d", seq];
    if ( [self.dicConfig objectForKey:sCfgId] ) {
        [self.dicConfig removeObjectForKey:sCfgId];
    }
    self.dicConfig[sCfgId] = config;
    if(config.nCfgCommand == 0){
        FUN_DevGetConfig_Json(self.msgHandle, CSTR(config.devId), CSTR(config.name), 0, config.channel, timeout, seq);
    }else{
        FUN_DevCmdGeneral(self.msgHandle, CSTR(config.devId), config.nCfgCommand, CSTR(config.name), config.nBinary, timeout, NULL, 0, 0, seq);
    }
    return seq++;
}

#pragma mark 将配置保存至设备
-(int)requestSetConfig:(DeviceConfig*)config{
    return [self requestSetConfig:config withTimeout:self.setTimeout];
}

#pragma mark 将配置保存至设备
-(int)requestSetConfig:(DeviceConfig*)config withTimeout:(int)timeout{
    NSString* sCfgId = [NSString stringWithFormat:@"%d", seq];
    if ( [self.dicConfig objectForKey:sCfgId] ) {
        [self.dicConfig removeObjectForKey:sCfgId];
    }
    self.dicConfig[sCfgId] = config;
    const char* pCfgBuf = config.jObject->ToString();
    config.jLastStrCfg = OCSTR(pCfgBuf);
    if (OCSTR(pCfgBuf).length>0) {
        FUN_DevSetConfig_Json(self.msgHandle, CSTR(config.devId), CSTR(config.name), pCfgBuf, (int)(strlen(pCfgBuf) + 1), config.channel, timeout, seq);
    }else{
        [SVProgressHUD showErrorWithStatus:TS("Data_exception")];
    }
    
    self.setTimeout = 10000;
    return seq++;
}

#pragma mark 取消某个配置的结果接收
-(void)cancelConfig:(int)cfgId{
    NSString* sCfgId = [NSString stringWithFormat:@"%d",cfgId];
    [self.dicConfig removeObjectForKey:sCfgId];
}

#pragma mark FunSDK 结果 
-(void)OnFunSDKResult:(NSNumber *)pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch ( msg->id ) {
#pragma mark - EMSG_DEV_GET_CONFIG_JSON
        case EMSG_DEV_GET_CONFIG_JSON:
        case EMSG_DEV_CMD_EN:
        {
            NSString* sCfgId = [NSString stringWithFormat:@"%d", msg->seq];
            DeviceConfig* config = self.dicConfig[sCfgId];
            
            if ([config.name isEqualToString:@"fVideo.InVolume"]) {
                NSLog(@"");
            }
            if (config) {
                if ( msg->pObject ) {
                    NSString* strName;
                    if ( config.channel >= 0 ) {
                        strName = [NSString stringWithFormat:@"%@.[%ld]", config.name, (long)config.channel];
                    }
                    else{
                        strName = config.name;
                    }
                    if (msg->pObject == NULL) {
                        return;
                    }
                    if ([strName isEqualToString:@"SystemInfo"]) {
//                        AccountModel* accountModel = [AccountModel sharedAccountModel];
//                        Device* dev = [accountModel deviceForId:config.devId];
//                        dev.netType = msg->param2;
                    }

                    if (config.jLastStrCfg == nil) {
                        config.jLastStrCfg = [OCSTR(msg->pObject) gtm_stringByUnescapingFromHTML];
                    }
                
                    NSString *tmpStr = [config.jLastStrCfg stringByReplacingOccurrencesOfString:strName withString:config.name];
    
                    config.jLastStrCfg = tmpStr;
                    if ( config.jObject ) {
                        config.jObject->Parse(CSTR(config.jLastStrCfg));
                    }
                }
                if (config == nil || msg == NULL) {
                    return;
                }
                
                if ([config.name isEqualToString:@"Detect.MotionDetect"]) {
                    NSLog(@"");
                }
                [config.delegate getConfig:config result:msg->param1];
                [self.dicConfig removeObjectForKey:sCfgId];
            }
        }
            break;
#pragma mark - EMSG_DEV_SET_CONFIG_JSON
            case EMSG_DEV_SET_CONFIG_JSON:
        {
            NSString* sCfgId = [NSString stringWithFormat:@"%d", msg->seq];
            DeviceConfig* config = self.dicConfig[sCfgId];
            if (config) {
                if (config.delegate && [config.delegate respondsToSelector:@selector(setConfig:result:)]) {
                    [config.delegate setConfig:config result:msg->param1];
                    [self.dicConfig removeObjectForKey:sCfgId];
                }
                
            }
        }
            break;
            
        default:
            break;
    }
}


@end
