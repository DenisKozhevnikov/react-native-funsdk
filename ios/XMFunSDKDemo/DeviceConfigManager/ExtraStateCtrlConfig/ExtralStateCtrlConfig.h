//
//  ExtralStateCtrlConfig.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/5/6.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ExtralStateCtrlConfigDelegate <NSObject>

@optional

- (void)getExtralStateCtrlConfigResult:(NSInteger)result;
- (void)setExtralStateCtrlConfigResult:(NSInteger)result;

@end

/*
 设备额外状态设置 （需要根据能力集判断是否支持）
 设备各种状态的提示音
 设备状态灯
 */

@interface ExtralStateCtrlConfig : ConfigControllerBase

@property (nonatomic,assign) id<ExtralStateCtrlConfigDelegate>delegate;

- (void)myGetConfig;
- (void)mySetConfig;

//MARK: 状态灯是否开启
- (int)getIsOn;
//MARK: 提示音是否开启
- (int)getVoiceTipEnable;

//MARK: 设置状态灯开关
- (void)setIsOn:(int)isOn;
//MARK: 设置提示音开关
- (void)setVoiceTipEnable:(int)enalbe;

@end

NS_ASSUME_NONNULL_END
