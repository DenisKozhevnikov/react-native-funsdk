//
//  NetWorkCfgManager.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/20.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFunSDKObject.h"

typedef void(^GetNetWorkCfgSetEnableVideoCallBack)(int result);
typedef void(^SetNetWorkCfgSetEnableVideoCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
 录像本地存储开关配置
 */
@interface NetWorkCfgManager : CYFunSDKObject

@property (nonatomic,assign) BOOL requested;

@property (nonatomic,copy) GetNetWorkCfgSetEnableVideoCallBack getNetWorkCfgSetEnableVideoCallBack;
@property (nonatomic,copy) SetNetWorkCfgSetEnableVideoCallBack setNetWorkCfgSetEnableVideoCallBack;

//MARK:请求录像本地开关配置
- (void)requestNetWorkSetEnableVideoCfg:(NSString *)devID completion:(GetNetWorkCfgSetEnableVideoCallBack)callBack;
//MAKR:保存录像本地开关配置
- (void)saveNetWorkSetEnableVideoCfgCompletion:(SetNetWorkCfgSetEnableVideoCallBack)callBack;

//MARK:获取设置本地录像开关状态
- (BOOL)getNetWorkSetEnableVideoEnabled;
- (void)setNetWorkSetEnableVideoEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
