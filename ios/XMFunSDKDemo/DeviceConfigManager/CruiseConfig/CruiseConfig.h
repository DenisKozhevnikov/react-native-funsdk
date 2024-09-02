//
//  CruiseConfig.h
//  FunSDKDemo
//
//  Created by zhang on 2019/6/25.
//  Copyright © 2019 zhang. All rights reserved.
//
/************
 1、根据能力级判断是否支持巡航
 2、根据能力级判断是否同时支持移动追踪和守望，如果支持，显示移动追踪和守望点功能
 3、获取巡航点，并且刷新界面显示 （巡航点数组，对象参数包括ID，名称、巡航点停留时间）
 4、增删巡航点（修改巡航点需要先删除再增加）
 5、跳转到某一个巡航点
 6、开始巡航，设置巡航次数
 7、添加守望点
 8、设置移动追踪参数 （开关、灵敏度、追踪结束回守望点守望时间）
 9、⚠️注意：移动追踪和人形检测功能不兼容，只能同时打开一个。当APP打开一个配置时，设备会自动把另一个配置关闭。
 **********/


/*******
 Uart.PTZTour 巡航信息配置json
 Id：巡航线id
 Name：巡航线name
 Tour：巡航线中的巡航点数组
 Tour.Id:巡航点ID
 Tour.Name:巡航点name
 Tour.Time:巡航点停留时间
 "Uart.PTZTour" : [ [ { "Id" : 0, "Name" : "", "Tour" : [ { "Id" : 252, "Name" : "", "Time" : 3 }, { "Id" : 253, "Name" : "", "Time" : 3 }, { "Id" : 254, "Name" : "", "Time" : 3 } ] } ] ]
 
 ********/

@protocol CruiseConfigDelegate <NSObject>

-(void)OnGetCruisePoint:(NSArray *_Nullable)points result:(int)result;

-(void)OnDeleteCruisePoint:(int)num result:(int)result;

-(void)OnSetCruisePoint:(int)num result:(int)result;

-(void)OnGotoCruisePoint:(int)num result:(int)result;

-(void)OnStartCruiseWithResult:(int)result;

-(void)OnStopCruiseWithResult:(int)result;

//移动追踪请求回调
- (void)OngetDetectTrackResult:(int)result;
//移动追踪设置回调
- (void)OnsetDetectTrackResult:(int)result;



//添加守望点回调
- (void)setWatchPointResult:(int)result;

@end

#import "ConfigControllerBase.h"
#import "CruiseDataSource.h"


NS_ASSUME_NONNULL_BEGIN
@interface CruiseConfig : ConfigControllerBase

+(CruiseConfig *)sharedInstance;


@property (nonatomic, weak) id<CruiseConfigDelegate> delegate;

@property (nonatomic, assign) int currentTourNum;//当前循环线编号

@property (nonatomic,assign) BOOL tempNoDismiss;    // 临时不取消提示

//查询 获取巡航点
-(void)FunGetCruisePoint;
//添加 这里的编号 分别代表标号为252，253，254的预置点
-(void)FunAddCruisePointWithNum:(int)num;
//跳转到某个预置点
-(void)FunGotoCruisePointWithNum:(int)num;
//重置巡航
-(void)FunResetCruisePointWithNum:(int)num;
//删除
-(void)FunDeleteCruisePointWithNum:(int)num;
//删除所有
-(void)FunDeleteAllCruisePoint;
//开始巡航
-(void)FunStartCruise;
//停止巡航
-(void)FunStopCruise;
//360巡航
-(void)Fun360Cruise;
//添加守望点
-(void)setWatchPointWithNum:(int)num;




#pragma mark 查询和设置 移动追踪
- (void)FungetDetectTrack;
- (void)setTrackConfig;

#pragma mark 读取和设置请求到的移动追踪属性
- (BOOL)getTrackEnable;
- (int)getTrackSensitivity;
- (int)getTrackReturnTime;

- (void)setTrackEnable:(BOOL)enable;
- (void)setTrackSensitivity:(int)sitivity;
- (void)setTrackReturnTime:(int)returnTime;
@end

NS_ASSUME_NONNULL_END
