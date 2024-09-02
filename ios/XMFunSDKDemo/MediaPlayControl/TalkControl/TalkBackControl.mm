//
//  TalkBackControl.m
//  XMEye
//
//  Created by XM on 2017/6/6.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "TalkBackControl.h"
#import <FunSDK/Fun_WebRtcAudio.h>
#import <FunSDK/Fun_AP.h>

@interface TalkBackControl ()
{
    int talkType;
    NSMutableData *sendData;
}
@end

@implementation TalkBackControl

#pragma mark - 单向对讲
- (void)startTalk{
    talkType = 0;
    if (_audioRecode == nil) {
        sendData = [[NSMutableData alloc] init];
        _audioRecode = [[Recode alloc] init];
        _audioRecode.delegate = self;
    }
    [_audioRecode startRecode:self.deviceMac];
    //先停止音频
    FUN_MediaSetSound(_handle, 0, 0);
    if (_hTalk == 0) {
        //开始对讲,单向对讲首次启动时，回调成功之后暂停设备上传音频数据
       _hTalk = FUN_DevStarTalk(self.msgHandle, [self.deviceMac UTF8String], FALSE, 0, 0);
    }else{
        //单向对讲后续APP讲话时，暂停设备端上传音频数据
        const char *str = "{\"Name\":\"OPTalk\",\"OPTalk\":{\"Action\":\"PauseUpload\"},\"SessionID\":\"0x00000002\"}";
        FUN_DevCmdGeneral(self.msgHandle, [self.deviceMac UTF8String], 1430, "PauseUpload", 0, 0, (char*)str, 0, -1, 0);
    }
    //APP停止播放设备音频
    FUN_MediaSetSound(_hTalk, 0, 0);
}
- (void)pauseTalk{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_audioRecode != nil) {
            [_audioRecode stopRecode];
            _audioRecode = nil;
        }
        //恢复设备端上传音频数据
        const char *str = "{\"Name\":\"OPTalk\",\"OPTalk\":{\"Action\":\"ResumeUpload\"},\"SessionID\":\"0x00000002\"}";
        FUN_DevCmdGeneral(self.msgHandle, [self.deviceMac UTF8String], 1430, "ResumeUpload", 0, 0, (char*)str, 0, -1, 0);
        //app播放设备端音频
        FUN_MediaSetSound(_hTalk, 100, 0);
    });
}
//停止预览->停止对讲，停止音频
-(void)closeTalk{
    if (_hTalk != 0) {
        if (_audioRecode != nil) {
            [_audioRecode stopRecode];
            _audioRecode = nil;
        }
        if (_hTalk != 0) {
            FUN_DevStopTalk(_hTalk);
            FUN_MediaSetSound(_hTalk, 0, 0);
            _hTalk = 0;
        }else{
            FUN_MediaSetSound(_handle, 0, 0);
        }
    }
}

/*
 WebRTC音频增益接口说明
 注意:
 1.
 - 开启对讲接口一定要先调用 : SAudioProcessParams info； Fun_WebRtcAudioInit(&info)

 - 发送对讲数据

 (接口调用先后顺序):
  WebRtcAudio_Process(audiodata, audiodata.length)
  Fun_DevSendTalkData(mDevId, audiodata, audiodata.length);
  
 - 关闭对讲一定要调用 WebRtcAudio_UnInit

 2. 双向对讲音频/实时预览的音频不允许同时打开！！！！！！！！

 3. 双向对讲的时候，开启回声消除，噪声抑制，音频增益，即AudioProcessParams.nFuncBit 设置为 1 << E_WEBRTC_AUDIO_FUNC_AEC | 1 << E_WEBRTC_AUDIO_FUNC_NS | 1 << E_WEBRTC_AUDIO_FUNC_AGC 默认就是开启回声消除

 4. 单向对讲的时候，不需要开启AEC回声消除功能 即AudioProcessParams.nFuncBit 设置为 1 << E_WEBRTC_AUDIO_FUNC_NS | 1 << E_WEBRTC_AUDIO_FUNC_AGC
 */

#pragma mark - 双向对讲
- (void)startDouTalk:(BOOL)needEchoCancellation {
    
    //双向对讲的回声消除功能
    SAudioProcessParams info = SAudioProcessParams();
    if (!needEchoCancellation) {//不需要回声消除时不开启
        info.nFuncBit = 1 << E_WEBRTC_AUDIO_FUNC_NS | 1 << E_WEBRTC_AUDIO_FUNC_AGC;
    }
    WebRtcAudio_Init(&info);//音频增益开启
    
    talkType = 1;
    //先停止音频
    FUN_MediaSetSound(_handle, 0, 0);
    
    if (_audioRecode == nil) {
        sendData = [[NSMutableData alloc] init];
        _audioRecode = [[Recode alloc] init];
        _audioRecode.delegate = self;
    }
    //APP手机音频上传
    [_audioRecode startRecode:self.deviceMac];
    
    if (_hTalk == 0) {
        //开始对讲
        _hTalk = FUN_DevStarTalk(self.msgHandle, [self.deviceMac UTF8String], FALSE, 0, 0);
    }
    //app播放设备端音频
    FUN_MediaSetSound(_hTalk, 100, 0);
}
- (void)stopDouTalk {
    [self closeTalk];
}

//设置对讲声音 （男声/女声）
-(void)setPitchSemiTonesType:(PitchSemiTonesType)pitchSemiTonesType{
    _pitchSemiTonesType = pitchSemiTonesType;
    
    if (pitchSemiTonesType == 0) {
        AP_STSetPitchSemiTones(1.f);
        AP_STUnInit();
    }
    else if (self.pitchSemiTonesType == PitchSemiTonesMan) {
        AP_STInit(self.msgHandle, 1, 8000, 1, 1, 1);
        AP_STSetPitchSemiTones(-4.f);
    }
    else if (self.pitchSemiTonesType == PitchSemiTonesWoman) {
        AP_STInit(self.msgHandle, 1, 8000, 1, 1, 1);
        AP_STSetPitchSemiTones(4.f);
    }
}


#pragma mark - 发送采集到的音频数据
- (void)audioRecordData:(char*) data size:(int)size;
{
    
    if (self.pitchSemiTonesType == PitchSemiTonesMan || self.pitchSemiTonesType == PitchSemiTonesWoman) {
        //声音转变 男声/女声，回调为 EMSG_AP_ON_RECEIVE_SAMPLES
        AP_STChangeVoice(data,size);
    }
    else{
        //音质优化
        WebRtcAudio_Process(data, size);
        FUN_DevSendTalkData(CSTR(self.deviceMac), data, size);
    }
}

#pragma mark - 对讲开始结果回调
-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_START_TALK: {//对讲失败
            if(_hTalk != 0 && msg->param1 != EE_OK){
                [MessageUI ShowErrorInt:msg->param1];
                _hTalk = 0;
            }else{
                if (talkType == 1) {
                    //双向对讲
                    
                }else{
                    //单向对讲
                    //设备端暂停采集音频
                    const char *str = "{\"Name\":\"OPTalk\",\"OPTalk\":{\"Action\":\"PauseUpload\"},\"SessionID\":\"0x00000002\"}";
                    FUN_DevCmdGeneral(self.msgHandle, [self.deviceMac UTF8String], 1430, "PauseUpload", 0, 0, (char*)str, 0, -1, 0);
                }
            }
        }
            break;
        case EMSG_DEV_STOP_TALK: {
            
        }
            break;
            
        case EMSG_DEV_CMD_EN: {
            NSLog(@"EMSG_DEV_CMD_EN = %d",msg->param1);
        }
            break;
        case EMSG_AP_ON_RECEIVE_SAMPLES:
        {
            NSLog(@"AP_STChangeVoice complete %i",msg->param1);
            if (msg->param1 > 0 && msg->pObject != NULL) {
                //对讲变声之后，SDK可能会把数据分割回调，因此APP需要把被分割的数据重新拼接为640长度
                [self parsingData:msg->pObject dataSize:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

- (void)parsingData:(char*)charData dataSize:(int)size {
    
    //音频数据需要拼接为 kFrameSize 的长度发送给设备，才能最好的恢复音频质量
    if (size == kFrameSize && sendData.length == 0) {
        WebRtcAudio_Process( charData, kFrameSize);
        FUN_DevSendTalkData(CSTR(self.deviceMac), charData,  kFrameSize);
        return;
    }
    [sendData appendBytes:charData length:size];
    if (sendData.length >= kFrameSize) {
        NSData *tempData = [sendData subdataWithRange:NSMakeRange(0, kFrameSize)];
        WebRtcAudio_Process( (char*)[tempData bytes], kFrameSize);
        FUN_DevSendTalkData(CSTR(self.deviceMac), (char*)[tempData bytes],  kFrameSize);
        NSData *tempData2 = [sendData subdataWithRange:NSMakeRange(kFrameSize, sendData.length-kFrameSize)];
        sendData = [NSMutableData dataWithData:tempData2];
    }
}


- (BOOL)isSupportTalk{
    //鱼眼灯泡不支持对讲 其他都支持 所以先直接返回ture 后期修改语言灯泡对讲
    return YES;
}
@end
