/**
 * @brief 音频数据处理对外接口
 * @date 2022/05/24
 * @author baixu
 */
#ifndef _AUDIO_PROCESS_FUN_AP_H_
#define _AUDIO_PROCESS_FUN_AP_H_

/**
 * @brief PCM编码MP3
 * @param szPcmFilePath  PCM源文件路径
 * @param szMp3FilePath  MP3文件存储路径
 * @param nSampleRate 采样率
 * @param nChannels  通道数
 * @param nBitRate 比特率
 * @return == EE_OK(0)成功，否者失败
 */
int AP_PCMEncoder2MP3(const char* szPcmFilePath, const char* szMp3FilePath, int nSampleRate, int nChannels, int nBitRate);

/**
 * @brief soundtouch第三方库初始化
 * @param hUser 异步消息接收句柄 消息id：EMSG_AP_ON_RECEIVE_SAMPLES（8700）
 * @param nChannels 通道数
 * @param nSampleRate 采样率
 * @param nTempo 节拍速度控制值。正常速度=1.0，较小的值表示速度较慢，较大的速度较快
 * @param nPitch 在源pitch的基础上，使用半音(Semitones)设置新的pitch [-12.0,12.0]
 * @param nSpeed 速率控制值。正常速率 = 1.0，较小的值代表较慢的速率，较大的代表较快的速率
 * @return  EE_OK(0)
 */
int AP_STInit(int hUser, int nChannels, int nSampleRate, float nTempo, float nPitch, float nSpeed);

void AP_STUnInit();

/** 设置新的速度控制值。正常速度=1.0，较小的值表示速度较慢，较大的速度较快 */
void AP_STSetTempo(float nTempo);

/** 设置八度音阶的音高变化 */
void AP_STSetPitchSemiTones(float nPitch);

/** 设置新的速率控制值。正常速率 = 1.0，较小的值代表较慢的速率，较大的代表较快的速率 */
void AP_STSetSpeed(float nSpeed);

/** soundtouch第三方库版本信息 */
const char *AP_STGetVersionInfo();

/** 出错的时候，获取错误信息  @details 暂未实现 */
const char *AP_STGetErrorString();

/**
 * @brief 输入音频样本
 * @details 结合AP_STReceiveSamples和AP_STFlush使用
 * @param pSamples 输入音频样本数据
 * @param nSize  输入音频样本大小
 */
void AP_STPutSamples(char *pSamples, int nSize);

/** 同步返回 */
/**
 * @brief 输出音频样本
 * @param pOutpSamples 输出的音频样本数据
 * @param nSize 输出的音频样本数据数组大小
 * @return 返回实际的样本大小
 */
int AP_STReceiveSamples(char *pOutpSamples, int nSize);

/** 将最后一个样本从处理管道刷新到输出 ps:数据接收最后调用 */
void AP_STFlush();

/** 清除对象输出和内部处理缓冲区中的所有样本*/
void AP_STClear();

/** 如果没有任何可用于输出的样本，则返回非零。 */
int AP_STIsEmpty();

/**
 * @brief 处理文件
 * @details 只支持wav格式的音频文件
 * @param szInputFile 输入文件
 * @param szOutPutFile  输出经过处理的文件
 * @return == EE_OK(0)成功，其他失败
 */
int AP_STProcessWavFile(const char *szInputFile, const char *szOutPutFile);

/**
 * @brief 处理音频样本数据
 * @param pSamples 输入样本数据
 * @param nSize  输入样本文件大小
 * @return @async 消息ID：8700; param1: 样本数大小; pDdta:样本数据（char *）
 * @return != EE_OK(0)失败
 */
int AP_STChangeVoice(char *pSamples, int nSize);

/**
 * @brief 计算短时音频的评率
 * @param bufferin 输入样本数据
 * @param bufferin_len  输入样本文件大小
 */
double AP_GetPitch(char *bufferin, int bufferin_len);

#endif /** _AUDIO_PROCESS_FUN_AP_H_ */