//
//  DeviceConfig.h
//  XWorld
//
//  Created by liuguifang on 16/5/23.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FunSDK/JObject.h>
#import "DeviceConfig.h"

@class DeviceConfig;

@protocol DeviceConfigDelegate <NSObject>

@optional
-(void)getConfig:(DeviceConfig*)config result:(int)result;

-(void)setConfig:(DeviceConfig*)config result:(int)result;

@end

@interface DeviceConfig : NSObject

@property (nonatomic, assign) BOOL isSet;               //是否可以设置
@property (nonatomic, assign) BOOL isGet;               //是否可以获取
@property (nonatomic, copy) NSString* devId;            //设备id
@property (nonatomic, copy) NSString* name;             //配置名称
@property (nonatomic, assign) int channel;              //通道号
@property (nonatomic, copy) NSString* jLastStrCfg;      //上次的配置
@property (nonatomic, assign) JObject* jObject;          //当前配置
@property (nonatomic, weak) id<DeviceConfigDelegate> delegate;  //配置获取、设置代理
@property (nonatomic, assign) int nCfgCommand;          // 命令，默认0
@property (nonatomic, assign) int nBinary;
-(instancetype)initWithJObject:(JObject*)jobject;

+(DeviceConfig *)initWith:(NSString*)devId Channel:(int)Channel GetSet:(int)nGetSet Resutl:(JObject *)pResult Delegate:(id)Delegate;
@end

