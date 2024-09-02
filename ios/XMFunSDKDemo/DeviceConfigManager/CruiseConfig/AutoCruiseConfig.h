//
//  AutoCruiseConfig.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/7/8.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AutoCruiseConfigTimingCfgCallBack)(int result,NSDictionary *info);

@protocol AutoCruiseConfigDelegate <NSObject>

-(void)OnGetAutoCruisePoint:(NSArray *_Nullable)points result:(int)result;

-(void)OnDeleteAutoCruisePoint:(int)num result:(int)result;

-(void)OnSetAutoCruisePoint:(int)num result:(int)result;

@end

/*
 定时巡航管理者
 
 是否支持判断 ： 能力集  Systemfunction.OtherFunction.SupportTimingPtzTour
 主要功能：1.定时巡航开关
         2.定时巡航时间间隔
         3.定时巡航点设置 目前和预置点设置一样 就设置预置点那3个点
 
 获取定时巡航配置：
 {
 "General.TimimgPtzTour": [
 {
 "Enable": false,        // 功能开关
 "TimeInterval": 3600    // 时间间隔, 单位S
 }
 ]
 }
 
 增加删除巡航点
 巡航点具体数据结构：
 {
 "OPPTZControl":    {
 "Command":    "AddTour",
 "Parameter":    {
 "Preset":    252,
 "PresetIndex":    0,
 "Step":    3,                     /////// 停留时间修改为10
 "Tour":    0,
 "TourTimes":    1
 }
 },
 "Name":    "OPPTZControl",
 "SessionID":    "0x0000000001"
 }
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface AutoCruiseConfig : NSObject

// 设备序列号 必须提供
@property (nonatomic,copy) NSString *devID;
// 定时配置载体
@property (nonatomic,strong) NSMutableDictionary *dicTimingCfg;
// 已设置巡航点列表
@property (nonatomic,strong) NSMutableArray *arrayPointList;
// 定时配置回调
@property (nonatomic,copy) AutoCruiseConfigTimingCfgCallBack timingCfgCallBack;
@property (nonatomic,weak) id<AutoCruiseConfigDelegate> delegate;
// 当前循环线编号
@property (nonatomic, assign) int currentTourNum;

//MARK: 获取定时配置
- (void)getTimingCfg:(AutoCruiseConfigTimingCfgCallBack)callBack;
//MARK: 设置定时配置
- (void)saveTimingCfg:(AutoCruiseConfigTimingCfgCallBack)callBack;
//MARK: 获取巡航列表
- (void)getCruiseList;
//MARK: 添加巡航点 和手动巡航一样的点 这里的编号 分别代表标号为252，253，254的预置点
- (void)addPoint:(int)num;
//MARK: 删除巡航点
- (void)deletePoint:(int)num;
//MARK: 重置巡航点
- (void)resetPoint:(int)num;

// 获取定时是否打开
- (BOOL)getTimingOpen;
// 获取定时间隔
- (int)getInterval;

// 设置定时开关
- (void)setTimingOpen:(BOOL)ifOpen;
// 设置定时间隔
- (void)setInterval:(int)time;

@end

NS_ASSUME_NONNULL_END
