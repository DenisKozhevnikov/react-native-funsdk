//
//  DeviceRandomPwdManager.h
//  XWorld_General
//
//  Created by wujiangbo on 2021/9/8.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetDevPwdResult)(BOOL completion);
typedef void(^ChangeRandomUserResult)(int result,NSString *adminToken,NSString *guestToken);

@interface DeviceRandomPwdManager : NSObject

@property (nonatomic, copy) GetDevPwdResult getDevPwdResult;
@property (nonatomic, copy) ChangeRandomUserResult changeRandomUserResult;
@property (nonatomic, copy) void (^TokenDeviceLoginDeviceFailed)();
+(instancetype)shareInstance;

/**
 如果是随机用户名和密码，
 需要引导用户去设置当前用户名和设备密码。
 获取失败是否重试
 */
#pragma mark -- 从服务器获取设备是否是随机账户名密码。。如果是随机密码默认返回用户名admin和空密码
-(void)getDeviceRandomPwd:(NSString *)devID autoSetUserNameAndPassword:(BOOL)autoSet Completion:(GetDevPwdResult)completion;
#pragma mark -- 从服务器获取设备是否是随机账户名密码。。如果是随机密码默认返回用户名admin和空密码
-(void)getDeviceRandomPwd:(NSString *)devID autoSetUserNameAndPassword:(BOOL)autoSet WithTryAgain:(BOOL)tryAgain Completion:(GetDevPwdResult)completion;

#pragma mark -- 从本地获取设备是否是随机账户名密码。。如果是随机密码默认返回用户名admin和空密码
-(NSDictionary *)getDeviceRandomPwdFromLocal:(NSString *)devID;

#pragma mark -- 修改用户名和密码
-(void)ChangeRandomUserWithDevID:(NSString *)devID newUser:(NSString *)newUser newPassword:(NSString *)newPassword result:(ChangeRandomUserResult)result;

-(void)saveDevRandomPwdToLocalDataSource:(NSDictionary *)dataSource devID:(NSString *)devID;

@end

