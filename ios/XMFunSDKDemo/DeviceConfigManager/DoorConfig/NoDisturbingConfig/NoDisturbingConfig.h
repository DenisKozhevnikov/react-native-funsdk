//
//  NoDisturbingConfig.h
//  FunSDKDemo
//
//  Created by XM on 2019/4/15.
//  Copyright © 2019年 XM. All rights reserved.
//
/********
 
免打扰管理
1、免打扰总开关
2、深度休眠开关
 3、是否开启消息推送
 4、功能开始时间
5、功能结束时间
 
 ******/
#pragma mark - 代理回调
@protocol NoDisturbingDelegate <NSObject>
@optional
//免打扰管理获取回调
- (void)NoDisturbingConfigGetResult:(NSInteger)result;
//设置免打扰管理回调
- (void)NoDisturbingConfigSetResult:(NSInteger)result;

@end
#import "ConfigControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoDisturbingConfig : ConfigControllerBase

@property (nonatomic, assign) id <NoDisturbingDelegate> delegate;

#pragma mark - 获取免打扰管理开关信息
- (void)getNoDisturbingConfig;
#pragma mark 设置免打扰管理开关信息
- (void)setNoDisturbingConfig;

#pragma mark - 读取免打扰开关
- (BOOL)getNoDisturbingEnable;
#pragma mark  读取消息推送开关
- (BOOL)getMessageEnable;
#pragma mark  读取深度休眠开关
- (BOOL)getSleepEnable;
#pragma mark  读取免打扰开始时间
- (NSString*)getStartTime;
#pragma mark  读取免打扰结束时间
- (NSString*)getEndTime;

#pragma mark - 设置免打扰开关
- (void)setNoDisturbingEnable:(BOOL)enable;
#pragma mark  设置消息推送开关
- (void)setMessageEnable:(BOOL)enable;
#pragma mark  设置深度休眠开关
- (void)setSleepEnable:(BOOL)enable;
#pragma mark  设置免打扰开始时间
- (void)setStartTime:(NSString*)time;
#pragma mark  设置免打扰结束时间
- (void)setEndTime:(NSString*)time;

@end

NS_ASSUME_NONNULL_END
