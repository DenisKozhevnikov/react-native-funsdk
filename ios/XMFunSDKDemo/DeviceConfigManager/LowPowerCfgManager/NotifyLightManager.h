//
//  NotifyLightManager.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/21.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotifyLightManager : NSObject

typedef void(^GetNotifyLightCallBack)(int result);
typedef void(^SetNotifyLightCallBack)(int result);

@property (nonatomic,copy) NSString *devID;

@property (nonatomic,copy) GetNotifyLightCallBack getNotifyLightCallBack;
@property (nonatomic,copy) SetNotifyLightCallBack setNotifyLightCallBack;

//MARK:获取设备呼吸灯配置
- (void)requestNotifyLightCfg:(NSString *)devID completion:(GetNotifyLightCallBack)callBack;
//MAKR:保存设备呼吸灯配置
- (void)saveNotifyLightCfg:(SetNotifyLightCallBack)callBack;
//MARK:获取设置设备呼吸灯
- (BOOL)getNotifyLightEnabled;
- (void)setNotifyLightEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
