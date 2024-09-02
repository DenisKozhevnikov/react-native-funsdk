//
//  HumanDetectionConfig.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/12/27.
//  Copyright © 2018 wujiangbo. All rights reserved.
//
/******
 徘徊检测配置

*****/
#import <Foundation/Foundation.h>
#import "ConfigControllerBase.h"
NS_ASSUME_NONNULL_BEGIN


@protocol AlarmPIRConfigDelegate <NSObject>

@optional
//获取徘徊检测回调信息
- (void)AlarmPIRConfigGetResult:(NSInteger)result;
//设置徘徊检测开关回调
- (void)AlarmPIRConfigSetResult:(NSInteger)result;

@end
@interface AlarmPIRConfig : ConfigControllerBase

@property (nonatomic, assign) id <AlarmPIRConfigDelegate> delegate;

#pragma mark - 获取徘徊检测配置
-(void)getAlarmPIRConfig;
#pragma mark - 读取徘徊检测报警功能开关状态
-(BOOL)getAlarmPIREnable;
#pragma mark - 读取徘徊检测时间长度
- (int)getAlarmPIRCheckTime;
//MARK: 取出徘徊检测灵敏度（PIR灵敏度）
- (int)getAlarmPirSensitive;
//MARK: 取出徘徊检测录像时长
- (int)getAlarmRecordLength;

#pragma mark - 设置徘徊检测报警功能开关状态
- (void)setAlarmPIREnable:(BOOL)enable;
#pragma mark - 设置徘徊检测时间长度
- (void)setAlarmPIRCheckTime:(int)enable;
#pragma mark - 设置徘徊检测灵敏度
//灵敏度 1是最低的 5是最高的
-(void)setAlarmPirSensitive:(int)enable;
//MARK: 设置徘徊检测录像时长
- (void)setAlarmRecordLength:(int)lenght;

@end

NS_ASSUME_NONNULL_END
