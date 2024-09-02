//
//  DoorTempPasswordConfig.h
//  FunSDKDemo
//
//  Created by XM on 2019/4/10.
//  Copyright © 2019年 XM. All rights reserved.
//

/******
 
 门锁临时密码
 1、先获取门锁信息
 2、设置门锁临时密码 （包含密码有效期和有效次数等）
 
 *******/
@protocol DoorTempPasswordDelegate <NSObject>

@optional
//获取门锁临时密码回调信息
- (void)tempPasswordConfigGetResult:(NSInteger)result;
//设置门锁临时密码回调
- (void)tempPasswordConfigSetResult:(NSInteger)result;

@end
#import "ConfigControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoorTempPasswordConfig : ConfigControllerBase

@property (nonatomic, assign) id <DoorTempPasswordDelegate> delegate;

#pragma mark 获取门锁临时密码信息
- (void)getDoorDevListConfig;
 #pragma mark 设置门锁临时密码
- (void)setDoorTempPassword;

 #pragma mark - 读取获取到的密码信息
- (int)getPasswordNumber; //密码有效次数
- (NSString*)getPassword; //密码
- (NSString*)getStartTime; //生效时间
- (NSString*)getEndTime; //失效时间

#pragma mark - 设置临时密码
- (void)setPasswordNumber:(int)num; //密码有效次数
- (void)setPassword:(NSString*)password; //密码
- (void)setStartTime:(NSString*)start; //生效时间
- (void)setEndTime:(NSString*)end; //失效时间
@end

NS_ASSUME_NONNULL_END
