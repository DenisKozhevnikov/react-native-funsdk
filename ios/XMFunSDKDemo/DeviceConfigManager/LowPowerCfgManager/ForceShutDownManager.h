//
//  ForceShutDownManager.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/21.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 强制关机置管理者(有能力集)
 
 “ShutDownMode “: 0 即不强制关机, 10即十分钟强制关机
 */
@interface ForceShutDownManager : NSObject

typedef void(^GetForceShutDownCallBack)(int result);
typedef void(^SetForceShutDownCallBack)(int result);

@property (nonatomic,copy) NSString *devID;

@property (nonatomic,copy) GetForceShutDownCallBack getForceShutDownCallBack;
@property (nonatomic,copy) SetForceShutDownCallBack setForceShutDownCallBack;

//MARK:获取强制关机配置
- (void)requestForceShutDownCfg:(NSString *)devID completion:(GetForceShutDownCallBack)callBack;
//MAKR:保存强制关机配置
- (void)saveForceShutDownCfg:(SetForceShutDownCallBack)callBack;
//MARK:获取设置强制关机
- (int)getForceShutDownMode;
- (void)setForceShutDownMode:(int)mode;

@end

NS_ASSUME_NONNULL_END
