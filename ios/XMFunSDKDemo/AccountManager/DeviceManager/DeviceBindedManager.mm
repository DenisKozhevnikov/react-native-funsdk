//
//  DeviceBindedManager.m
//  XWorld_General
//
//  Created by SaturdayNight on 2018/9/11.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import "DeviceBindedManager.h"
#import <FunSDK/FunSDK.h>
#import "SystemFunction.h"
#import "DeviceConfig.h"

// 设备绑定标相关
typedef void(^DevBindEnableResultBlock)(BOOL bindEnable, BOOL bindFinished, NSInteger errCode);
typedef void(^DevFetchBindConfigResultBlock)(BOOL bindEnable, NSInteger errCode);
typedef void(^DevBindConfigResultBlock)(BOOL successed, NSInteger errCode);

@interface DeviceBindedManager () <DeviceConfigDelegate>{
    SystemFunction jSystemFunction;
}

@property (nonatomic,assign) int msgHandle;
/** 设备绑定相关 */
@property (nonatomic, copy) DevBindEnableResultBlock devBindEnableCompletion;
/** 获取绑定设备配置 */
@property (nonatomic, copy) DevFetchBindConfigResultBlock devFetchBindConfigCompletion;
/** 绑定配置 */
@property (nonatomic, copy) DevBindConfigResultBlock devBindConfigCompletion;

@end

@implementation DeviceBindedManager

-(void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
        self.devID = @"";
    }
    
    return self;
}

-(void)getBindConfig:(AddDeviceStyleCallBack)result bindResult:(DeviceBindedCallBack)bindResult{
    self.addDeviceStyleCallBack = result;
    self.deviceBindedCallBack = bindResult;
    
    Fun_Log((char *)"快速配置流程: 获取能力集 \n");
    jSystemFunction.SetName(JK_SystemFunction);
    DeviceConfig* systemFunction = [[DeviceConfig alloc] initWithJObject:&jSystemFunction];
    systemFunction.devId = self.devID;
    systemFunction.channel = -1;
    systemFunction.isSet = NO;
    systemFunction.delegate = self;
    [self requestGetConfig:systemFunction];
}
// 获取设备的绑定标识能力集
- (void)jf_queryDevSupportAppBindValueWithDevId:(NSString *)devId completion:(void(^)(BOOL bindEnable, BOOL bindFinished, NSInteger errCode))completion{
    self.devBindEnableCompletion = completion;
    jSystemFunction.SetName(JK_SystemFunction);
    DeviceConfig* systemFunction = [[DeviceConfig alloc] initWithJObject:&jSystemFunction];
    systemFunction.devId = ISLEGALSTR(devId)?devId:self.devID;
    systemFunction.channel = -1;
    systemFunction.isSet = NO;
    systemFunction.delegate = self;
    [self requestGetConfig:systemFunction];
}
#pragma mark - 预览界面判断是否需要设置为绑定
- (void)setDeviceBindInCamera{
    // 先判断是否是主账号
    Fun_SysIsDevMasterAccountFromServer(self.msgHandle, [self.devID UTF8String], 0);
}

#pragma mark - 获取配置返回
- (void)getConfig:(DeviceConfig *)config result:(int)result
{
    Fun_Log((char *)"快速配置流程: 获取能力集回调 \n");
    NSLog(@"devid[%@] channel[%d] getConfig[%@] result[%d]", config.devId, config.channel, config.name, result);
    if ( result >=0 ) {
        if ([config.name isEqualToString:OCSTR(JK_SystemFunction)]) {
            BOOL support = jSystemFunction.mOtherFunction.SupportAppBindFlag.Value();
            if (support) {
                Fun_Log((char *)"快速配置流程: 开始获取绑定标志 \n");
                //                FUN_DevGetConfig_Json(self.msgHandle, [self.devID UTF8String], "General.AppBindFlag", 1024);
                [self queryDevBindValueWithDevId:config.devId completion:^(BOOL bindEnable, NSInteger errCode) {
                    if (!bindEnable) { // 未绑定，则先绑定
                        [self bindDevWithWithDevId:config.devId completion:^(BOOL successed, NSInteger errCode) {
                            XMLog(@"");
                            if (self.devBindEnableCompletion) { // 支持绑定标志配置回调
                                self.devBindEnableCompletion(support, successed, errCode);
                                self.devBindEnableCompletion = nil;
                            }
                        }];
                    }else{
                        if (self.devBindEnableCompletion) { // 支持绑定标志配置回调
                            self.devBindEnableCompletion(support, bindEnable, errCode);
                            self.devBindEnableCompletion = nil;
                        }
                    }
                }];
            }
            else{
                if (self.addDeviceStyleCallBack) {
                    self.addDeviceStyleCallBack(AddDeviceStyleNormal);
                }
                if (self.devBindEnableCompletion) { // 获取绑定标志能力集回调
                    self.devBindEnableCompletion(support, NO, result);
                    self.devBindEnableCompletion = nil;
                }
            }
        }
    }else{
        if (self.addDeviceStyleCallBack) {
            self.addDeviceStyleCallBack(AddDeviceStyleNormal);
        }
        if (self.devBindEnableCompletion) { // 获取绑定标志能力集回调
            self.devBindEnableCompletion(NO, NO, result);
            self.devBindEnableCompletion = nil;
        }
    }
}

// 获取设备是否绑定
- (void)queryDevBindValueWithDevId:(NSString *)devId completion:(void(^)(BOOL bindEnable, NSInteger errCode))completion{
    self.devFetchBindConfigCompletion = completion;
    NSString *dev_id = ISLEGALSTR(devId)?devId:self.devID;
    FUN_DevGetConfig_Json(self.msgHandle, CSTR(dev_id), "General.AppBindFlag", 1024);
}

// 绑定设备
- (void)bindDevWithWithDevId:(NSString *)devId completion:(void(^)(BOOL successed, NSInteger errCode))completion{
    self.devBindConfigCompletion = completion;
    NSDictionary* jsonDic1 = @{@"Name":@"General.AppBindFlag",@"General.AppBindFlag":@{@"BeBinded":@(YES)}};
    NSError *error;
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:jsonDic1 options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    FUN_DevSetConfig_Json(self.msgHandle, CSTR(self.devID), "General.AppBindFlag", [pCfgBufString1 UTF8String], (int)(strlen([pCfgBufString1 UTF8String]) + 1));
}

- (void)setConfig:(DeviceConfig *)config result:(int)result {
    
}
// MARK: OnFunSDKResult
- (void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    switch (msg->id) {
        case EMSG_SYS_IS_MASTERMA:
        {
            //#ifdef XM_CLOUD_SUPPORT_ACCOUNT_ALL_MASTER
            //            [self getBindConfig:^(AddDeviceStyle style) {
            //
            //            } bindResult:^(BOOL ifBinded) {
            //                // 这里返回解析的时候已经绑定
            //            }];
            //#else
            /*
             如果是主账号:（支持绑定，实际未绑定的情况下需要去绑定）
             1.获取是否支持绑定
             2.如果支持，再去获取绑定配置
             3.如果配置未绑定，则去设置绑定 清空订阅 设置主账号
             */
            
            BOOL ifMaster = NO;
            if (msg->param1 == 0) {
                
            }
            else if (msg->param1 >= 1)
            {
                ifMaster = YES;
            }
            
            if (ifMaster) {
                [self getBindConfig:^(AddDeviceStyle style) {
                    
                } bindResult:^(BOOL ifBinded) {
                    // 这里返回解析的时候已经绑定
                }];
            }
            //#endif
        }
            break;
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if (strcmp(msg->szStr, "General.AppBindFlag") == 0) {
                Fun_Log((char *)"快速配置流程: 获取绑定标志回调 \n");
                if (msg->param1 >= 0) {
                    if (msg->pObject == NULL) {
                        if (self.addDeviceStyleCallBack) {
                            self.addDeviceStyleCallBack(AddDeviceStyleNormal);
                        }
                        if (self.devFetchBindConfigCompletion) { // 获取设备绑定配置结果
                            self.devFetchBindConfigCompletion(NO, msg->param1);
                            self.devFetchBindConfigCompletion = nil;
                        }
                        return;
                    }
                    NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    NSError *error;
                    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                    if(error){
                        if (self.addDeviceStyleCallBack) {
                            self.addDeviceStyleCallBack(AddDeviceStyleNormal);
                        }
                        if (self.devFetchBindConfigCompletion) { // 获取设备绑定配置结果
                            self.devFetchBindConfigCompletion(NO, msg->param1);
                            self.devFetchBindConfigCompletion = nil;
                        }
                        return;
                    }
                    
                    NSDictionary *dicInfo = [jsonDic objectForKey:@"General.AppBindFlag"];
                    BOOL ifBinded = [[dicInfo objectForKey:@"BeBinded"] boolValue];
                    if (self.deviceBindedCallBack) {
                        self.deviceBindedCallBack(ifBinded);
                    }
                    if (self.devFetchBindConfigCompletion) { // 获取设备绑定配置结果
                        self.devFetchBindConfigCompletion(ifBinded, msg->param1);
                        self.devFetchBindConfigCompletion = nil;
                    }
                    if (!ifBinded) {
                        Fun_Log((char *)"快速配置流程: 设置绑定标志 \n");
                        NSDictionary* jsonDic1 = @{@"Name":@"General.AppBindFlag",@"General.AppBindFlag":@{@"BeBinded":[NSNumber numberWithBool:YES]}};
                        NSError *error;
                        NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:jsonDic1 options:NSJSONWritingPrettyPrinted error:&error];
                        NSString *pCfgBufString1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
                        
                        FUN_DevSetConfig_Json(self.msgHandle, CSTR(self.devID), "General.AppBindFlag", [pCfgBufString1 UTF8String], (int)(strlen([pCfgBufString1 UTF8String]) + 1));
                    }
                    
                }
                else
                {
                    if (self.addDeviceStyleCallBack) {
                        self.addDeviceStyleCallBack(AddDeviceStyleNormal);
                    }
                    if (self.devFetchBindConfigCompletion) { // 获取设备绑定配置结果
                        self.devFetchBindConfigCompletion(NO, msg->param1);
                        self.devFetchBindConfigCompletion = nil;
                    }
                }
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:{
            if (NULL == msg->szStr) break;
//            if (strcmp(msg->szStr, "General.AppBindFlag") == 0){
            if ([OCSTR(msg->szStr) isEqualToString:@"General.AppBindFlag"]) {
                if (msg->param1 < 0 || NULL == msg->pObject) {
                    if (self.devBindConfigCompletion) { // 设备绑定配置值结果
                        self.devBindConfigCompletion(NO, msg->param1);
                        self.devBindConfigCompletion = nil;
                    }
                    return;
                }
                NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSError *error;
                id jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                if (![jsonDic isKindOfClass:[NSDictionary class]] || [jsonDic count] <= 0) {
                    if (self.devBindConfigCompletion) { // 设备绑定配置值结果
                        self.devBindConfigCompletion(NO, msg->param1);
                        self.devBindConfigCompletion = nil;
                    }
                    return;
                }
                NSDictionary *tempDic = (NSDictionary *)jsonDic;
//                NSString *cmdName = tempDic[@"Name"];
                NSNumber *errCode = tempDic[@"Ret"];
                if (self.devBindConfigCompletion) { // 设备绑定配置值结果
                    BOOL successed = (100 == [errCode integerValue])?YES:NO;
                    self.devBindConfigCompletion(successed, msg->param1);
                    self.devBindConfigCompletion = nil;
                }
                XMLog(@"");
            }
        }
            break;
        default:
            break;
    }
}

@end
