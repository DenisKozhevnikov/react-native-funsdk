//
//  CruiseConfig.m
//  FunSDKDemo
//
//  Created by zhang on 2019/6/25.
//  Copyright © 2019 zhang. All rights reserved.
//


#import "CruiseConfig.h"
#import "CruiseDataSource.h"
#import "Detect_DetectTrack.h"
#import "FunSDK/FunSDK.h"

@interface CruiseConfig ()
{
    Detect_DetectTrack detectTrack;     //移动追踪（人形跟随）
}

@property (nonatomic,assign) int tempNum;   // 临时记录当前操作的预置点编号
@property (nonatomic,assign) BOOL ifNeedAddTour;   // 是否需要添加或删除巡航线
@property (nonatomic,assign) BOOL ifNeedDeleteTour;
@property (nonatomic,assign) BOOL ifResetTour;      // 是否是重置预置点


@end

@implementation CruiseConfig

+(CruiseConfig *)sharedInstance{
    static CruiseConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        instance.currentTourNum = 0;//巡航线编号默认0
    });
    return instance;
}

//查询 获取巡航点
-(void)FunGetCruisePoint{
    FUN_DevGetConfig_Json(self.MsgHandle, CSTR(self.devID), "Uart.PTZTour", 0, -1, 15000, 9000/*9000 表请求读取preSetPoint data*/);
    
    
    //   如果要设置 Uart.PTZTour 配置中的参数，需要把获取到的json修改参数之后发出,如下参考：
    
//    设置AVEnc.SmartH264信息
//    char param[1024];
//    sprintf(param, "{ \"AVEnc.SmartH264\" : [ { \"SmartH264\" : false } ], \"Name\" : \"AVEnc.SmartH264\", \"SessionID\" : \"0x000006A9\" }");
//    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
//    FUN_DevSetConfig_Json(SELF, SZSTR(channel.deviceMac), "AVEnc.SmartH264",
//                          (char *)param,(int)strlen(param) + 1,channel.channelNumber);
}

//添加  (先添加预支点  后添加到巡航线)
-(void)FunAddCruisePointWithNum:(int)num{
    /*"SetPreset";// 设置预置点 "ClearPreset";//删除预置点 "GotoPreset"; //跳转到预置点; “SetPresetName” 编辑预置点名字*/
    self.ifNeedAddTour = YES;
    self.tempNum = num;
    char cfg[1024];
    NSLog(@"CY= kaishi add Point %i",num);
    NSString *presetPoitnName = [NSString stringWithFormat:@"%@:%d",TS("preset"),num];
    sprintf(cfg,"{\"Name\":\"OPPTZControl\",\"OPPTZControl\":{\"Command\":\"SetPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d,\"PresetName\":\"Preset_Point:%s\"}},\"SessionID\":\"0x08\"}",num,CSTR(presetPoitnName));
    FUN_DevCmdGeneral(self.MsgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9527/*9527 表添加预置点*/);
}

//跳转到某个预置点
-(void)FunGotoCruisePointWithNum:(int)num{
    char cfg[1024];
    sprintf(cfg, "{\"OPPTZControl\":{\"Command\":\"GotoPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d}}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",num);
    
    FUN_DevCmdGeneral(self.MsgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9528/*9528 表跳转*/);
}

//重置巡航
-(void)FunResetCruisePointWithNum:(int)num{
    self.tempNum = num;
    self.ifResetTour = YES;
    [self FunDeleteCruisePointWithNum:num];
}

//删除
-(void)FunDeleteCruisePointWithNum:(int)num{
    self.ifNeedDeleteTour = YES;
    self.tempNum = num;
    char cfg[1024];
    sprintf(cfg, "{\"OPPTZControl\":{\"Command\":\"ClearPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d}}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",num);
    NSLog(@"CY= kaishi delete Point %i",num);
    FUN_DevCmdGeneral(self.MsgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9530/*9530 表删除*/);
}

//删除所有
-(void)FunDeleteAllCruisePoint{
    char cfgTour[1024];
    sprintf(cfgTour, "{\"OPPTZControl\":{\"Command\":\"ClearTour\",\"Parameter\":{\"Tour\":%d}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",self.currentTourNum);
    FUN_DevCmdGeneral(self.MsgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfgTour, (int)strlen(cfgTour) + 1, -1, 10005/*10005 表清除所有巡航点*/);
}

//开始巡航
-(void)FunStartCruise{
    char cfgTour[1024];
    sprintf(cfgTour, "{\"OPPTZControl\":{\"Command\":\"StartTour\",\"Parameter\":{\"TourTimes\":1,\"Tour\":%d}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",self.currentTourNum);
    FUN_DevCmdGeneral(self.MsgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfgTour, (int)strlen(cfgTour) + 1, -1, 10003/*10003 表添开始巡航*/);
}

//停止巡航
-(void)FunStopCruise{
    char cfgTour[1024];
    sprintf(cfgTour, "{\"OPPTZControl\":{\"Command\":\"StopTour\"},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}");
    FUN_DevCmdGeneral(self.MsgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfgTour, (int)strlen(cfgTour) + 1, -1, 10002/*10004 表结束巡航*/);
}

//360巡航  还没有接口 暂时不支持
-(void)Fun360Cruise{
    [self FunDeleteAllCruisePoint];
}

//查询 获取移动追踪
- (void)FungetDetectTrack {
    CfgParam* param = [[CfgParam alloc] initWithName:[NSString stringWithUTF8String:JK_Detect_DetectTrack] andDevId:self.devID andChannel:-1 andConfig:&detectTrack andOnce:YES andSaveLocal:NO];
    [self AddConfig:param];
    [self GetConfig:[NSString stringWithUTF8String:JK_Detect_DetectTrack]];
}
//保存 设置移动追踪
- (void)setTrackConfig {
    [self SetConfig:[NSString stringWithUTF8String:JK_Detect_DetectTrack]];
}

//添加守望点
-(void)setWatchPointWithNum:(int)num{
    /*"SetPreset";// 设置预置点 "ClearPreset";//删除预置点 "GotoPreset"; //跳转到预置点; “SetPresetName” 编辑预置点名字*/
    self.ifNeedAddTour = NO;
    self.tempNum = num;
    char cfg[1024];
    NSLog(@"CY= kaishi add Point %i",num);
    NSString *presetPoitnName = [NSString stringWithFormat:@"%@:%d",TS("preset"),num];
    sprintf(cfg, "{\"OPPTZControl\":{\"Command\":\"SetPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d,\"PresetName\":\"%s\"}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",num,CSTR(presetPoitnName));
    FUN_DevCmdGeneral(self.MsgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9529/*9529 表添添加守望点*/);
}

#pragma mark - FunSDK 接口请求回调
-(void)OnFunSDKResult:(NSNumber *) pParam{
    [super OnFunSDKResult:pParam];
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    if (self.ifResetTour || self.ifNeedAddTour || self.ifNeedDeleteTour || self.tempNoDismiss) {
        self.tempNoDismiss = NO;
    }
    else{
    }
    
    switch ( msg->id ) {
        case EMSG_DEV_GET_CONFIG_JSON:{
            if ( strcmp(msg->szStr, "Uart.PTZTour") == 0 ) {
                NSMutableArray *pionts= [NSMutableArray arrayWithCapacity:0];
                if (msg -> param1 >= 0) {
                    
                    NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    NSError *error;
                    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                    if(error){
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnGetCruisePoint:result:)]) {
                            [self.delegate OnGetCruisePoint:[pionts mutableCopy] result:msg -> param1];
                        }
                        return;
                    }
                    id tourData = jsonDic[@"Uart.PTZTour"];
                    if (tourData == [NSNull null]) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnGetCruisePoint:result:)]) {
                            [self.delegate OnGetCruisePoint:[pionts mutableCopy] result:msg -> param1];
                        }
                        return;
                    }
                    
                    id tourArr = tourData[0];
                    if (tourArr == [NSNull null]) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnGetCruisePoint:result:)]) {
                            [self.delegate OnGetCruisePoint:[pionts mutableCopy] result:msg -> param1];
                        }
                        return;
                    }
                    NSNumber *toutId = tourArr[0][@"Id"];
                    self.currentTourNum = [toutId intValue];
                    
                    id cruisePiontsData = tourArr[0][@"Tour"];
                    if (cruisePiontsData == [NSNull null]) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnGetCruisePoint:result:)]) {
                            [self.delegate OnGetCruisePoint:[pionts mutableCopy] result:msg -> param1];
                        }
                        return;
                    }
                    
                    NSArray *cruisePionts = cruisePiontsData;
                    
                    for (int i = 0; i < cruisePionts.count ; i ++) {
                        CruiseDataSource *model = [[CruiseDataSource alloc]init];
                        NSNumber *idNum = cruisePionts[i][@"Id"];
                        model.cruiseID = [idNum intValue];
                        model.cruiseName = cruisePionts[i][@"Name"];
                        NSNumber *cruiseTime = cruisePionts[i][@"Time"];
                        model.time = [cruiseTime intValue];
                        
                        [pionts addObject:model];
                    }
                    
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(OnGetCruisePoint:result:)]) {
                    [self.delegate OnGetCruisePoint:[pionts mutableCopy] result:msg -> param1];
                }
            }
        }
            break;
        case EMSG_DEV_CMD_EN:
        {
            NSString *paramName = OCSTR(msg -> szStr);
            if ([paramName isEqualToString:@"OPPTZControl"]  ) {
                
                if (msg -> seq == 9530) {//删除操作预支点
                    if (self.ifNeedDeleteTour  && msg->param1 >= 0) {
                        self.ifNeedDeleteTour = NO;
                        char cfgTour[1024];
                        sprintf(cfgTour, "{\"OPPTZControl\":{\"Command\":\"DeleteTour\",\"Parameter\":{\"Preset\":%d,\"Tour\":%d}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",self.tempNum,self.currentTourNum);
                        NSLog(@"CY= kaishi delete Line %i",self.tempNum);
                        FUN_DevCmdGeneral(self.MsgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfgTour, (int)strlen(cfgTour) + 1, -1, 10002/*10002 表删除巡航点*/);
                    }
                    else{
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnDeleteCruisePoint:result:)]) {
//                            [self.delegate OnDeleteCruisePoint:nil  result:msg -> param1];
                        }
                    }
                }else if (msg -> seq == 9527){//预置预支点
                    if (self.ifNeedAddTour && msg->param1 >= 0) {
                        self.ifNeedAddTour = NO;
                        char cfgTour[1024];
                        sprintf(cfgTour, "{\"OPPTZControl\":{\"Command\":\"AddTour\",\"Parameter\":{\"Preset\":%d,\"Step\":3,\"Tour\":%d,\"PresetIndex\":%d}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",self.tempNum,self.currentTourNum,self.tempNum-252);
                        NSLog(@"CY= kaishi add Line %i",self.tempNum);
                        FUN_DevCmdGeneral(self.MsgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfgTour, (int)strlen(cfgTour) + 1, -1, 10001/*10001 表添加巡航线*/);
                    }
                    else{
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnSetCruisePoint:result:)]) {
//                            [self.delegate OnSetCruisePoint:nil  result:msg -> param1];
                        }
                    }
                    
                }else if (msg -> seq == 9528){//跳转成功
                    if (self.delegate && [self.delegate respondsToSelector:@selector(OnGotoCruisePoint:result:)]) {
//                        [self.delegate OnGotoCruisePoint:nil  result:msg -> param1];
                    }
                }else if (msg -> seq == 9528){//跳转成功
                    if (self.delegate && [self.delegate respondsToSelector:@selector(OnGotoCruisePoint:result:)]) {
//                        [self.delegate OnGotoCruisePoint:nil  result:msg -> param1];
                    }
                }else if (msg->seq == 9529){//设置守望点回调
                    if (self.delegate && [self.delegate respondsToSelector:@selector(setWatchPointResult:)]) {
                        [self.delegate setWatchPointResult:msg->param1];
                    }
                }else if (msg -> seq == 10001){//表添加巡航点
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(OnSetCruisePoint:result:)]) {
//                        [self.delegate OnSetCruisePoint:nil  result:msg -> param1];
                    }
                    
                }else if (msg -> seq == 10002){//表删除巡航点
                    if (self.ifResetTour  && msg->param1 >= 0) {
                        self.ifResetTour = NO;
                        [self FunAddCruisePointWithNum:self.tempNum];
                    }
                    else{
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnDeleteCruisePoint:result:)]) {
//                            [self.delegate OnDeleteCruisePoint:nil  result:msg -> param1];
                        }
                        
                    }
                }else if (msg -> seq == 10003){//表开始巡航
                    if (self.delegate && [self.delegate respondsToSelector:@selector(OnStartCruiseWithResult:)]) {
                        [self.delegate OnStartCruiseWithResult:msg -> param1];
                    }
                }else if (msg -> seq == 10004){//表结束巡航
                    if (self.delegate && [self.delegate respondsToSelector:@selector(OnStopCruiseWithResult:)]) {
                        [self.delegate OnStopCruiseWithResult:msg -> param1];
                    }
                }else if (msg -> seq == 10005){//表清除巡航线所有巡航点
                    if (self.delegate && [self.delegate respondsToSelector:@selector(OnDeleteCruisePoint:result:)]) {
//                        [self.delegate OnDeleteCruisePoint:nil  result:msg -> param1];
                    }
                }
            }
            
        }
            break;
        case EMSG_DEV_PTZ_CONTROL:{
            if (self.delegate && [self.delegate respondsToSelector:@selector(OnStopCruiseWithResult:)]) {
                [self.delegate OnStopCruiseWithResult:msg -> param1];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 获取配置回调
- (void)OnGetConfig:(CfgParam *)param {
    //移动追踪
    if ([param.name isEqualToString:[NSString stringWithUTF8String:JK_Detect_DetectTrack]]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(OngetDetectTrackResult:)]) {
            [self.delegate OngetDetectTrackResult:(int)param.errorCode];
        }
    }
}
#pragma mark 设置移动追踪回调
-(void)OnSetConfig:(CfgParam *)param {
    if ( [param.name isEqualToString:[NSString stringWithUTF8String:JK_Detect_DetectTrack]] ) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(OnsetDetectTrackResult:)]) {
            [self.delegate OnsetDetectTrackResult:(int)param.errorCode];
        }
    }
}

#pragma mark - 读取和设置请求到的移动追踪属性
- (BOOL)getTrackEnable {
    return detectTrack.Enable.Value();
}
- (int)getTrackSensitivity {
    return detectTrack.Sensitivity.Value();
}
- (int)getTrackReturnTime {
    return detectTrack.ReturnTime.Value();
}

- (void)setTrackEnable:(BOOL)enable {
    detectTrack.Enable = enable;
}
- (void)setTrackSensitivity:(int)sitivity {
    detectTrack.Sensitivity = sitivity;
}
- (void)setTrackReturnTime:(int)returnTime {
    detectTrack.ReturnTime = returnTime;
}
@end
