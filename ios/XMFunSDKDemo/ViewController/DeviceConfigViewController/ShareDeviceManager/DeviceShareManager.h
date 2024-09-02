//
//  DeviceShareManager.h
//  FunSDKDemo
//
//  Created by yefei on 2022/10/21.
//  Copyright © 2022 yefei. All rights reserved.
//

#import <Foundation/Foundation.h>

//搜索分享用户回调
typedef void(^DeviceShareSearchUserCallBack)(int result,NSArray * _Nonnull users);

NS_ASSUME_NONNULL_BEGIN

@interface DeviceShareManager : NSObject

//搜索可以分享的用户回调
@property (nonatomic,copy) DeviceShareSearchUserCallBack deviceShareSearchUserCallBack;

//MARK: - 分享设备
- (void)shareDevice:(NSString *)devID toUser:(NSString *)userID permission:(NSString *)permissions comletion:(void(^)(int result))completion;

//MARK: - 搜索可以分享的用户
- (void)searchUser:(NSString *)userName completion:(DeviceShareSearchUserCallBack)callBack;

//MARK: - 修改分享权限
- (void)changeSharedPermission:(NSString *)permission sharedUserID:(NSString *)sharedID completion:(void(^)(int result))completion;


//MARK: - 取消分享
- (void)cancelShareDeviceID:(NSString *)shareDeviceID completion:(void(^)(int result))completion;

//MARK: - 请求我分享的设备 分享给了哪些账号 ID传空字符串 就是返回所有的分享的账号信息
- (void)requestSharedDevice:(NSString *)devID sharedInfo:(void(^)(int result,NSArray *sharedList))completion;

//MARK: - 请求分享给我的设备列表
- (void)requestDeviceSharedToMe:(void(^)(int result,NSArray *sharedToMeList))completion;

//MARK: - 接受分享
- (void)acceptShareDeviceID:(NSString *)devID completion:(void(^)(int result))completion;

//MARK: - 拒绝分享
- (void)denyShareDeviceID:(NSString *)devID completion:(void(^)(int result))completion;

//MARK: - 主动添加来自分享的设备 通过二维码扫描等方式
- (void)addSharedDevice:(NSString *)devID shareAccountID:(NSString *)shareAccountID permission:(NSString *)permissions completion:(void(^)(int result))completion;

@end

NS_ASSUME_NONNULL_END
