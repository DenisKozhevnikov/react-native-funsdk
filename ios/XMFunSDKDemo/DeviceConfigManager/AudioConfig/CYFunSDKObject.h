//
//  CYFunSDKObject.h
//  XWorld_General
//
//  Created by SaturdayNight on 2018/9/11.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FunSDK/JObject.h>

@class DeviceConfig;

@interface CYFunSDKObject : NSObject

@property (nonatomic, copy) NSString* devID;
@property (nonatomic) NSMutableArray* arrayCfgReqs;

#pragma mark - 请求获取配置
-(void)requestGetConfig:(DeviceConfig*)config;

#pragma mark - 请求设置配置
-(void)requestSetConfig:(DeviceConfig*)config;

#pragma mark - 对象注销前调用
-(void)cleanContent;

@end
