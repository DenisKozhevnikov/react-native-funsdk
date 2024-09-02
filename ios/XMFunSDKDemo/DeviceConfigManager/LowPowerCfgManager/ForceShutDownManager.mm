//
//  ForceShutDownManager.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/21.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "ForceShutDownManager.h"
#import <FunSDK/FunSDK.h>

@interface ForceShutDownManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,strong) NSMutableDictionary *dicForcesShutDownCfg;

@end

@implementation ForceShutDownManager

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
- (void)requestForceShutDownCfg:(NSString *)devID completion:(GetForceShutDownCallBack)callBack{
    self.getForceShutDownCallBack = callBack;
    
    if (devID) {
        self.devID = devID;
    }
    
    FUN_DevGetConfig_Json(self.msgHandle, self.devID.UTF8String, "Consumer.ForceShutDownMode", 1024);
}

//MAKR:保存强制关机配置
- (void)saveForceShutDownCfg:(SetForceShutDownCallBack)callBack{
    self.setForceShutDownCallBack = callBack;
    
    NSDictionary* jsonDic1 = @{@"Name":@"Consumer.ForceShutDownMode",@"Consumer.ForceShutDownMode":self.dicForcesShutDownCfg};
    NSError *error;
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:jsonDic1 options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, CSTR(self.devID), "Consumer.ForceShutDownMode", [pCfgBufString1 UTF8String], (int)(strlen([pCfgBufString1 UTF8String]) + 1));
}

//MARK:获取设置强制关机
- (int)getForceShutDownMode{
    return [[self.dicForcesShutDownCfg objectForKey:@"ShutDownMode"] intValue];
}

- (void)setForceShutDownMode:(int)mode{
    [self.dicForcesShutDownCfg setObject:[NSNumber numberWithInt:mode] forKey:@"ShutDownMode"];
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
                    if (self.getForceShutDownCallBack){
                        self.getForceShutDownCallBack(-1);
                    }
                    return;
                }
                
                self.dicForcesShutDownCfg = [[retDic objectForKey:@"Consumer.ForceShutDownMode"] mutableCopy];
                
                if (self.getForceShutDownCallBack){
                    self.getForceShutDownCallBack(msg->param1);
                }
            }else{
                if (self.getForceShutDownCallBack){
                    self.getForceShutDownCallBack(msg->param1);
                }
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:
        {
            if (self.setForceShutDownCallBack) {
                self.setForceShutDownCallBack(msg->param1);
            }
        }
            break;
        default:
            break;
    }
}

@end
