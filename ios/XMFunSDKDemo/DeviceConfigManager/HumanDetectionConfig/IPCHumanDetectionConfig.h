//
//  IPCHumanDetectionConfig.h
//  FunSDKDemo
//
//  Created by zhang on 2019/7/4.
//  Copyright © 2019 zhang. All rights reserved.
//

/******
 人形检测json数据
 {
     "Detect.HumanDetection.[0]": {   //通道0
         "Enable": true,   //总开关
         "ObjectType": 0,
         "PedFdrAlg": 1,
         "PedRule": [{    //报警规则
             "Enable": true, , //是否使用 这个Rule
             "RuleLine": { //警戒线 两个点确定一条线
                 "AlarmDirect": 2, //报警方向 0 从左向右；1 从右向左； 2双向
                 "Pts": {
                     "StartX": 1156,
                     "StartY": 4332,
                     "StopX": 2422,
                     "StopY": 2837
                 }
             },
             "RuleRegion": { //报警区域 3-6个点确定一个区域
                 "AlarmDirect": 2,
                 "Pts": [{
                     "X": 0,
                     "Y": 0
                 }, {
                     "X": 0,
                     "Y": 8192
                 }, {
                     "X": 8192,
                     "Y": 8192
                 }, {
                     "X": 8192,
                     "Y": 0
                 }, {
                     "X": 3300,
                     "Y": 2615
                 }],
                 "PtsNum": 4
             },
             "RuleType": 1
         }, {
             "Enable": false, //是否使用 这个Rule
             "RuleLine": {
                 "AlarmDirect": 2,
                 "Pts": {
                     "StartX": 100,
                     "StartY": 100,
                     "StopX": 8100,
                     "StopY": 8100
                 }
             },
             "RuleRegion": {
                 "AlarmDirect": 2,
                 "Pts": [{
                     "X": 100,
                     "Y": 100
                 }, {
                     "X": 8100,
                     "Y": 100
                 }, {
                     "X": 8100,
                     "Y": 8100
                 }, {
                     "X": 100,
                     "Y": 8100
                 }],
                 "PtsNum": 4
             },
             "RuleType": 1
         }, {
             "Enable": false,
             "RuleLine": {
                 "AlarmDirect": 2,
                 "Pts": {
                     "StartX": 100,
                     "StartY": 100,
                     "StopX": 8100,
                     "StopY": 8100
                 }
             },
             "RuleRegion": {
                 "AlarmDirect": 2,
                 "Pts": [{
                     "X": 100,
                     "Y": 100
                 }, {
                     "X": 8100,
                     "Y": 100
                 }, {
                     "X": 8100,
                     "Y": 8100
                 }, {
                     "X": 100,
                     "Y": 8100
                 }],
                 "PtsNum": 4
             },
             "RuleType": 1
         }, {
             "Enable": false,
             "RuleLine": {
                 "AlarmDirect": 2,
                 "Pts": {
                     "StartX": 100,
                     "StartY": 100,
                     "StopX": 8100,
                     "StopY": 8100
                 }
             },
             "RuleRegion": {
                 "AlarmDirect": 2,
                 "Pts": [{
                     "X": 100,
                     "Y": 100
                 }, {
                     "X": 8100,
                     "Y": 100
                 }, {
                     "X": 8100,
                     "Y": 8100
                 }, {
                     "X": 100,
                     "Y": 8100
                 }],
                 "PtsNum": 4
             },
             "RuleType": 1
         }],
         "PushInterval": 3000,    推送间隔
         "Sensitivity": 1,
         "ShowRule": 0,     //是否显示规则
         "ShowTrack": 0    //是否显示踪迹
     },
     "Name": "Detect.HumanDetection.[0]",
     "Ret": 100,
     "SessionID": "0x187"
 }
 
 * 人形检测配置 IPC
 * 需要先获取能力级，判断是否支持人形检测  SystemFunction.AlarmFunction.PEAInHumanPed
 *****/
@protocol IPCHumanDetectionDelegate <NSObject>

@optional
//获取能力级回调信息
- (void)IPCHumanDetectionConfigGetResult:(NSInteger)result;
//设置人形检测开关回调
- (void)IPCHumanDetectionConfigSetResult:(NSInteger)result;

@end
#import "ConfigControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface IPCHumanDetectionConfig : ConfigControllerBase

@property (nonatomic, assign) id <IPCHumanDetectionDelegate> delegate;


#pragma mark - 获取人形检测配置
- (void)getHumanDetectionConfig;

#pragma mark - 读取人形检测报警功能开关状态
-(int)getHumanDetectEnable;
#pragma mark 读取人形检测报警轨迹开关状态
-(int)getHumanDetectShowTrack;
#pragma mark 读取人形检测报警规则开关状态
-(int)getHumanDetectShowRule;

#pragma mark - 设置人形检测报警功能开关状态
-(void)setHumanDetectEnable:(int)enable;
#pragma mark 设置人形检测报警轨迹开关状态
-(void)setHumanDetectShowTrack:(int)ShowTrack;
#pragma mark 设置人形检测报警规则开关状态
-(void)setHumanDetectShowRule:(int)showrule;
@end

NS_ASSUME_NONNULL_END
