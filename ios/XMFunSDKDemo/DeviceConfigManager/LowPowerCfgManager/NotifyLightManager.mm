//
//  NotifyLightManager.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/21.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "NotifyLightManager.h"
#import <FunSDK/FunSDK.h>

@interface NotifyLightManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,strong) NSMutableDictionary *dicNotifyLightCfg;

@end

@implementation NotifyLightManager

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

//MARK:获取强制关机配置
- (void)requestNotifyLightCfg:(NSString *)devID completion:(GetNotifyLightCallBack)callBack{
    self.getNotifyLightCallBack = callBack;
    
    if (devID) {
        self.devID = devID;
    }
    
    FUN_DevGetConfig_Json(self.msgHandle, self.devID.UTF8String, "Consumer.NotifyLight", 1024);
}

//MAKR:保存强制关机配置
- (void)saveNotifyLightCfg:(SetNotifyLightCallBack)callBack{
    self.setNotifyLightCallBack = callBack;
    
    NSDictionary* jsonDic1 = @{@"Name":@"Consumer.NotifyLight",@"Consumer.NotifyLight":self.dicNotifyLightCfg};
    NSError *error;
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:jsonDic1 options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, CSTR(self.devID), "Consumer.NotifyLight", [pCfgBufString1 UTF8String], (int)(strlen([pCfgBufString1 UTF8String]) + 1));
}

//MARK:获取设置强制关机
- (BOOL)getNotifyLightEnabled{
    return [[self.dicNotifyLightCfg objectForKey:@"Enable"] intValue];
}

- (void)setNotifyLightEnable:(BOOL)enable{
    [self.dicNotifyLightCfg setObject:[NSNumber numberWithBool:enable] forKey:@"Enable"];
}

//MARK: - FunSDKCallBack
-(void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if (msg->param1 >= 0) {
                NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                
                NSError *error;
                NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                if (!retDic) {
                    if (self.getNotifyLightCallBack){
                        self.getNotifyLightCallBack(-1);
                    }
                    return;
                }
                
                self.dicNotifyLightCfg = [[retDic objectForKey:@"Consumer.NotifyLight"] mutableCopy];
                
                if (self.getNotifyLightCallBack){
                    self.getNotifyLightCallBack(msg->param1);
                }
            }else{
                if (self.getNotifyLightCallBack){
                    self.getNotifyLightCallBack(msg->param1);
                }
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:
        {
            if (self.setNotifyLightCallBack) {
                self.setNotifyLightCallBack(msg->param1);
            }
        }
            break;
        default:
            break;
    }
}

@end
