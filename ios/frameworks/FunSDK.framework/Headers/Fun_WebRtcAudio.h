/**
 * @brief WebRtc音频处理对外接口头文件
 */

#ifndef __FUNSDK_WEBRTC_AUDIO_H_
#define __FUNSDK_WEBRTC_AUDIO_H_

#include "APDefines.h"

/** WebRtc音频数据处理参数初始化 */
int WebRtcAudio_Init(SAudioProcessParams *pAudioProcessParams);

/** 反初始化 */
void WebRtcAudio_UnInit();

/**
 * @brief WebRtc音频数据处理
 * @details 参数通过初始化接口WebRtcAudio_Init设置，使用完后调用WebRtcAudio_UnInit进行释放
 * @param pPCMData PCM音频数据
 * @param nDataSize 数据大小
 * @return >=0 成功，否者失败
 */
int WebRtcAudio_Process(char *pPCMData, int nDataSize);

/**
 * @brief WebRtc音频数据回声消除
 * @details 参数通过初始化接口WebRtcAudio_Init设置，使用完后调用WebRtcAudio_UnInit进行释放
 * @param pPCMData 原始PCM音频数据
 * @param nDataSize  原始数据代销
 * @param pFarData  参考音频数据(回声)
 * @param nFarDataSize 参考音频数据大小
 * @return >=0 成功，否者失败
 */
int WebRtcAudio_AecProcess(char *pPCMData, int nDataSize, char *pFarData, int nFarDataSize);

/** WebRtc音频数据噪声抑制 */
int WebRtcAudio_NsProcess(char* pPCMData, int nDataSize);

/** WebRtc音频数据增益 */
int WebRtcAudio_AgcProcess(char* pPCMData, int nDataSize);

#endif // __FUNSDK_WEBRTC_AUDIO_H_