//
//  ShadowServicesManager.m
//  FunSDKDemo
//
//  Created by plf on 2023/4/25.
//  Copyright © 2023 plf. All rights reserved.
//

#import "ShadowServicesManager.h"
#import "JsonData.h"

@interface ShadowServicesManager ()

@end


@implementation ShadowServicesManager

+ (instancetype)getInstance {
    static ShadowServicesManager *Manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Manager = [[ShadowServicesManager alloc]init];
    });
    return Manager;
}

-(void)dealloc{
    //销毁前把监听关闭
    [self removeShadowServiceListener];
    
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


//MARK: 影子服务器获取设备配置
- (void)getDevCfgsFromShadowService:(NSString *)cfglist callBack:(GetDevCfgsFromShadowServiceCallBack)result{
    self.GetDevCfgsFromShadowServiceCallBack = result;
    
    char szCfg[512] = {0};
    snprintf(szCfg, 512, "{ \"msg\":\"getcfg\",\"cfglist\":%s}",[cfglist UTF8String]);
    
    Fun_GetDevCfgsFromShadowService(self.msgHandle, self.devID.UTF8String, szCfg, 5000, 0);
}

//MARK: 设置设备离线配置到影子服务
- (void)setDevOffLineCfgsToShadowService:(NSString *)cfglist callBack:(SetDevOffLineCfgsToShadowServiceCallBack)result
{
    self.setDevOffLineCfgsToShadowServiceCallBack = result;
    
    char szCfg[512] = {0};
    snprintf(szCfg, 512, "{ \"msg\":\"setcfg\",\"cfglist\":%s}",[cfglist UTF8String]);

    Fun_SetDevOffLineCfgsToShadowService(self.msgHandle, self.devID.UTF8String, szCfg, 5000, 0);
    
}

//MARK: 影子服务设备配置状态监听
- (void)addShadowServiceListener:(NSString *)cfglist callBack:(AddShadowServiceListenerCallBack)result
{
    self.addShadowServiceListenerCallBack = result;
    
    char szCfg[512] = {0};
    snprintf(szCfg, 512, "{ \"msg\":\"monitorcfg\",\"cfglist\":%s}",[cfglist UTF8String]);

    FUN_SysAddShadowServerListener(self.msgHandle, self.devID.UTF8String, szCfg);
}

//MARK: 移除影子服务设备配置监听
- (void)removeShadowServiceListener
{
    FUN_SysRemoveShadowServerListener(self.devID.UTF8String);
}

#pragma mark - 回调函数
- (void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_SHADOW_SERVICE_GET_DEV_CONFIGS:{
            if (msg->param1>=0) {
                //获取成功
                if (msg->pObject == NULL) {
                    return;
                }
                
                NSData *data = [JsonData parseMsgObject:msg->pObject];
                if ( data == nil ){
                    return;
                }
                NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ( appData == nil){
                    return;
                }
                NSString* strConfigName = [appData valueForKey:@"data"];
                if (strConfigName == nil) {
                    return;
                }
                
                if (self.getDevCfgsFromShadowServiceCallBack) {
                    self.getDevCfgsFromShadowServiceCallBack(appData[@"data"]);
                }
            }
        }
            break;
        case EMSG_SHADOW_SERVICE_SET_DEV_OFFLINE_CFGS:
        {
            if (msg->param1>=0) {
                NSLog(@"1111");
            }
        }
            break;
        case EMSG_SHADOW_SERVICE_DEV_CONFIGS_CHANGE_NOTIFY:
        {
            if (msg->param1>=0) {
                //获取成功
                if (msg->pObject == NULL) {
                    return;
                }
                
                NSData *data = [JsonData parseMsgObject:msg->pObject];
                if ( data == nil ){
                    return;
                }
                NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ( appData == nil){
                    return;
                }
                NSString* strConfigName = [appData valueForKey:@"data"];
                if (strConfigName == nil) {
                    return;
                }
                
                if (self.addShadowServiceListenerCallBack) {
                    self.addShadowServiceListenerCallBack(appData[@"data"]);
                }
            }
        }
        default:
            break;
    }
}


@end
