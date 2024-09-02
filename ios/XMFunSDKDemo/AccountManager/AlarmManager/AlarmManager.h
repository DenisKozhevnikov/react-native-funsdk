//
//  AlarmManager.h
//  FunSDKDemo
//
//  Created by XM on 2018/5/5.
//  Copyright © 2018年 XM. All rights reserved.
//
/***
 
 设备报警，继承自 FunMsgListener，包括注册和注销设备报警，需要和设备报警开关同时使用
 如果需要设备报警推送到手机，则需要在这里注册报警推送，并且在设备报警配置中也要打开设备报警开关
 （这里是向报警服务器注册和注销设备信息，而报警配置中才是真正的打开设备报警配置）
 
 ** 如果需要定制报警服务器，则初始化报警服务器接口处需要多传递一个报警服务器URL
   具体格式请看下面 TESTURL
 *****/
#define TESTURL  @"Third:your_alarm_url"   //定制报警服务器示例URL，URL前面需要加上 Third:                    示例：Third:http://devtech.com/callback/5719.html

@protocol AlarmManagerDelegate <NSObject>
//注册设备报警结果
- (void)LinkAlarmDelegate:(NSString *)deviceMac Result:(NSInteger)result;
//注销设备报警结果
- (void)UnlinkAlarmAlarmDelegate:(NSString *)deviceMac Result:(NSInteger)result;
@end


typedef enum {
    DevelopmentType = 200,
    ProductionType = 3,
}PushType;

#import <Foundation/Foundation.h>
#import "FunMsgListener.h"

@interface AlarmManager : FunMsgListener
{
    
}
@property (nonatomic, assign) id <AlarmManagerDelegate> delegate;

+ (instancetype)getInstance;

#pragma mark 初始化报警服务器
- (void)initServer:(const char*)tokenChar; //如果需要定制报警服务器的话，需要修改这个方法（方法内部已做说明）
#pragma mark 报警和注销报警
- (void)LinkAlarm:(NSString *)deviceMac DeviceName:(NSString *)devName;
- (void)UnlinkAlarm:(NSString *)deviceMac;
@end
