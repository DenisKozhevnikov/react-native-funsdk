//
//  BaseJConfigController.h
//  XWorld
//
//  Created by liuguifang on 16/6/3.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FunSDK/JObject.h>

@class DeviceConfig;

@interface BaseJConfigController : UIViewController
@property (nonatomic, copy) NSString* devId;
@property (nonatomic) NSMutableArray* arrayCfgReqs;

#pragma mark - 请求获取配置
-(void)requestGetConfig:(DeviceConfig*)config;

#pragma mark - 请求设置配置
-(void)requestSetConfig:(DeviceConfig*)config;

@end
