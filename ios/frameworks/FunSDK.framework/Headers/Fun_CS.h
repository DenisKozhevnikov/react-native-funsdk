/**
 * @brief 云存储相关服务V2版本(简化协议)
 * @see http://10.2.11.100/display/cloud/PMS_V2
 * @author baixu
 * @date 2023/03/08
 */

#ifndef __FUN_PMS_H_
#define __FUN_PMS_H_

#include "XTypes.h"

/**
 * @brief 按时间查询云存储视频片段
 * @details 异步回调消息：id:6300 param1: >=0 成功，否者失败 Str:消息列表信息
 * @details 短视频查询逻辑是: 如果你给的时间段和视频的实际时间段有交集就会返回, 普通视频查询逻辑是：你给的时间段必须包含视频实际的时间段
 * @param szReqJson 请求参数信息(JSON),格式如下：
 * @example
 * {
 *   "msg": "video_query",           ///< 接口标识1.短视频(short_video_query) 2.校验userid接口，必须携带userid(video_query_user、short_video_query_user)
 *   "sn": "14005d42a45417d7",
 *   "st": "2018-06-05 00:00:00",    ///< 注:如果st和et相同，表示要查询的视频包含了这个时间点
 *   "et": "2018-06-05 23:59:59",
 *   "ch": 0,                        ///<【可选】不填写此字段表示查询所有通道
 *   "label":["person","pet"] ///<【可选】标签数组，不传则不筛选，支持筛选多个（或）
 * }
 */
int CS_QueryVideoClipsByTime(UI_HANDLE hUser, const char *szReqJson, int nSeq);

/**
* @brief 云存储视频时间轴查询
* @details 云存储视频时间轴查询（一天内）,最好查询一整天
* @details 异步回调消息：id:6302 param1: >=0 成功，否者失败  Str:消息信息
* @param szReqJson 请求信息 参考如下：
* @example
* {
*    "msg": "video_axis_query",
*    "sn": "14005d42a45417d7",
*    "st": "2018-06-05 00:00:00",
*    "et": "2018-06-05 23:59:59",
*    "ch": 0    ///<【可选】不填写此字段表示查询所有通道
* }
*/
int CS_QueryVideoTimeAxis(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 下载云视频片段缩略图
 * @details 异步回调消息：id:6301 param1: >=0 成功，否者失败
 * @param szReqJson 请求信息 参考如下：
 * @example
 * {
 *   "msg": "video_thumbnail_download" ///<  短视频 ："short_video_thumbnail_download" 长视频支持userid校验："video_thumbnail_download_user" 短视频支持userid校验"short_video_thumbnail_download_user"
 *   "sn": "14005d42a45417d7",
 *   "timeout" : 8000, ///< 超时时间，默认8000
 *   "ch" : 0, ///< 通道号, 默认 -1
 *   "downfirst" : true, ///< 是否需要优先下载  默认true
 *   "filename" : "/sdcard/baiux/1.jpg", ///< 本地存储文件绝对路径
 *   "width" :  64, ///< 缩略图宽度
 *   "height" : 64, ///< 缩略图高度
 *   "st": "2018-06-05 00:00:00",   ///< 如果videoinfo存在，则使用videoinfo，否者使用此时间进行主动查询，如果需要支持userid校验，"msg"字段需要传对应的值
 *   "et": "2018-06-05 23:59:59",
 *   "label":["person","pet"], ///<【可选】标签数组，不传则不筛选，支持筛选多个
 *   "videoinfo" :
 *   {
 *      "st": "2018-06-05 10:22:32",
 *      "et": "2018-06-05 10:23:05",
 *      "indx": "c142dd39f8222e1d_180605102232_1528165354-0.m3u8",
 *      "picfg": 1,
 *      "bucket": "OBS_obs-cn-pic-01",
 *      "vidsz": 1191087
 *   }
 * }
 */
int CS_DownloadVideoClipThumbnail(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 设置下载列表中的任务数量
 * @details 默认为N_MAX_DOWNLOAD_QUEUE_SIZE(32)
 */
int CS_SetDownloadVideoClipThumbnailMaxQueue(int nMaxQueueSize);

/**
 * @brief 取消全部缩略图下载任务
 */
void CS_StopDownloadVideoClipThumbnail();

#endif //__FUN_PMS_H_
