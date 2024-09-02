//
//  AudioInputConfig.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/5/16.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "AudioInputConfig.h"
#import "AudioConfigInput.h"
#import "DeviceConfig.h"

@interface AudioInputConfig () <DeviceConfigDelegate>
{
    JObjArray<AudioConfigInput> jAudioConfigInput;
}

@property (nonatomic,assign) BOOL ifSupportConfig;   // 是否支持配置 需要解析具体获取参数判断

@end

@implementation AudioInputConfig

//MARK:获取保存配置
- (void)getConfig{
    jAudioConfigInput.SetName(JK_AudioConfigInput);
    
    DeviceConfig *cfg = [[DeviceConfig alloc] initWithJObject:&jAudioConfigInput];
    cfg.devId = self.devID;
    cfg.channel = -1;
    cfg.isSet = NO;
    cfg.delegate = self;
    
    [self requestGetConfig:cfg];
}

- (void)setConfig{
    jAudioConfigInput.SetName(JK_AudioConfigInput);
    
    DeviceConfig *cfg = [[DeviceConfig alloc] initWithJObject:&jAudioConfigInput];
    cfg.devId = self.devID;
    cfg.channel = -1;
    cfg.isGet = NO;
    cfg.delegate = self;
    
    [self requestSetConfig:cfg];
}

//MARK:获取和设置配置具体参数
//MARK:获取音量
- (int)getVolume{
    return jAudioConfigInput[0].LeftVolume.Value();
}

//MARK:设置音量
- (void)setVolume:(int)volume{
    jAudioConfigInput[0].LeftVolume = volume;
    jAudioConfigInput[0].RightVolume = volume;
}

//MARK:检查是否支持配置
- (BOOL)checkSupportConfig{
    return self.ifSupportConfig;
}

//MARK: 请求回调
- (void)getConfig:(DeviceConfig *)config result:(int)result{
    if (result >= 0) {
        if ([config.jLastStrCfg containsString:@"LeftVolume"]) {
            self.ifSupportConfig = YES;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(getAudioInputConfigResult:)]) {
        [self.delegate getAudioInputConfigResult:result];
    }
}

- (void)setConfig:(DeviceConfig *)config result:(int)result{
    if (self.delegate && [self.delegate respondsToSelector:@selector(setAudioInputConfigResult:)]) {
        [self.delegate setAudioInputConfigResult:result];
    }
}

@end
