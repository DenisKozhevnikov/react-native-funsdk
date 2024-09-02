/**
 * @brief 报警服务相关接口
 * @details 新的简化协议
 * @author baixu
 * @date 2023/03/09
 */

#ifndef __FUN_AS_H_
#define __FUN_AS_H_

#include "XTypes.h"

/**
 * @brief 报警服务初始化
 * @details 只需初始化一次，多次初始化会相互覆盖
 * @param szInitInfo 参数信息(JSON格式) 参考如下：
 * {
 *    "user" : "",  ///< 云账户用户名 Android内部推送使用
 *    "pwd" : "",   ///< 云账户密码 Android内部推送使用
 *    "language" : "", ///< 报警语言类型  *传空字符串的话SDK内部自动获取
 *    "tk" : "", ///< 报警推送服务使用的TOKEN  *只有Android客户端需要传此字段，用于XM内部报警推送服务
 *    "userid" :"" ///< 【可选】云账户UserID *如果需要通过UserId进行报警订阅，必须包含此字段，字段内容可以为空(SDK读取内部缓存)
 * }
 * @return 异步回调消息：id:EMSG_AS_INIT_INFO = 6400 ///<报警服务初始化
 *                    param1: >=0 成功，否则失败
 */
int AS_Init(UI_HANDLE hUser, const char *szInitInfo, int nSeq);

/**
 * @brief 报警订阅
 * @details 支持批量设备&&批量Token订阅
 * @param szReqJson 参数信息(JSON格式) 参考如下：
 * @example
 * {
 *    "msg" : "alarm_subscribe",
 *    "snlist" :
 *    [
 *      {
 *          "sn" : "",  ///< 设备序列号
 *          "dev" : "", ///< 【可选】 设备别名
 *          rules": { ///< 推送规则
 *                      "level": "Full", ///< 当前推送的消息等级，等级分为：Full, Important, No
 *                      "events": ["xxx", "xxx", "xxx", "xxx", "xxx", "xxx"] ///< 重要事件类型定义
 *                  }
 *      }
 *    ]
 *    "voclist" : "", ///< 【可选】ios新增声音标识
 *    "tklist" :
 *    [
 *      {
 *          "tk" : "",  ///< 报警订阅TOKEN
 *          "ty" : ""  ///< 报警订阅类型，可传第三方报警服务地址
 *      }
 *    ]
 * }
 * @return 异步回调消息：id:EMSG_AS_DEVS_ALARM_SUBSCRIBE = 6401 ///<报警订阅(支持批量)
 *                    param1: >=0 成功，否则失败
 *                    Str():订阅成功序列号集合
 */
int AS_DevsAlarmSubscribe(UI_HANDLE hUser, const char *szReqJson, int nSeq);

/**
 * @brief 取消报警订阅
 * @details 支持批量设备&&批量Token取消订阅
 * @param szReqJson 参数信息(JSON格式) 参考如下：
 * @example
 * {
 *    "msg" : "alarm_unsubscribe",
 *    "all": "0",                  ///<【可选】 0或者无该字段表示:只删除指定Token的订阅关系 1表示:删除该设备的所有订阅关系（此时不需要AppToken字段）,
 *                                              2表示: 只保留UserId对应的订阅关系  3表示: 只清除UserId对应的订阅关系
*     "ut": 123456,     ///<【可选】 utc时间，如果晚于这个时间订阅的才会删除，用于删除指定时间前的订阅（仅用于根据userid删除订阅情况）
 *    "snlist" :
 *    [
 *      {
 *          "sn" : "",  ///< 设备序列号
 *      }
 *    ]
 *    "tklist" :
 *    [
 *      {
 *          "tk" : "",  ///< 报警订阅TOKEN
 *      }
 *    ]
 * }
 * @return 异步回调消息：id:EMSG_AS_DEVS_ALARM_UNSUBSCRIBE = 6402, ///< 取消报警订阅(支持批量)
 *                    param1: >=0 成功，否则失败
 *                    Str():取消订阅成功序列号集合
 */
int AS_DevsAlarmUnSubscribe(UI_HANDLE hUser, const char *szReqJson, int nSeq);

/**
 * @brief 报警订阅(UserID)
 * @details 通过UserID进行订阅，UserID && 批量Token订阅
 * @param szReqJson 参数信息(JSON格式) 参考如下：
 * @example
 * {
 *    "msg" : "userid_subscribe"(客服系统),  ///< userid_adv_subscribe（广告推送）
 *    "uslist" :  ///< 暂不支持多个。。userid数组只能传一个
 *    [
 *      {
 *          "userid" : "",
 *      }
 *    ]
 *    "tklist" :
 *    [
 *      {
 *          "tk" : "",  ///< 报警订阅TOKEN
 *          "ty" : ""  ///< 报警订阅类型
 *      }
 *    ]
 * }
 * @return 异步回调消息：id:EMSG_AS_USERID_ALARM_SUBSCRIBE = 6412, ///< 报警订阅(UserID)
 *                    param1: >=0 成功，否则失败
 *                    Str():订阅成功序列号集合
 */
int AS_UserIDAlarmSubscribe(UI_HANDLE hUser, const char *szReqJson, int nSeq);

/**
 * @brief 取消报警订阅(UserID)
 * @details 通过UserID取消订阅，UserID && 批量Token订阅
 * @param szReqJson 参数信息(JSON格式) 参考如下：
 * @example
 * {
 *    "msg" : "userid_unsubscribe"(客服系统),  ///< userid_adv_unsubscribe（广告推送）
 *    "all": "1",                  //【可选】 //1表示:删除该userid的所有订阅关系（此时不需要tklist）
 *    "uslist" :
 *    [
 *      {
 *          "userid" : "",  ///< 设备序列号
 *      }
 *    ]
 *    "tklist" :
 *    [
 *      {
 *          "tk" : "",  ///< 报警订阅TOKEN
 *      }
 *    ]
 * }
 * @return 异步回调消息：id:EMSG_AS_USERID_ALARM_UNSUBSCRIBE = 6413, ///< 取消报警订阅(UserID)
 *                    param1: >=0 成功，否则失败
 *                    Str():取消订阅成功序列号集合
 */
int AS_UserIDAlarmUnSubscribe(UI_HANDLE hUser, const char *szReqJson, int nSeq);

/**
 * @brief 查询报警消息列表
 * @details 最多查询200条，要查询全部请使用AS_QueryAlarmMsgListByTime接口
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *   "msg": "alarm_query",
 *   "sn": "c142dd39f8222e1d",
 *   "am": "1",    ///<【可选】未携带此字段则不下发图片url，协议标识（用于标识客户端是否支持https，1 表示支持https下发的下载地址为https，0 表示不支持http下发的下载地址为http，其他将返回错误）
 *   "wd": "80",   ///<【可选】缩略图宽 整数字符串 未携带下发原图url
 *   "hg": "123",  ///<【可选】缩略图高 整数字符串 未携带下发原图url
 *   "ch": 0      ///<【可选】不填写此字段表示查询所有通道
 *   "pgsize":20, ///<【可选】单次分页查询个数，不传按原方案走，默认为20，可设置在1~20区间
 *   "pgnum":1,   ///<【可选】查询页数，从1开始，传1将重新刷新数据库，否者不会更新 默认1
 *   "event":"",  ///<【可选】查询报警类型
 *   "fttp": "and",  ///<【可选】仅当event与label过滤方式同时使用时起作用，不传则默认为and方式（即与判断），传则只允许值为and和or（即或判断），此字段针对于event与label的过滤规则
 *   "label" : ["",""],  ///<【可选】报警标签，即ai检测类型
 *   "labelfttp":"or",   ///<【可选】针对报警标签的过滤方式，and为与判断，or为或判断，不传则默认为and，传则只允许值为and和or
 *   "labeldet":true,    ///<【可选】用于表示是否需要详细标签信息，需要标签详细信息则传值且值为true
 *   "usercheck" : 1  ///<【可选】为1表示要进行userid校验，其余情况则按原有逻辑走
 *  }
 * @return 异步回调消息：id:EMSG_AS_QUERY_ALARM_MSG_LIST = 6403, ///< 查询报警消息列表
 *                    param1: >=0 成功，否则失败
 *                    Str:设备序列号
 *                    pData：消息列表信息
 */
int AS_QueryAlarmMsgList(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 按时间查询报警消息列表
 * @details 接口内部自动循环查询，直到传递的时间范围内查不到结果
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *   "msg": "alarm_query",
 *   "sn": "4ad15e3168fb9061",
 *   "am": "1",    ///<【可选】未携带此字段则不下发图片url，协议标识（用于标识客户端是否支持https，1 表示支持https下发的下载地址为https，0 表示不支持http下发的下载地址为http，其他将返回错误）
 *   "wd": "80",   ///<【可选】缩略图宽 整数字符串 未携带下发原图url
 *   "hg": "123",  ///<【可选】缩略图高 整数字符串 未携带下发原图url
 *   "ch": 0,      ///<【可选】不填写此字段表示查询所有通道
 *   "st" : "2017-11-29 07:03:58",
 *   "et" : "2017-11-29 07:04:58"
 *   "pgsize":20, ///<【可选】单次分页查询个数，不传按原方案走，默认为20，可设置在1~20区间
 *   "pgnum":1,   ///<【可选】查询页数，从1开始，传1将重新刷新数据库，否者不会更新 默认1
 *   "event":"",  ///<【可选】查询报警类型
 *   "fttp": "and",  ///<【可选】仅当event与label过滤方式同时使用时起作用，不传则默认为and方式（即与判断），传则只允许值为and和or（即或判断），此字段针对于event与label的过滤规则
 *   "label" : ["",""],  ///<【可选】报警标签，即ai检测类型
 *   "labelfttp":"or",   ///<【可选】针对报警标签的过滤方式，and为与判断，or为或判断，不传则默认为and，传则只允许值为and和or
 *   "labeldet":true,    ///<【可选】用于表示是否需要详细标签信息，需要标签详细信息则传值且值为true
 *   "usercheck" : 1  ///<【可选】为1表示要进行userid校验，其余情况则按原有逻辑走
 *  }
 * @return 异步回调消息：id:EMSG_AS_QUERY_ALARM_MSG_LIST_BY_TIME = 6404, ///< 按时间查询报警消息列表
 *                    param1: >=0 成功，否则失败
 *                    Str:设备序列号
 *                    pData：消息列表信息
 */
int AS_QueryAlarmMsgListByTime(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
* @brief 报警消息图片下载
* @details 支持云端和普通报警消息图片下载，只支持单个报警消息图片下载
* @param szReqJson 请求信息(JSON格式)，参考如下：
* @example
* {
*   "msg": "download_alarm_image",
*   "sn": "4ad15e3168fb9061",
*   "filename": "", ///< 文件存储绝对路径
*  "downloadbyurl" : "0", ///< 是否通过url下载图片，"1"：通过url直接下载图片，alarmmsg需要包含picinfo/url字段 "0":通过其他信息下载图片
*   "wd": "80",   ///<【可选】缩略图宽 整数字符串 未携带下载原图
*   "hg": "80",  ///<【可选】缩略图高 整数字符串 未携带下载原图
*   "alarminfo": ///< 报警信息，查询返回的数据，只支持单个报警消息图片下载
*   {
*       ...
*   },
*  }
* @return 异步回调消息：id:EMSG_AS_DOWNLOAD_ALARM_MSG_IMAGE = 6414, ///< 报警消息图片下载
 *                   param1: >=0 成功，否则失败
 *                   Str:图片存储地址
*/
int AS_DownloadAlarmMsgImage(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 取消等待队列中所有未下载的图片
 * @details 正在下载中的无法取消
 * @return 异步回调消息：id:EMSG_AS_STOP_DOWNLOAD_ALARM_MSG_IMAGE = 6415, ///< 取消等待队列中所有未下载的图片
 *                    param1: >=0 成功，否则失败
 */
int AS_StopDownloadAlarmMsgImage(UI_HANDLE hUser, int nSeq = 0);

/**
 * @brief 是否有报警消息产生
 * @details 获取某个指定时间之后的报警个数，用于APP显示未读或者新增消息的个数
 * @example
 * {
 *   "msg": "nmq", ///< new message query
 *   "time": "2022-07-12 20:03:06", ///< 【可选】从当前time开始是否有新的报警消息（当多个设备查一个时间点时使用该字段）,此字段存在优先使用此字段
 *   "snlist":
 *   [
 *     {
 *        "sn": "xxx",
 *        "time": "2022-07-12 20:03:06", ///< 【可选】从当前time开始是否有新的报警消息（当多个设备查不同时间点时使用该字段）
 *     }
 *   ]
 * }
 * @return 异步回调消息：id:EMSG_AS_WHETHER_AN_ALARM_MSG_IS_GENERATED = 6405, ///< 是否有报警消息产生
 *                    param1: >=0 成功，否则失败
 *                    Str:结果信息
 *                    pData:查询成功的序列号集合
 */
int AS_WhetherAnAlarmMsgIsGenerated(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 根据时间点查询云视频片段信息
 * @details 批量根据时间点查询视频片段信息，单次最多查询50个，超过50个取前50个，少于50按实际的查找，仅返回查找到的信息
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *  "msg": "video_clip", 或者 "msg": "short_video_clip"  ///< 查看短视频的请求
 *  "sn": "xx", ///< 设备序列号
 * 	"ch": 0, ///< 【可选】不填写此字段表示查询所有通道
 * 	"time":[ "2023-02-28 17:00:00","2023-02-28 18:00:00","2023-02-28 19:00:00"....], ///< 报警时间点
 * 	"label":["person","pet"] ///<【可选】标签数组，不传则不筛选，支持筛选多个
 * }
 * @return 异步回调消息：id:EMSG_AS_QUERY_CLOUD_VIDEO_CLIP_INFO_BY_POINT = 6406, ///< 查询视频片段信息
 *                    param1: >=0 成功，否则失败
 *                    Str:结果信息
 */
int AS_QueryCloudVideoClipInfoByPoint(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 日历功能
 * @details 按时间查询日历，可查看视频节点和报警消息节点
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *  "msg": "calendar",
 *  "sn": "c142dd39f8222e1d", ///< 设备序列号
 *  "dt": "2017-11",  ///< 按月查询，如果按天查询则Data对应的value为json数组，例："dt": [{"tm": "2017-11-01"},{"tm": "2017-11-02"}]  如果支持最新一条消息 Date：Last
 *  "ty": "VIDEO",  ///< VIDEO：查询视频日历节点 MSG：查询报警消息日历节点
 * 	"ch": 0 ///< 【可选】不填写此字段表示查询所有通道
 * }
 * @return 异步回调消息：id:EMSG_AS_QUERY_CALENDAR_BY_TIME = 6407, ///< 日历功能
 *                    param1: >=0 成功，否则失败
 *                    Str:结果信息
 */
int AS_QueryCalendarByTime(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 删除报警信息
 * @details 删除报警信息
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *	"msg": "alarm_delete",
 *	"sn": "14005d42a45417d7",
 *	"delty": "MSG",          ///< 删除消息和图片为:MSG  删除视频:VIDEO
 *	"ids": [ --【可选】 如果没有ids会全部清空
 *	         {
 *				"id":"180905114640"
 *			 }
 *		   ]
 * }
 * @return 异步回调消息：id:EMSG_AS_DELETE_ALARM = 6408, ///< 删除报警消息
 *                    param1: >=0 成功，否则失败
 *                    Str:结果信息
 */
int AS_DeleteAlarm(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 查询订阅状态
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *	 "msg": "query_subscribe",
 *	 "tks": ["token1", "token2"], ///< 根据token查询   *subty和tks同时存在，优先使用subty
 *	 "subty": "Android"       ///< 根据设备类型查询，subty目前包括: Android Hook IOS Google XG HuaWei Third  ALL(表示查询所有订阅类型)
 *	 "snlist": [{
 *		 "sn": "c142dd39f8222e1a"
 *	 }]
 * }
 * @return 异步回调消息：id:EMSG_AS_QUERY_SUBSCRIBE_STATUS = 6409, ///< 查询订阅状态
 *                    param1: >=0 成功，否则失败
 *                    Str:结果信息
 */
int AS_QuerySubscribeStatus(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 查询状态历史记录
 * @details 访问的服务器并不是pms服务，暂时放在一块。。
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *   "msg": "status_history",
 *	 "sort": "asc", ///< 升序排列  降序使用"desc"
 *	 "count" : 200, ///< 查询条数，默认500，最多500（因为设备可能分配在不同的服务器，实际客户端收到的的最大条数是500的成倍增加）
 *	 "startTm": 1664001721, ///< utc时间，默认0   *批量设备只能查询同一个时间范围
 *	 "endTm": 1664001721, ///< utc时间，默认当前时间
 *	 "snlist": [{
 *		 "sn": "027995bbc8d649901b"
 *	 }]
 * }
 * @return 异步回调消息：id：EMSG_AS_QUERY_STATUS_HISTORY_RECORD = 6410, ///< 查询状态历史记录
 *                    param1: >=0 成功，否则失败
 *                    Str()：结果信息(Json格式，数据内容APP需重新按时间排序)
 *                    pData:查询成功的设备序列号集合
 */
int AS_QueryStatusHistoryRecord(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 查询云视频播放地址
 * @details 访问的服务器并不是pms服务，暂时放在一块。。返回的内容组成：http://host:6614/css_hls/VideoName
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *   "msg": "query_hls_url",
 *	 "sn": "xxxx",
 *	 "ch": 0,      ///<【可选】不填写此字段表示查询所有通道
 *	 "last" : "1",   ///< 【可选】如果有此字段，则表示更新最新的m3u8文件
 *   "st" : "2017-11-29 07:03:58",
 *   "et" : "2017-11-29 07:04:58",
 * }
 * @return 异步回调消息：id：EMSG_AS_QUERY_CLOUD_VIDEO_HLS_URL = 6411, ///< 查询云存储视频播放地址
 *                    param1: >=0 成功，否则失败
 *                    Str()：结果信息(Json格式)
 */
int AS_QueryCloudVideoHlsUrl(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 设置报警消息已读标志
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *  "msg": "msgstatus_record", ///< 接口标识
 *  "sn": "xxxxxxxxx",         ///< 设备序列号
 *  "ids": ["","",""]          ///< alarmid列表
 * }
 * @return 异步回调消息：id:EMSG_AS_SET_ALARM_MSG_READ_FLAG = 6416, ///< 设置报警消息已读标志
 *                    param1: >=0 成功，否则失败
 */
int AS_SetAlarmMsgReadFlag(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 根据时间段获取存储信息条数（可选择消息条数还是视频条数）
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *  "msg": "get_storage_count", ///< 接口标识
 *  "st" : "2023-11-29 00:00:00", ///< 开始时间 格式必须为年-月-日 时:分:秒
 *  "et" : "2023-11-29 23:59:59", ///< 结束时间 格式必须为年-月-日 时:分:秒
 *  "type" : "MSG", ///< 查询消息类型 消息为MSG，视频为VIDEO
 *	"snlist": [{
 *		 "sn": "027995bbc8d6491b",
 *		 "events":["appEventHumanDetectAlarm"],   ///< 查询报警类型【可选】
         "ch": 0                                  ///< 通道号【可选】
 *	 }]
 * }
 * @return 异步回调消息：id:EMSG_AS_GET_STORAGE_INFO_COUNT = 6417, ///< 根据时间段获取存储信息条数
 *                    param1: >=0 成功，否则失败
 *                    Str()：结果信息(Json格式)
 *                    pData:查询成功的序列号集合
 */
int AS_GetStorageInfoCount(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 按文件名称查询对应的云存储视频片段信息
 * @param szReqJson 请求参数信息(JSON),格式如下：
 * @example
 * {
 *   "msg": "gvi",           ///< 此接口固定为gvi
 *   "sn": "a6a2a89ab9ec7f0d",
 *   "vids":["003_a6a2a89ab9ec7f0d_240511153516_1715422917-1.m3u8","003_a6a2a89ab9ec7f0d_240511153516_1715422917-1.m3u8"],  ///< 云视频文件名称
 * }
 * @return 异步回调消息：ID: EMSG_AS_QUERY_VIDEO_CLIP_BY_NAME  = 6418； param1: >=0 成功，否则失败；Str()：结果信息(Json格式)
 */
int AS_QueryVideoClipsByFileName(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

#endif //__FUN_AS_H_
