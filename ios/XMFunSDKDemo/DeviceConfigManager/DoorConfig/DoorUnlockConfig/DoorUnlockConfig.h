//
//  DoorUnlockConfig.h
//  FunSDKDemo
//
//  Created by XM on 2019/4/9.
//  Copyright © 2019年 XM. All rights reserved.
//

/*******
 
 门锁的远程开锁功能
 1、获取设备UnlockID
 2、通过设备UnlockID和开锁密码进行开锁
 
 ******/
@protocol DoorUnlockDelegate <NSObject>

@optional
//获取门锁ID回调信息
- (void)DoorUnlockConfigGetResult:(NSInteger)result;
//远程开锁回调
- (void)DoorUnlockConfigSetResult:(NSInteger)result;

@end
#import "ConfigControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoorUnlockConfig : ConfigControllerBase

@property (nonatomic, assign) id <DoorUnlockDelegate> delegate;

#pragma mark 获取门锁远程开锁的doorUnlockID，调用前需要先判断远程开锁能力级
- (void)getDoorUnlockIDConfig;
#pragma mark 远程开锁
- (void)setDoorUnlock:(NSString*)password;
@end

NS_ASSUME_NONNULL_END
