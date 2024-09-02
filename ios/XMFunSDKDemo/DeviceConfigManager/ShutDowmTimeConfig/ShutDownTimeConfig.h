//
//  ShutDownTimeConfig.h
//  FunSDKDemo
//
//  Created by XM on 2019/3/18.
//  Copyright © 2019年 XM. All rights reserved.
//

/****
 *
 * 获取和设置设备休眠时间 （目前只有部分设备支持休眠，例如门铃、门锁、猫眼、喂食器等等，但是支持休眠的设备类型一直在增加）
 *休眠时间单位为秒S，
 *
 *///


#import "FunMsgListener.h"

@protocol ShutDownTimeConfigDelegate <NSObject>

#pragma mark 获取设备休眠时间结果回调
- (void)getShutDownTimeConfigResult:(int)result;

#pragma mark 保存设备休眠时间结果回调
- (void)setShutDownTimeConfigResult:(int)result;

- (void)recyleSleepAndWakeup;



@end

NS_ASSUME_NONNULL_BEGIN

@interface ShutDownTimeConfig : FunMsgListener
@property (nonatomic, assign) id <ShutDownTimeConfigDelegate> delegate;
@property (nonatomic, assign) int time;

//获取设备休眠时间
-(void)getShutDownTime;
//设置休眠时间
-(void)setSutDownTime:(int)shutDownTime;
//进入休眠
- (void)setDeviceSleep;
//唤醒
- (void)setDevicewake;
@end

NS_ASSUME_NONNULL_END
