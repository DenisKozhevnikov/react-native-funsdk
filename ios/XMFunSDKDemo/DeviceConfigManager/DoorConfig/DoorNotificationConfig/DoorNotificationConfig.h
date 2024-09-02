//
//  DoorNotificationConfig.h
//  FunSDKDemo
//
//  Created by XM on 2019/4/17.
//  Copyright © 2019年 XM. All rights reserved.
//
/********
 
消息推送管理
 1、密码消息推送  (mPassWdManger)
 2、门卡消息推送  (mCardManger)
 3、指纹消息推送  (mFingerManger)
 备注： demo中只显示了密码消息推送开关，门卡和指纹的消息推送开关没有做处理
 ******/
#pragma mark - 代理回调
@protocol DoorNotificationDelegate <NSObject>
@optional
//消息推送管理获取回调
- (void)DoorNotificationConfigGetResult:(NSInteger)result;
//消息推送管理设置回调
- (void)DoorNotificationConfigSetResult:(NSInteger)result;

@end
#import "ConfigControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoorNotificationConfig : ConfigControllerBase

@property (nonatomic, assign) id <DoorNotificationDelegate> delegate;

#pragma mark - 获取消息推送管理开关信息
- (void)getDoorNotificationConfig;
#pragma mark 设置消息推送管理开关信息
- (void)setDoorNotificationConfig;

#pragma mark - 获取密码数量
- (int)checkPasswordAdmin; //管理员密码
- (int)checkPasswordGeneral; //普通成员密码
- (int)checkPasswordGuest; //宾客
- (int)checkPasswordTemporary; //临时
- (int)checkPasswordForce; //强力

#pragma mark - 获取密码消息推送信息
- (NSMutableArray*)getPasswordAdmin;
- (NSMutableArray*)getPasswordGeneral;
- (NSMutableArray*)getPasswordGuest;
- (NSMutableArray*)getPasswordTemporary;
- (NSMutableArray*)getPasswordForce;

#pragma mark - 设置密码消息推送信息
- (void)setPasswordAdmin:(NSMutableArray*)array;
- (void)setPasswordGeneral:(NSMutableArray*)array;
- (void)setPasswordGuest:(NSMutableArray*)array;
- (void)setPasswordTemporary:(NSMutableArray*)array;
- (void)setPasswordForce:(NSMutableArray*)array;
@end

NS_ASSUME_NONNULL_END
