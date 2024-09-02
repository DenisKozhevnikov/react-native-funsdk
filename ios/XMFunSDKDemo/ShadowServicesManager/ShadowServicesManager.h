//
//  ShadowServicesManager.h
//  FunSDKDemo
//
//  Created by plf on 2023/4/25.
//  Copyright © 2023 plf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunMsgListener.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^GetDevCfgsFromShadowServiceCallBack)(NSDictionary *dic);
typedef void (^SetDevOffLineCfgsToShadowServiceCallBack)(BOOL result);
typedef void (^AddShadowServiceListenerCallBack)(NSDictionary *dic);

@interface ShadowServicesManager : FunMsgListener
+ (instancetype)getInstance;

@property(nonatomic,copy)NSString *devID;

@property (nonatomic,copy) GetDevCfgsFromShadowServiceCallBack getDevCfgsFromShadowServiceCallBack;
@property (nonatomic,copy) SetDevOffLineCfgsToShadowServiceCallBack setDevOffLineCfgsToShadowServiceCallBack;
@property (nonatomic,copy) AddShadowServiceListenerCallBack addShadowServiceListenerCallBack;

//影子服务器获取设备配置
- (void)getDevCfgsFromShadowService:(NSString *)cfglist callBack:(GetDevCfgsFromShadowServiceCallBack)result;

//设置设备离线配置到影子服务
- (void)setDevOffLineCfgsToShadowService:(NSString *)cfglist callBack:(SetDevOffLineCfgsToShadowServiceCallBack)result;

//影子服务设备配置状态监听
- (void)addShadowServiceListener:(NSString *)cfglist callBack:(AddShadowServiceListenerCallBack)result;

//移除影子服务设备配置监听
- (void)removeShadowServiceListener;
@end

NS_ASSUME_NONNULL_END
