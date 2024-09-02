/*********************************************************************************
*Author:	Yongjun Zhao
*Description:  
*History:  
Date:	2017.11.03/Yongjun Zhao
Action:Create
**********************************************************************************/
#pragma once
#include "XTypes.h"
#define N_MAX_DOWNLOAD_QUEUE_SIZE 32

/**
 * @brief 日历功能(可同时查看视频节点 和 报警消息节点)
 * @param devId 设备序列号
 * @param nChannel 通道号
 * @param szStreamType 码流类型
 * @param nDate 日期
 * @return 异步回调消息：id:EMSG_MC_SearchMediaByMoth = 6202, ///< 按月查询录像
 *                    param1: >=0 成功，否则失败
 */
int MC_SearchMediaByMoth(UI_HANDLE hUser, const char *devId, int nChannel, const char *szStreamType, int nDate, int nSeq = 0);

/**
 * @brief 查询时间段内的报警视频片段
 * @param devId 设备序列号
 * @param nChannel 通道号
 * @param szStreamType 码流类型
 * @param nStartTime 开始时间
 * @param nEndTime 结束时间
 * @return 异步回调消息：id:EMSG_MC_SearchMediaByTime = 6203, ///< 按时间查询录像
 *                    param1: <0失败，详见错误码
 *                    Str:查询到的结果，json信息
 */
int MC_SearchMediaByTime(UI_HANDLE hUser, const char *devId, int nChannel, const char *szStreamType, int nStartTime, int nEndTime, int nSeq = 0);

/**
 * @brief 云存储视频查询
 * @details 短视频查询逻辑是: 如果你给的时间段和视频的实际时间段有交集就会返回
 *          普通视频查询逻辑是：你给的时间段必须包含视频实际的时间段
 * @param sDevId 设备序列号
 * @param nChannel 通道号
 * @param sStreamType 码流类型
 * @param nStartTime 开始时间 ///<短视频，某一时间点，开始时间往前推移5s，结束时间往后推移10s
 * @param nEndTime 结束时间
 * @param sMessageType 消息类型 ///<短视频：MSG_SHORT_VIDEO_QUERY_REQ，报警视频：MSG_ALARM_VIDEO_QUERY_REQ
 * @param bTimePoint 是否按时间点查询 ///<TRUE/FALSE
 * @return 异步回调消息：id:EMSG_MC_SearchMediaByTime = 6203, ///< 按时间查询录像
 *                    param1: <0失败，详见错误码
 *                    Str:查询到的结果，json信息
 */
int MC_SearchMediaByTimeV2(UI_HANDLE hUser, const char *sDevId, int nChannel, const char *sStreamType, int nStartTime, int nEndTime, const char* sMessageType, Bool bTimePoint = FALSE, int nSeq = 0);

/**
 * @brief 下载录像等媒体的缩略图
 * @details nWidth,nHeight可以指定宽和高，等于0时默认为原始大小
 * @param devId 设备序列号
 * @param szJson 报警云视频片段消息
 * @param szFileName 下载图片绝对路径
 * @param nWidth 图片宽度
 * @param nHeight 图片高度
 * @return 异步回调消息：id:EMSG_MC_DownloadMediaThumbnail = 6204, ///< 下载媒体缩略图
 *                    param1: <0失败，详见错误码
 */
int MC_DownloadThumbnail(UI_HANDLE hUser, const char *devId, const char *szJson, const char *szFileName, int nWidth = 0, int nHeight = 0, int nSeq = 0);

/**
 * @brief 云视频片段缩略图下载
 * @details 通过开始时间和结束时间SDK内部自己查询
 *          默认最大等待下载队列32个，超过会被清除，可通过MC_SetDownloadThumbnailMaxQueue进行最大任务下载数量的设置
 *          可通过MC_StopDownloadThumbnail清空下载队列
 *          nWidth,nHeight可以指定宽和高，等于0时默认为原始大小
 * @param sDevId 设备序列号
 * @param sFileName 下载图片绝对路径
 * @param sStreamType 主辅码流  ///<默认:"Main"
 * @param sMessageType 消息类型 ///<报警视频：MSG_ALARM_VIDEO_QUERY_REQ
 *                                短视频：MSG_SHORT_VIDEO_QUERY_REQ
 * @param nStartTime 开始时间
 * @param nEndTime 结束时间
 * @param nWidth 缩略图宽度
 * @param nHeight 缩略图高度
 * @param bTimePoint 是否按时间点查询  ///<TRUE/FALSE
 * @return 异步回调消息：id:EMSG_MC_DownloadMediaThumbnail = 6204, ///< 下载媒体缩略图
 *                    param1: <0失败，详见错误码
 */
int MC_DownloadThumbnailByTime(UI_HANDLE hUser, const char *sDevId, const char *sFileName, const char *sStreamType, const char *sMessageType, int nChannel, int nStartTime, int nEndTime, int nWidth = 0, int nHeight = 0, Bool bTimePoint = FALSE, int nSeq = 0);

/**
 * @brief 设置缩略图下载的最大任务数量
 * @details 默认任务数量为 N_MAX_DOWNLOAD_QUEUE_SIZE 32
 * @param nMaxQueueSize 设置最大任务数
 */
int MC_SetDownloadThumbnailMaxQueue(int nMaxQueueSize);

/**
 * @brief 取消全部缩略图下载任务
 */
void MC_StopDownloadThumbnail();

/**
 * @brief 云存储视频时间轴查询
 * @details 云存储视频时间轴查询（一天内）,最好查询一整天
 * @param sDevId 设备序列号
 * @param sStreamType 主辅码流  ///<默认:"Main"
 * @param nChannel 通道号
 * @param nStartTime 开始时间
 * @param nEndTime 结束时间
 * @return 异步回调消息：id:EMSG_MC_SearchMediaTimeAxis = 6205, // 查询云视频时间轴（一天内）
 *                    param1: <0失败，详见错误码
 *                    Str:查询到的结果，json信息
 */
int MC_SearchMediaTimeAxis(UI_HANDLE hUser, const char *sDevId, const char *sStreamType, int nChannel, int nStartTime, int nEndTime, int nSeq = 0);
