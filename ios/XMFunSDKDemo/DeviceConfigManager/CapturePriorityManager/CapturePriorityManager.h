//
//  CapturePriorityManager.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/20.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFunSDKObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GetCapturePriorityCallBack)(int result);
typedef void(^SetCapturePriorityCallBack)(int result);

/*
 拍照优先配置
 
 type 0 表示关 1表示自动
 */
@interface CapturePriorityManager : CYFunSDKObject

@property (nonatomic,copy) GetCapturePriorityCallBack getCapturePriorityCallBack;
@property (nonatomic,copy) SetCapturePriorityCallBack setCapturePriorityCallBack;

@property (nonatomic,assign) BOOL requested;

//MARK:请求拍照优先配置
- (void)requestCapturePriorityCfg:(NSString *)devID completion:(GetCapturePriorityCallBack)callBack;
//MAKR:保存拍照优先配置
- (void)saveCapturePriorityCfgCompletion:(SetCapturePriorityCallBack)callBack;

//MARK:获取设置拍照优先配置状态
- (int)getCapturePriorityType;
- (void)setCapturePriorityType:(int)type;

@end

NS_ASSUME_NONNULL_END
