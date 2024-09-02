//
//  AudioOutput.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/5/16.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFunSDKObject.h"

@protocol AudioOutputConfigDelegate <NSObject>

@optional
- (void)getAudioOutputConfigResult:(int)result;
- (void)setAudioOutputConfigResult:(int)result;

@end

NS_ASSUME_NONNULL_BEGIN

/*
 音量输出 即喇叭音量配置
 */

@interface AudioOutputConfig : CYFunSDKObject

@property (nonatomic,weak) id<AudioOutputConfigDelegate>delegate;

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
