//
//  LightBulbViewController.h
//  FunSDKDemo
//
//  Created by zhang on 2019/12/10.
//  Copyright © 2019 zhang. All rights reserved.
//
/***************
*
*灯泡配置配置视图控制器  （就是APP中的 控制模式配置：星光全彩、红外夜视、双光警戒）
*在这里设置灯泡开关、模式、定时等等
 
 * 灯泡配置
 * Camera_WhiteLight 灯泡配置   获取当前正在使用的配置
 *
 *示例 json格式：{
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
 Duration：持续亮灯时间 默认设置范围(5s,30s,120s)，可根据需求自行设置
 Level: 灵敏度 1->低 3->中 5->高   
 WorkMode: 工作模式  Auto：自动模式，isp里根据环境亮度自动开关
 Timming：定时模式
 KeepOpen：一直开启
 Intelligent：智能模式 (双光灯)
 Atmosphere: 气氛灯 (音乐灯)
 Glint: 随音乐闪动 (音乐灯)
 Close：关闭
 WorkPeriod：工作时间段 在timming模式下有效
*
*/
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LightBulbViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
