#ifndef __FUNSDK_WEBRTCAUDIO_AP_DEFINES_H_
#define __FUNSDK_WEBRTCAUDIO_AP_DEFINES_H_

#include "XTypes.h"


/** WebRtc音频处理功能枚举 */
using EWebRtcAudioFunc = enum EWebRtcAudioFunc
{
     E_WEBRTC_AUDIO_FUNC_AEC = 0,
    E_WEBRTC_AUDIO_FUNC_NS = 1,
    E_WEBRTC_AUDIO_FUNC_AGC = 2,
};

using EWebRtcAECRemoteType = enum EWebRtcAECRemoteType
{
    E_WEBRTC_AEC_REMOTE_TYPE_TALK = 0, ///< 对讲音频数据
    E_WEBRTC_AEC_REMOTE_TYPE_REAL = 1, ///< 实时预览的音频数据
};

/**WebRtc回声消除参数 */
using SWebRtcAecParams = struct SWebRtcAecParams
{
    int nDelayTime; ///< 声卡延迟：范围[0,500]，单位 ms，默认是 160ms
    int nEchoMode; ///<  回声残留模式： 0：mild 1：medium 2：aggressive (默认)
    int nCngMode; ///< 双方都静音的情况下，是否会填充舒适噪声 1:填充(默认) 0:不填充
    EWebRtcAECRemoteType nRemoteType; ///< 远端音频类型  0:对讲音频数据 1:实时预览的音频数据 @enum EWebRtcAECRemoteType
    SWebRtcAecParams()
    {
        nDelayTime = 160;
        nEchoMode = 2;
        nCngMode = 1;
        nRemoteType = E_WEBRTC_AEC_REMOTE_TYPE_TALK;
    }
};

/** WebRtc降噪强度等级枚举 */
using ENsMode = enum ENsMode
{
    E_NS_MODE_MILD = 0,
    E_NS_MODE_MEDIUM = 1,
    E_NS_MODE_AGGRESSIVE = 2,
};

/** WebRtc噪声抑制参数 */
using SWebRtcNsParams = struct SWebRtcNsParams
{
    ENsMode nNsMode; ///< 降噪强度等级，@enum ENsMode，默认：E_NS_MODE_AGGRESSIVE
    SWebRtcNsParams()
    {
        nNsMode = E_NS_MODE_AGGRESSIVE;
    }
};

/** 音频增益模式 */
using EAgcMode = enum EAgcMode
{
    E_AGC_MODE_UNCHANGED = 0,
    E_AGC_MODE_ADAPTIVE_ANALOG = 1, /// < 自适应模拟
    E_AGC_MODE_ADAPTIVE_DIGITAL = 2, ///< 自适应数字
    E_AGC_MODE_FIXED_DIGITAL = 3, ///< 固定数字
};

/** WebRtc音频增益参数 */
using SWebRtcAgcParams = struct SWebRtcAgcParams
{
    int nMinLevel; ///<  音量最小值，默认0
    int nMaxLevel; ///< 音量最大值，默认255
    EAgcMode nAgcMode; ///< 增益模式，@enum EAgcMode，默认 E_AGC_MODE_FIXED_DIGITAL
    int nCompressionGaindB; ///< 增益能力，表示音频最大的增益能力，如设置为12dB，最大可以被提升 12dB，默认6dB
    int nTargetLevelDbfs;  ///< 目标音量，表示音量均衡结果的目标值，如设置为 1表示输出音量的目标值为1dB，默认3
    int nLimiterEnable; ///< 压限器开关，一般与targetLevelDbfs配合使用，compressionGaindB是调节小音量的增益范围，limiter则是对超过targetLevelDbfs的部分进行限制，避免数据爆音，默认true
    SWebRtcAgcParams()
    {
        nMinLevel = 0;
        nMaxLevel = 255;
        nAgcMode = E_AGC_MODE_FIXED_DIGITAL;
        nCompressionGaindB = 10;
        nTargetLevelDbfs = 3;
        nLimiterEnable = 1;
    }
};

/** WebRtc音频处理参数 */
using SAudioProcessParams = struct SAudioProcessParams
{
    int nFuncBit; ///< 开启的功能，二进制按位标识，@enum EWebRtcAudioFunc，例如：111 代表开启AEC、NS、AGC，默认7，全部开启
    int nSampleRate; ///< 采样频率，默认8000（目前只支持8000hz）
    int nSampleBits; ///< 采样位数，默认16bit（目前只支持16bit）
    int nChannels; ///< 通道数，默认单通道
    SWebRtcAecParams webRtcAecParams;
    SWebRtcNsParams webRtcNsParams;
    SWebRtcAgcParams webRtcAgcParams;
    SAudioProcessParams()
    {
        nFuncBit = 7;
        nSampleRate = 8000;
        nSampleBits = 16;
        nChannels = 1;
    }
};

#endif // __FUNSDK_WEBRTCAUDIO_AP_DEFINES_H_