//
//  ElectricityConfig.h
//  FunSDKDemo
//
//  Created by zhang on 2019/5/10.
//  Copyright © 2019 zhang. All rights reserved.
//
/******
* 获取低功耗设备剩余电量
* 设备上报功能目前包括两方面，一方面是电量上报，另一方面是存储卡状态上报
* 直接用GetConfig方法获取的可能会不准确，使用设备主动上报的方式获取的电量实时性最好
 *****/

@protocol ElectricityConfigDelegate <NSObject>

@optional
//获取设备电量上报回调信息
- (void)startUploadElectricityResult:(NSInteger)result;
//设置设备电量上报开关回调
- (void)stopUploadElectricityResult:(NSInteger)result;
//设备电量上报
- (void)deviceUploadElectricityResult:(NSInteger)result;

@end
#import "FunMsgListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface ElectricityConfig : FunMsgListener

@property (nonatomic) int percent; //剩余电量 百分比
@property (nonatomic) int electable; //充电状态 0：未充电 1：正在充电 2：电充满 3：未知（表示各数据不准确）

@property (nonatomic) int storageStatus; //TF卡状态： -2：设备存储未知 -1：存储设备被拔出 0：没有存储设备 1：有存储设备 2：存储设备插入
@property (nonatomic, assign) id <ElectricityConfigDelegate> delegate;

#pragma mark 设置设备开始上报s状态 （包括电量，存储状态）
- (void)startUploadElectricity;
#pragma mark 停止设备上报电量
- (void)stopUploadElectricity;
@end

NS_ASSUME_NONNULL_END
