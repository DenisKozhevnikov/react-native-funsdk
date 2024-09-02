//
//  AudioInputConfig.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/5/16.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFunSDKObject.h"

@protocol AudioInputConfigDelegate <NSObject>

@optional
- (void)getAudioInputConfigResult:(int)result;
- (void)setAudioInputConfigResult:(int)result;

@end

NS_ASSUME_NONNULL_BEGIN

/*
 音量输入 即麦克风音量配置
 */

@interface AudioInputConfig : CYFunSDKObject

@property (nonatomic,weak) id<AudioInputConfigDelegate>delegate;

//MARK:获取保存配置
- (void)getConfig;
- (void)setConfig;

//MARK:获取和设置配置具体参数
//MARK:获取音量
- (int)getVolume;
//MARK:设置音量
- (void)setVolume:(int)volume;

//MARK:检查是否支持配置
- (BOOL)checkSupportConfig;

@end

NS_ASSUME_NONNULL_END
