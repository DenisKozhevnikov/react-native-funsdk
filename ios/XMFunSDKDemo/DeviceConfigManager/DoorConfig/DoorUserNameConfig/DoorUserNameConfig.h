//
//  DoorUserNameConfig.h
//  FunSDKDemo
//
//  Created by XM on 2019/4/11.
//  Copyright © 2019年 XM. All rights reserved.
//
/******
 
 门锁用户名称修改
 1、先获取门锁用户信息
 2、修改门锁各个用户名信息 （包括管理员、普通成员、宾客等等的信息）（又包括密码、指纹、门卡等类型）
 
 *******/
#pragma mark - 代理回调
@protocol DoorUserNameDelegate <NSObject>
@optional
//获取门锁用户信息回调
- (void)DoorUserNameConfigGetResult:(NSInteger)result;
//设置门锁用户信息回调
- (void)DoorUserNameConfigSetResult:(NSInteger)result;

@end
#import "ConfigControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoorUserNameConfig : ConfigControllerBase

@property (nonatomic, assign) id <DoorUserNameDelegate> delegate;

#pragma mark - 获取门锁用户信息
- (void)getDoorUserNameConfig;
#pragma mark 设置门锁用户信息
- (void)setDoorUserName:(NSMutableDictionary*)dic;

#pragma mark -  设置门锁用户信息
- (NSMutableDictionary*)getDoorUserInfo;
@end

NS_ASSUME_NONNULL_END
