//
//  SubscribeManager.h
//  FunSDKDemo
//
//  Created by XM on 2023/9/25.
//  Copyright © 2023年 XM. All rights reserved.
//
/***
 
MQTT订阅接口
 *****/

@protocol SubscribeManagerDelegate <NSObject>
//初始化MQTT回调
- (void)initSubscribeServerDelegateResult:(NSInteger)result;
//注销MQTT回调
- (void)uninitSubscribeServerDelegateResult:(NSInteger)result;

//订阅设备在线状态通知结果
- (void)SubscribeFromServerDelegate:(NSString *)deviceMac Result:(NSInteger)result;
//取消订阅设备在线状态通知结果
- (void)UnSubscribeFromServerDelegate:(NSString *)deviceMac Result:(NSInteger)result;

//服务端下发的状态回调
- (void)messageFromServer:(NSString*)deviceMac message:(NSString*)message;
@end


#import <Foundation/Foundation.h>
#import "FunMsgListener.h"

@interface SubscribeManager : FunMsgListener
{
    
}
@property (nonatomic, assign) id <SubscribeManagerDelegate> delegate;

+ (instancetype)getInstance;

#pragma mark 初始化MQTT服务
- (void)initSubscribeServer;
- (void)unInitSubscribeServer;

//订阅设备在线状态通知
- (void)subscribeFromServer:(NSString*)deviceMac;
//取消订阅设备在线状态通知 （删除设备时，请先调用取消订阅接口）
- (void)unSubscribeFromServer:(NSString*)deviceMac;
@end
