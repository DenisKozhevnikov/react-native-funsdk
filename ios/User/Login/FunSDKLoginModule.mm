//
//  FunSDKLoginModule.m
//  Funsdk
//
//  Created by Денис Кожевников on 10.08.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//
#import "FunSDKLoginModule.h"
#import "FunSDK/FunSDK.h"
#import <React/RCTLog.h>
#import "LoginShowControl.h"
#import "DeviceManager.h"
#import "AlarmManager.h"

@interface FunSDKLoginModule()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;

@end

@implementation FunSDKLoginModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (id)init {
    self = [super init];
    if (self) {
        [self loginOut];
    }
    return self;
}

- (void)loginOut {
    // clean up SDK
    FUN_UnInitNetSDK();
}



RCT_EXPORT_METHOD(loginByAccount:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    const char *userName = [params[@"username"] UTF8String];
    const char *psw = [params[@"password"] UTF8String];
        
    if (!self.resolvers) {
        self.resolvers = [NSMutableDictionary dictionary];
    }
    
    NSNumber *key = @(EMSG_SYS_GET_DEV_INFO_BY_USER);
    // Сохраняем блоки resolve и reject в маппинг
    self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
    
    FUN_SysGetDevList(self.msgHandle, [@(userName) UTF8String] , [@(psw) UTF8String],0);
    
    //暂存登陆模式
    [[LoginShowControl getInstance] setLoginType:loginTypeCloud];
//    //云登陆需要暂存登陆账号密码
    [[LoginShowControl getInstance] setLoginUserName: @(userName) password:@(psw)];
    
    FunMsgListener *listener = [[FunMsgListener alloc]init];
}

- (void)OnFunSDKResult:(NSNumber *) pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    

    NSLog(@"sender: %d", msg->sender);
    NSLog(@"id: %d", msg->id);
    NSLog(@"param1: %d", msg->param1);
    NSLog(@"param2: %d", msg->param2);
    NSLog(@"param3: %d", msg->param3);
    NSLog(@"szStr: %s", msg->szStr);
    NSLog(@"pObject: %s", msg->pObject);
    NSLog(@"nDataLen: %d", msg->nDataLen);
    NSLog(@"seq: %d", msg->seq);
    NSLog(@"pMsg: %p", msg->pMsg);

    switch (msg->id) {
        case EMSG_SYS_GET_DEV_INFO_BY_USER:{
            NSNumber *key = @(msg->id);
            NSDictionary *callbacks = self.resolvers[key];
            
//            NSLog(@"Current keys in self.resolvers: %@", [self.resolvers allKeys]);

            RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
            RCTPromiseRejectBlock reject = callbacks[@"reject"];
            
            if (msg->param1 < 0) {
                // Если ошибка, вызываем reject
                if (reject) {
//                    reject(@"login_error", @"Login failed", [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
                    // Создаем строку для отклонения промиса в том же формате, как в Java-коде
                     NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
                     reject(@"login_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
                }
                
                //                //用户名登录失败，根据错误信息msg->param1判断错误类型
                //                if (msg->param1 == EE_PASSWORD_NOT_VALID)
                //                {
                //                    //密码错误示例
                //                }
            } else {
                if (resolve) {
                    resolve(@(msg->param1));
                }
     
                // 初始化报警服务器
//                [[AlarmManager getInstance] initServer:[[[LoginShowControl getInstance] getPushToken] UTF8String]];
                //
                //
                //                //用户名登录成功，返回用户名下的设备列表信息，保存到APP缓存和本地存储中
                [[DeviceManager getInstance]  resiveDevicelist:[NSMessage SendMessag:nil obj:msg->pObject p1:msg->param1 p2:0]];
                //                //获取用户名下的别人分享给自己的设备
                [[DeviceManager getInstance] getShareToMeList];
                //                char devJson[750*500];
                //                FUN_GetFunStrAttr(EFUN_ATTR_GET_USER_ACCOUNT_DATA_INFO, devJson, 750*500);
                //                NSLog(@"包含当前账号的设备列表和其他用户分享给自己的设备列表json数据 = %s",devJson);
                
                
                //用户登录回调
                //                if ([self.delegate respondsToSelector:@selector(loginWithNameDelegate:)]) {
                //                    [self.delegate loginWithNameDelegate:msg->param1];
                //                }
            }
            // Удаляем обработанный маппинг
            [self.resolvers removeObjectForKey:key];
            break;
        }
            
        default:
            break;
            
    }
}
    

@end
