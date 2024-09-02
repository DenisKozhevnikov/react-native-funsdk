//
//  AlarmManager.m
//  FunSDKDemo
//
//  Created by XM on 2018/5/5.
//  Copyright © 2018年 XM. All rights reserved.
//

#define SERVER_MQTT_FLAG @"MQTT_SERVER"
#define HOST_MQTT_TEST @"jfmq-v2-pre.xmcsrv.net"
#define HOST_MQTT_PRODUCT @"jfmq-v2.xmcsrv.net"
#define PORT_MQTT 1883

#import "SubscribeManager.h"
#import "FunSDK/Fun_MC.h"
#import <FunSDK/FunSDK.h>

@implementation SubscribeManager

+ (instancetype)getInstance {
    static SubscribeManager *Manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Manager = [[SubscribeManager alloc]init];
    });
    return Manager;
}
- (id)init {
    self = [super init];
    return self;
}

//MQTT初始化
- (void)initSubscribeServer{
    FUN_SysSetServerIPPort(CSTR(SERVER_MQTT_FLAG), CSTR(HOST_MQTT_PRODUCT), PORT_MQTT);
    //MQTT初始化
//    Fun_MQTTInit(self.msgHandle);
}
- (void)unInitSubscribeServer{
    //MQTT反初始化
    Fun_MQTTUnInit(self.msgHandle);
}

//订阅设备在线状态通知
- (void)subscribeFromServer:(NSString*)deviceMac {
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"devicemsg",@"SubscribeInfo",@[deviceMac],@"Sn", nil];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    int result = Fun_SubscribeInfoFromServer(self.msgHandle, SZSTR(jsonString),0);
    
    dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"status",@"SubscribeInfo",@[deviceMac],@"Sn", nil];
    jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    result = Fun_SubscribeInfoFromServer(self.msgHandle, SZSTR(jsonString),0);
}

//取消订阅设备在线状态通知
- (void)unSubscribeFromServer:(NSString*)deviceMac {
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"devicemsg",@"SubscribeInfo",@[deviceMac],@"Sn", nil];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    int result = Fun_UnSubscribeInfoFromServer(self.msgHandle, SZSTR(jsonString),0);
    
    dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"status",@"SubscribeInfo",@[deviceMac],@"Sn", nil];
    jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    result = Fun_UnSubscribeInfoFromServer(self.msgHandle, SZSTR(jsonString),0);
}

#pragma mark - 回调函数
- (void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
            
        case EMSG_SYS_MQTT_CLIENT: //初始化MQTT回调 （MQTT在任何地方订阅的回调都会回调到本类文件）
            if (msg->param1 < 0) {
                //初始化失败
            }else{
                //初始化成功
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(initSubscribeServerDelegateResult:)]) {
                [self.delegate initSubscribeServerDelegateResult:msg->param1];
            }
            break;
        case EMSG_SYS_MQTT_UNINIT: //反初始化
            if (msg->param1 < 0) {
                //反初始化失败
            }else{
                //反初始化成功
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(uninitSubscribeServerDelegateResult:)]) {
                [self.delegate uninitSubscribeServerDelegateResult:msg->param1];
            }
            break;
        case EMSG_SYS_MQTT_SUBSCRIBE_INFO: //订阅结果
            if (msg->param1 < 0) {
                //订阅失败
            }else{
                //订阅成功
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(SubscribeFromServerDelegate:Result:)]) {
                [self.delegate SubscribeFromServerDelegate:NSSTR(msg->szStr) Result:msg->param1];
            }
            break;
        case EMSG_SYS_MQTT_UNSUBSCRIBE_INFO: //取消订阅结果
            if (msg->param1 < 0) {
                //取消订阅失败
            }else{
                //取消订阅成功
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(UnSubscribeFromServerDelegate:Result:)]) {
                [self.delegate UnSubscribeFromServerDelegate:NSSTR(msg->szStr) Result:msg->param1];
            }
            break;
            
        case EMSG_SYS_MQTT_RETURNMSG: //服务端主动向APP推送设备的订阅消息
            if (self.delegate && [self.delegate respondsToSelector:@selector(messageFromServer:message:)]) {
                [self.delegate messageFromServer:NSSTR(msg->szStr) message:NSSTR(msg->pObject)];
            }
            NSLog([NSString stringWithFormat:@"EMSG_SYS_MQTT_RETURNMSG = %@",NSSTR(msg->pObject)]);
            break;
        case EMSG_SYS_MQTT_RECONECTEDFAIL: //服务端主动向APP推送设备的订阅消息 （设备短线重联时，多次重联设备都失败了，在此回调失败原因）
            //msg->param1 最后一次连接失败的错误值
            //msg->param2 连接失败的次数
            break;
                    
        default:
            break;
    }
}

@end
