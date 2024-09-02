//
//  AutoCruiseConfig.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/7/8.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "AutoCruiseConfig.h"
#import <FunSDK/FunSDK.h>

@interface AutoCruiseConfig ()

@property (nonatomic,assign) int msgHandle;

@property (nonatomic,assign) int tempNum;   // 临时记录当前操作的预置点编号
@property (nonatomic,assign) BOOL ifNeedAddTour;   // 是否需要添加或删除巡航线
@property (nonatomic,assign) BOOL ifNeedDeleteTour;
@property (nonatomic,assign) BOOL ifResetTour;      // 是否是重置预置点

@end

@implementation AutoCruiseConfig

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
    }
    
    return self;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

//MARK: 获取定时配置
- (void)getTimingCfg:(AutoCruiseConfigTimingCfgCallBack)callBack{
    self.timingCfgCallBack = callBack;
    
    FUN_DevGetConfig_Json(self.msgHandle, [self.devID UTF8String], "General.TimimgPtzTour", 1024);
}

//MARK: 设置定时配置
- (void)saveTimingCfg:(AutoCruiseConfigTimingCfgCallBack)callBack{
    self.timingCfgCallBack = callBack;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[self.dicTimingCfg] options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, [self.devID UTF8String],"General.TimimgPtzTour", [pCfgBufString UTF8String], (int)(strlen([pCfgBufString UTF8String]) + 1), -1, 10000);
}

//MARK: 获取巡航列表
- (void)getCruiseList{
    FUN_DevGetConfig_Json(self.msgHandle, CSTR(self.devID), "Uart.PTZTour", 0, -1, 15000, 9000/*9000 表请求读取preSetPoint data*/);
}

//MARK: 添加巡航点 和手动巡航一样的点 这里的编号 分别代表标号为252，253，254的预置点
- (void)addPoint:(int)num{
    /*"SetPreset";// 设置预置点 "ClearPreset";//删除预置点 "GotoPreset"; //跳转到预置点; “SetPresetName” 编辑预置点名字*/
    self.ifNeedAddTour = YES;
    self.tempNum = num;
    char cfg[1024];
    NSLog(@"CY= kaishi add Point %i",num);
    NSString *presetPoitnName = [NSString stringWithFormat:@"%@:%d",TS("preset"),num];
    sprintf(cfg, "{\"OPPTZControl\":{\"Command\":\"SetPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d,\"PresetName\":\"%s\"}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",num,CSTR(presetPoitnName));
    FUN_DevCmdGeneral(self.msgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9527/*9527 表添加预置点*/);
}

//MARK: 删除巡航点
- (void)deletePoint:(int)num{
    self.ifNeedDeleteTour = YES;
    self.tempNum = num;
    char cfg[1024];
    sprintf(cfg, "{\"OPPTZControl\":{\"Command\":\"ClearPreset\",\"Parameter\":{\"Channel\":0,\"Preset\":%d}}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",num);
    NSLog(@"CY= kaishi delete Point %i",num);
    FUN_DevCmdGeneral(self.msgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfg, (int)strlen(cfg) + 1, -1, 9530/*9530 表删除*/);
}

//MARK: 重置巡航点
- (void)resetPoint:(int)num{
    self.tempNum = num;
    self.ifResetTour = YES;
    [self deletePoint:num];
}

// 获取定时是否打开
- (BOOL)getTimingOpen{
    BOOL result = [[self.dicTimingCfg objectForKey:@"Enable"] boolValue];
    
    return result;
}

// 获取定时间隔
- (int)getInterval{
    int result = [[self.dicTimingCfg objectForKey:@"TimeInterval"] intValue];
    
    return result;
}

// 设置定时开关
- (void)setTimingOpen:(BOOL)ifOpen{
    [self.dicTimingCfg setObject:[NSNumber numberWithBool:ifOpen] forKey:@"Enable"];
}

// 设置定时间隔
- (void)setInterval:(int)time{
    [self.dicTimingCfg setObject:[NSNumber numberWithInt:time] forKey:@"TimeInterval"];
}

//MARK: - FUNSDK回调
-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if (strcmp(msg->szStr, "General.TimimgPtzTour") == 0) {
                NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                if (jsonDic) {
                    self.dicTimingCfg = [[[jsonDic objectForKey:@"General.TimimgPtzTour"] objectAtIndex:0] mutableCopy];
                }
                
                self.timingCfgCallBack(msg->param1, self.dicTimingCfg);
            }else  if ( strcmp(msg->szStr, "Uart.PTZTour") == 0 ) {
                NSMutableArray *pionts= [NSMutableArray arrayWithCapacity:0];
                if (msg -> param1 >= 0) {
                    
                    NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    NSError *error;
                    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                    if(error){
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnGetAutoCruisePoint:result:)]) {
                            [self.delegate OnGetAutoCruisePoint:[pionts mutableCopy] result:msg -> param1];
                        }
                        return;
                    }
                    id tourData = jsonDic[@"Uart.PTZTour"];
                    if (tourData == [NSNull null]) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnGetAutoCruisePoint:result:)]) {
                            [self.delegate OnGetAutoCruisePoint:[pionts mutableCopy] result:msg -> param1];
                        }
                        return;
                    }
                    
                    id tourArr = tourData[0];
                    if (tourArr == [NSNull null]) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnGetAutoCruisePoint:result:)]) {
                            [self.delegate OnGetAutoCruisePoint:[pionts mutableCopy] result:msg -> param1];
                        }
                        return;
                    }
                    NSNumber *toutId = tourArr[0][@"Id"];
                    self.currentTourNum = [toutId intValue];
                    
                    id cruisePiontsData = tourArr[0][@"Tour"];
                    if (cruisePiontsData == [NSNull null]) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnGetAutoCruisePoint:result:)]) {
                            [self.delegate OnGetAutoCruisePoint:[pionts mutableCopy] result:msg -> param1];
                        }
                        return;
                    }
                    
                    NSArray *cruisePionts = cruisePiontsData;
                    
                    self.arrayPointList = [cruisePionts mutableCopy];
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(OnGetAutoCruisePoint:result:)]) {
                    [self.delegate OnGetAutoCruisePoint:[self.arrayPointList mutableCopy] result:msg -> param1];
                }
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:
        {
            if (strcmp(msg->szStr, "General.TimimgPtzTour") == 0) {
                self.timingCfgCallBack(msg->param1, nil);
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
                        FUN_DevCmdGeneral(self.msgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfgTour, (int)strlen(cfgTour) + 1, -1, 10002/*10002 表删除巡航点*/);
                    }
                    else{
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnDeleteAutoCruisePoint:result:)]) {
//                            [self.delegate OnDeleteAutoCruisePoint:nil  result:msg -> param1];
                        }
                    }
                }else if (msg -> seq == 9527){//预置预支点
                    if (self.ifNeedAddTour && msg->param1 >= 0) {
                        self.ifNeedAddTour = NO;
                        char cfgTour[1024];
                        sprintf(cfgTour, "{\"OPPTZControl\":{\"Command\":\"AddTour\",\"Parameter\":{\"Preset\":%d,\"Step\":10,\"Tour\":%d,\"PresetIndex\":%d}},\"SessionID\":\"0x08\",\"Name\":\"OPPTZControl\"}",self.tempNum,self.currentTourNum,self.tempNum-252);
                        NSLog(@"CY= kaishi add Line %i",self.tempNum);
                        FUN_DevCmdGeneral(self.msgHandle, CSTR(self.devID), 1400, "OPPTZControl", 4096, 10000,(char *)cfgTour, (int)strlen(cfgTour) + 1, -1, 10001/*10001 表添加巡航线*/);
                    }
                    else{
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnSetAutoCruisePoint:result:)]) {
//                            [self.delegate OnSetAutoCruisePoint:nil  result:msg -> param1];
                        }
                    }
                    
                }else if (msg -> seq == 10001){//表添加巡航点
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(OnSetAutoCruisePoint:result:)]) {
//                        [self.delegate OnSetAutoCruisePoint:nil  result:msg -> param1];
                    }
                    
                }else if (msg -> seq == 10002){//表删除巡航点
                    if (self.ifResetTour  && msg->param1 >= 0) {
                        self.ifResetTour = NO;
                        [self addPoint:self.tempNum];
                    }
                    else{
                        if (self.delegate && [self.delegate respondsToSelector:@selector(OnDeleteAutoCruisePoint:result:)]) {
//                            [self.delegate OnDeleteAutoCruisePoint:nil  result:msg -> param1];
                        }
                        
                    }
                }else if (msg -> seq == 10005){//表清除巡航线所有巡航点
                    if (self.delegate && [self.delegate respondsToSelector:@selector(OnDeleteAutoCruisePoint:result:)]) {
//                        [self.delegate OnDeleteAutoCruisePoint:nil  result:msg -> param1];
                    }
                }
            }
            
        }
            break;
        default:
            break;
    }
}

@end

