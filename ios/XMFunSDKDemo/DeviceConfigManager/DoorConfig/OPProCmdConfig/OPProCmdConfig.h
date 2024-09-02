//
//  OPProCmdConfig.h
//  FunSDKDemo
//
//  Created by XM on 2019/4/12.
//  Copyright © 2019年 XM. All rights reserved.
//
/******
 
门锁消息统计
 1、获取门锁消息统计开关
 2、设置门锁消息统计开关
 3、消息统计功能打开的情况下，每天会推送一条门锁开门情况汇总信息，并且在设备信息功能中也可以查询到
 
 *******/
#pragma mark - 代理回调
@protocol OPProCmdDelegate <NSObject>
@optional
//获取门锁统计开关回调
- (void)OPProCmdConfigGetResult:(NSInteger)result;
//设置门锁统计开关回调
- (void)OPProCmdConfigSetResult:(NSInteger)result;

@end
#import "ConfigControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface OPProCmdConfig : ConfigControllerBase

@property (nonatomic, assign) id <OPProCmdDelegate> delegate;

#pragma mark 判断数据是否有效
- (BOOL)checkConfig;

#pragma mark - 获取门锁统计开关信息
- (void)getOPProCmdConfig;
#pragma mark 设置门锁统计开关信息
- (void)setOPProCmdConfig;

#pragma mark - 读取门锁信息中，消息统计开关
- (BOOL)getMessageCmdValue;
#pragma mark 设置门锁信息中，消息统计开关
- (void)setMessageCmdValue:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
