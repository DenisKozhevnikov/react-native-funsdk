//
//  AlarmDetectConfig.m
//  FunSDKDemo
//
//  Created by XM on 2018/5/18.
//  Copyright © 2018年 XM. All rights reserved.
//
/***
 
 设备报警配置
 Detect_MotionDetect 移动侦测配置
 Detect_BlindDetect  视频遮挡配置
 Detect_LossDetect  视频丢失配置
 
 *****/

#import "AlarmDetectConfig.h"
#import "Detect_MotionDetect.h"
#import "Detect_BlindDetect.h"
#import "Detect_LossDetect.h"
#import "FunSDK/FunSDK.h"

@interface AlarmDetectConfig () {
}
@property (nonatomic, assign) Detect_BlindDetect blindCfg; //视频遮挡数据对象
@property (nonatomic, assign) Detect_LossDetect lossCfg;//视频丢失数据对象
@property (nonatomic, assign) Detect_MotionDetect motionCfg;//移动侦测数据对象

@property (nonatomic, strong) NSMutableDictionary *PMSDic;
@property (nonatomic, assign) int pushInterval;//报警间隔
@property (nonatomic, strong) NSMutableDictionary *voiceTipDic;//报警声类型

@end

@implementation AlarmDetectConfig

#pragma mark 获取设备报警配置接口调用
- (void)getDeviceAlarmDetectConfig{
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    //移动侦测
    CfgParam* paramMotionCfg = [[CfgParam alloc] initWithName:[NSString stringWithUTF8String:_motionCfg.Name()] andDevId:channel.deviceMac andChannel:channel.channelNumber andConfig:&_motionCfg andOnce:YES andSaveLocal:NO];
    [self AddConfig:paramMotionCfg];
    //视频遮挡
    CfgParam* paramBlindCfg = [[CfgParam alloc] initWithName:[NSString stringWithUTF8String:_blindCfg.Name()] andDevId:channel.deviceMac andChannel:channel.channelNumber andConfig:&_blindCfg andOnce:YES andSaveLocal:NO];
    [self AddConfig:paramBlindCfg];
    //视频丢失
    CfgParam* paramLossCfg = [[CfgParam alloc] initWithName:[NSString stringWithUTF8String:_lossCfg.Name()] andDevId:channel.deviceMac andChannel:channel.channelNumber andConfig:&_lossCfg andOnce:YES andSaveLocal:NO];
    [self AddConfig:paramLossCfg];
    //调用获取配置的命令
    [self GetConfig];
    
    [self getAlarmPushInterval];
}
#pragma mark 获取配置回调信息
-(void)OnGetConfig:(CfgParam *)param {
    if ([param.name isEqualToString:[NSString stringWithUTF8String:_motionCfg.Name()]]) {
        //移动侦测回调
        if ([self.delegate respondsToSelector:@selector(getAlarmDetectConfigResult:)]) {
            [self.delegate getAlarmDetectConfigResult:param.errorCode ];
        }
    }
    if ( [param.name isEqualToString:[NSString stringWithUTF8String:_blindCfg.Name()]]) {
        //视频遮挡回调
        if ([self.delegate respondsToSelector:@selector(getAlarmDetectConfigResult:)]) {
            [self.delegate getAlarmDetectConfigResult:param.errorCode ];
        }
    }
    if ([param.name isEqualToString:[NSString stringWithUTF8String:_lossCfg.Name()]]) {
        //视频丢失回调
        if ([self.delegate respondsToSelector:@selector(getAlarmDetectConfigResult:)]) {
            [self.delegate getAlarmDetectConfigResult:param.errorCode ];
        }
    }
}
#pragma mark 保存设备报警配置接口调用
- (void)setDeviceAlarmDetectConfig {
    //发送保存配置的请求
    [self SetConfig];
    
    //设置报警间隔
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    char szCfg[512] = {0};
    sprintf(szCfg, "{ \"Name\":\"NetWork.PMS\",\"NetWork.PMS\" : {\"Enable\" : true, \"ServName\":\"push.umeye.cn\",\"Port\":80,\"BoxID\":\"\",\"PushInterval\":%d}}", self.pushInterval);
    NSLog(@"%s", szCfg);
    FUN_DevCmdGeneral(self.MsgHandle, CSTR(channel.deviceMac), 1040, "NetWork.PMS", 0, 5000, szCfg, (int)strlen(szCfg)+1, -1, 0);
}
#pragma mark 获取设备报警间隔
- (void)getAlarmPushInterval {
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    FUN_DevCmdGeneral(self.MsgHandle, CSTR(channel.deviceMac), 1042, "NetWork.PMS", 0, 5000, NULL, 0, -1, 2);
}

#pragma mark 获取报警铃声配置
- (void)getVoiceTipAbilityList{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    FUN_DevGetConfig_Json(self.MsgHandle, CSTR(channel.deviceMac), "Ability.VoiceTipType", 1024);
}

#pragma mark - 设置语言 获取报警类表之前需要先设置一下语言
-(void)setBrowserLanguage{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    LanguageTypes browserLanguage = CHINESE_S;
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    if ([currentLanguage containsString:@"zh-Hans"]) {
        browserLanguage = CHINESE_S;
    } else if ([currentLanguage containsString:@"zh-Hant"]||[currentLanguage containsString:@"zh-"]) {
        browserLanguage = CHINESE_T;
    } else if ([currentLanguage containsString:@"de-"]) {
        browserLanguage = GERMAN;
    } else if ([currentLanguage containsString:@"fr-"]) {
        browserLanguage = FRENCH;
    } else if ([currentLanguage hasPrefix:@"es"]) {
        browserLanguage = SPANISH;
    } else if ([currentLanguage containsString:@"pt-"]) {
        browserLanguage = PORTUGAL;
    } else if ([currentLanguage containsString:@"it-"]) {
        browserLanguage = ITALIAN;
    } else if ([currentLanguage containsString:@"ko-"]) {
        browserLanguage = KOREAN;
    } else if ([currentLanguage containsString:@"tr-"]) {
        browserLanguage = TURKEY;
    } else if ([currentLanguage containsString:@"th-"]) {
        browserLanguage = THAI;
    } else if ([currentLanguage containsString:@"ja-"]) {
        browserLanguage = JAPANESE;
    } else if ([currentLanguage containsString:@"ru-"]) {
        browserLanguage = RUSSIAN;
    } else if ([currentLanguage containsString:@"vi-"]) {
        browserLanguage = VIETNAMESE;
    }else if ([currentLanguage containsString:@"en-"]){
        browserLanguage = ENGLISH;
    }
    
    char param[1024];
    sprintf(param, "{ \"BrowserLanguage\" : { \"BrowserLanguageType\" : %d }, \"Name\" : \"BrowserLanguage\" }",browserLanguage);
    
    
    FUN_DevSetConfig_Json(self.MsgHandle, CSTR(channel.deviceMac), "BrowserLanguage",
                          (char *)param,(int)strlen(param) + 1,0);
}
#pragma mark 保存设备报警间隔
- (void)setAlarmPushInterval:(int)interval {
    self.pushInterval = interval;
}
#pragma mark 保存配置回调信息
- (void)OnSetConfig:(CfgParam *)param {
    if ([param.name isEqualToString:[NSString stringWithUTF8String:_motionCfg.Name()]]) {
    }
    if ( [param.name isEqualToString:[NSString stringWithUTF8String:_blindCfg.Name()]] ) {
    }
    if ([param.name isEqualToString:[NSString stringWithUTF8String:_lossCfg.Name()]]) {
        if ([self.delegate respondsToSelector:@selector(setAlarmDetectConfigResult:)]) {
            [self.delegate setAlarmDetectConfigResult:param.errorCode];
        }
    }
}


#pragma mark 读取各项配置的属性值
- (BOOL)getLossEnable { //视频都是开关
    return _lossCfg.Enable.Value();
}
- (BOOL)getMotionEnable { //移动侦测开关
    return _motionCfg.Enable.Value();
}
- (BOOL)getMotionRecordEnable { //移动侦测录像开关
    return _motionCfg.mEventHandler.RecordEnable.Value();
}
- (BOOL)getMotionSnapEnable { //移动侦测抓图开关
    return _motionCfg.mEventHandler.SnapEnable.Value();
}
- (BOOL)getMotionMessageEnable{ //移动侦测手机消息推送开关
    return _motionCfg.mEventHandler.MessageEnable.Value();
}
- (int)getMotionlevel{//获取移动侦测灵敏度
    return _motionCfg.Level.Value();
}
- (BOOL)getBlindEnable { //视频遮挡开关
    return _blindCfg.Enable.Value();
}
- (BOOL)getBlindRecordEnable { //视频遮挡录像开关
    return _blindCfg.mEventHandler.RecordEnable.Value();
}
- (BOOL)getBlindSnapEnable { //视频遮挡抓图开关
    return _blindCfg.mEventHandler.SnapEnable.Value();
}
- (BOOL)getBlindMessageEnable{ //视频遮挡手机消息推送开关
    return _blindCfg.mEventHandler.MessageEnable.Value();
}

- (int)getPushInterval{ //获取报警间隔
    //报警间隔
    if (self.PMSDic) {
        NSNumber *interval = self.PMSDic[@"PushInterval"];
        if (interval) {
            //新设备支持报警间隔,30s以内的显示为30秒
            _pushInterval = [interval intValue]<30?30:[interval intValue];
            return self.pushInterval;
        } else {
            //老设备不支持报警间隔
        }
    }
    return 0;
}

- (NSMutableArray *)getVoiceTip{ //获取报警声类型列表
    //报警间隔
    if (self.voiceTipDic) {
        NSMutableArray *voiceArray = [self.voiceTipDic[@"VoiceTip"] mutableCopy];
        if (voiceArray) {
            return voiceArray;
        }
    }
    return nil;
}

-(int)getSelectVoiceTipNum{//获取当前选中报警声类型
    return _motionCfg.mEventHandler.VoiceType.Value();
}

#pragma - mark 设置各项配置具体的属性值
-(void)setSelectVoiceTipNum:(int)voiceTip{//设置当前选中报警声类型
    _motionCfg.mEventHandler.VoiceType = voiceTip;
}
- (void)setLossEnable:(BOOL)Enable { //视频都是开关
     _lossCfg.Enable = Enable;
}
- (void)setMotionEnable:(BOOL)Enable { //移动侦测开关
    _motionCfg.Enable = Enable;
}
- (void)setMotionRecordEnable:(BOOL)Enable { //移动侦测录像开关
    _motionCfg.mEventHandler.RecordMask = Enable ? "0x1" : "0x0";
    _motionCfg.mEventHandler.RecordEnable = Enable;
    _motionCfg.mEventHandler.RecordLatch = 30;
}
- (void)setMotionSnapEnable:(BOOL)Enable { //移动侦测抓图开关
    _motionCfg.mEventHandler.SnapShotMask = Enable ? "0x1" : "0x0";
    _motionCfg.mEventHandler.SnapEnable = Enable;
}
- (void)setMotionMessageEnable:(BOOL)Enable{ //移动侦测手机消息推送开关
    _motionCfg.mEventHandler.MessageEnable =Enable;
}
- (void)setMotionlevel:(int)Level{//移动侦测灵敏度
    _motionCfg.Level = Level;
}
- (void)setBlindEnable:(BOOL)Enable { //视频遮挡开关
    _blindCfg.Enable =Enable;
}
- (void)setBlindRecordEnable:(BOOL)Enable { //视频遮挡录像开关
    _blindCfg.mEventHandler.RecordEnable =Enable;
}
- (void)setBlindSnapEnable:(BOOL)Enable { //视频遮挡抓图开关
    _blindCfg.mEventHandler.SnapEnable = Enable;
}
- (void)setBlindMessageEnable:(BOOL)Enable { //视频遮挡手机消息推送开关
    _blindCfg.mEventHandler.MessageEnable =Enable;
}

//这个回调方法是必须的，初步获取到的数据通过这个方法回调到底层进行解析
- (void)OnFunSDKResult:(NSNumber *) pParam {
    [super OnFunSDKResult:pParam];
    
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN: {
            if (msg->param3 == 1042) {
                if (msg->param1 >= 0) {
                    //读取报警间隔回调
                    NSString *cmdName = [NSString stringWithUTF8String:msg->szStr];
                    NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    
                    if ([cmdName isEqualToString:@"NetWork.PMS"]) {
                        NSError *error;
                        NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                        
                        self.PMSDic = [retDic[@"NetWork.PMS"] mutableCopy];
                        
                        NSNumber *interval = self.PMSDic[@"PushInterval"];
                        if (interval) {
                            //新设备支持报警间隔
                            _pushInterval = [interval intValue]<30?30:[interval intValue];
                        } else {
                            //老设备不支持报警间隔
                        }
                    }
                }
                if ([self.delegate respondsToSelector:@selector(getAlarmPushIntervalResult:)]) {
                    [self.delegate getAlarmPushIntervalResult:msg->param1];
                }
            }else if (msg->param3 == 1040) {
                if (msg->param1 >= 0) {
                    //设置报警间隔回调
                    NSString *cmdName = [NSString stringWithUTF8String:msg->szStr];
                    if ([cmdName isEqualToString:@"NetWork.PMS"]) {
                        self.PMSDic[@"PushInterval"] = [NSNumber numberWithInt:_pushInterval];
                    }
                }
                if ([self.delegate respondsToSelector:@selector(setAlarmPushIntervalResult:)]) {
                    [self.delegate setAlarmPushIntervalResult:msg->param1];
                }
            }
        }break;
        case EMSG_DEV_SET_CONFIG_JSON:
        {
            if (strcmp(msg->szStr, "BrowserLanguage") == 0){
                if (msg->param1 >= 0) {
                    [self getVoiceTipAbilityList];
                }else{
                    [MessageUI ShowErrorInt:msg->param1];
                }
            }
        }
            break;
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if (strcmp(msg->szStr, "Ability.VoiceTipType") == 0){
                if (msg->param1 >= 0) {
                    if (msg->pObject == NULL) {
                        return;
                    }
                    NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    
                    NSError *error;
                    NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                    if (!retDic) {
                        return;
                    }
                    
                    if ([[retDic objectForKey:@"Ability.VoiceTipType"] objectForKey:@"VoiceTip"]){
                        self.voiceTipDic = [[retDic objectForKey:@"Ability.VoiceTipType"] mutableCopy];
                        NSMutableArray *voiceArray = [[[retDic objectForKey:@"Ability.VoiceTipType"] objectForKey:@"VoiceTip"] mutableCopy];
                        if ([self.delegate respondsToSelector:@selector(getVoiceTipTypeResult:)]) {
                            [self.delegate getVoiceTipTypeResult:msg->param1];
                        }
                    }
                }else{
                    [MessageUI ShowErrorInt:msg->param1];
                }
            }
        }
            break;
        default:
            break;
    }
}

/***
 
 时间段结构：
 1、最外层是一个7元素数组，每个元素代表一天
 2、每个元素又是一个数组，这一层的元素分别代表一个时间段设置
 3、每个时间段又包含两部分，分别是开启状态和时间段，如下：
 
 @"0 00:00:00-23:59:59"; 第一个0或者1对应不启用和启用，哪一个时间段的启用状态是1，那么这一段时间配置就会生效。后面的时间对应时间段配置
 
 时间段设置之后，可以在报警配置中读取:
 [NSString stringWithUTF8String:_motionCfg.mEventHandler.TimeSection[i][0].Value()];

 ***/
#pragma mark - 示例：自定义设置移动侦测报警周日到周五白天打开，保存后生效，没有设置过时间段时，默认每天都全天生效 （每周第一天是周日.0-6分别对应周日-周六）
 //@"0 00:00:00-23:59:59"; 第一个0或者1对应不启用和启用，后面的时间对应时间段配置
- (void)setExampleDetectionConfig {
    //先设置报警为打开
    _motionCfg.Enable = true;
    for (int i = 0; i < 7; i++) {
        //时间段报警时，先把所有时间短设置为不启用
        NSString *dataStr = @"0 00:00:00-23:59:59";
        _motionCfg.mEventHandler.TimeSection[i][0] = SZSTR(dataStr);
    }
    for (int i =0; i< 6; i++) {
        ////设置周日到周五报警时间段，假设白天为早6点到晚6点
        NSString *dataStr = @"1 06:00:00-17:59:59";
        //存进缓存数据中
        _motionCfg.mEventHandler.TimeSection[i][0] = SZSTR(dataStr);
        //保存之后生效
    }
    
//    //如果一天想要设置两段时间录像，则可以继续设置第二段时间段
//    for (int i =0; i< 6; i++) {
//        ////设置第二个时间段为晚8点到晚10点
//        NSString *dataStr = @"1 20:00:00-21:59:59";
//        //存进缓存数据中
//        _motionCfg.mEventHandler.TimeSection[i][1] = SZSTR(dataStr);
//        //保存之后生效
//    }
    //每天可以配置几个时间段，以获取到json中时间段数量为准，默认应该是6个时间段
    
    //测试读取设置的报警时间段配置
    [self readTimeSectionTest];
}
#pragma mark - 示例 读取周日到周五前面 每天的第一段时间段设置，一般来说6段都需要读取一下，最后综合每一天的报警时间
- (void)readTimeSectionTest {
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i =0; i< 6; i++) {
        NSString *timeSection = [NSString stringWithUTF8String:_motionCfg.mEventHandler.TimeSection[i][0].Value()];
        [array addObject:timeSection];
    }
    NSLog(@"%@",array);
}
/***
 TimeSection 结构
 
"TimeSection": [
                [
                 "1 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00"
                 ],
                [
                 "1 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00"
                 ],
                [
                 "1 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00"
                 ],
                [
                 "1 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00"
                 ],
                [
                 "1 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00"
                 ],
                [
                 "1 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00"
                 ],
                [
                 "1 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00",
                 "0 00:00:00-24:00:00"
                 ]
                ]
 
 Mask结构
 "Mask": [
 [
 "0x00000007",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000"
 ],
 [
 "0x00000007",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000"
 ],
 [
 "0x00000007",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000"
 ],
 [
 "0x00000007",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000"
 ],
 [
 "0x00000007",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000"
 ],
 [
 "0x00000007",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000"
 ],
 [
 "0x00000007",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000",
 "0x00000000"
 ]
 ],
 
 ****/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
