//
//  LightBulbConfig.h
//  FunSDKDemo
//
//  Created by zhang on 2019/12/11.
//  Copyright © 2019 zhang. All rights reserved.
//
/***
 *
 * 灯泡配置
 * Camera_WhiteLight 灯泡配置   获取当前正在使用的配置
 *
 *示例 json格式：{
 "Brightness":50,
 "MoveTrigLight":{
 "Duration":    60,
 "Level":    5
 },
 "WorkMode":    "Intelligent",
 "WorkPeriod":    {
 "EHour":    6,
 "EMinute":    0,
 "Enable":    1,
 "SHour":    18,
 "SMinute":    0
 }
 }
 *
 *json说明：
 MoveTrigLight：移动物体自动亮灯（智能模式下有效）
 Duration：持续亮灯时间 超级看看中设置范围(5s,10s,30s,60s,90s,120s)
 Level: 灵敏度 1->低 3->中 5->高
 Brightness：亮度
 WorkMode: 工作模式  Auto：星光全彩（自动模式，isp里根据环境亮度自动开关)
 Timming：定时模式
 KeepOpen：一直开启
 Intelligent：智能模式 (双光灯) 双光警戒
 Atmosphere: 气氛灯 (音乐灯)
 Glint: 随音乐闪动 (音乐灯)
 Close：关闭（红外夜视）
 WorkPeriod：工作时间段 在timming模式下有效
 *
 *****/
@protocol WhiteLightConfigDelegate <NSObject>
//获取编码配置代理回调
- (void)getWhiteLightConfigResult:(NSInteger)result;
//保存编码配置代理回调
- (void)setWhiteLightConfigResult:(NSInteger)result;

@end
#import "ConfigControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LightBulbConfig : ConfigControllerBase

@property (nonatomic, assign) id <WhiteLightConfigDelegate> delegate;

- (void)getDeviceConfig;
- (void)setDeviceConfig;

- (int)getLightBrightness; //获取亮度值
- (int)getMoveTrigLightDuration; //获取自动亮灯时间
- (int)getMoveTrigLightLevel;  //获取自动亮灯灵敏度
- (NSString*)getWorkMode;  //获取工作模式
- (BOOL)getWorkPeriodEnable;  //获取工作时间段开关
- (int)getWorkPeriodSHour;  //获取工作时间段
- (int)getWorkPeriodSMinute;  //获取工作时间段
- (int)getWorkPeriodEHour;  //获取工作时间段
- (int)getWorkPeriodEMinute;  //获取工作时间段

- (void)setLightBrightness:(int)value; //设置亮度值
- (void)setMoveTrigLightDuration:(int)value; //设置自动亮灯时间
- (void)setMoveTrigLightLevel:(int)value;  //设置自动亮灯灵敏度
- (void)setWorkMode:(NSString*)value; //设置工作模式
- (void)setWorkPeriodEnable:(BOOL)value;  //设置工作时间段开关
- (void)setWorkPeriodSHour:(int)value;  //设置工作时间段
- (void)setWorkPeriodSMinute:(int)value;  //设置工作时间段
- (void)setWorkPeriodEHour:(int)value;  //设置工作时间段
- (void)setWorkPeriodEMinute:(int)value;  //设置工作时间段
@end

NS_ASSUME_NONNULL_END
