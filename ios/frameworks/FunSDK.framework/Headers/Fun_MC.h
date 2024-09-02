/*********************************************************************************
*Author:	Yongjun Zhao(赵永军)
*Description:  
*History:  
Date:	2014.01.01/Yongjun Zhao
Action：Create
**********************************************************************************/
#pragma once
#include "XTypes.h"

#ifndef SystemTime
/// 系统时间结构,需要和SYSTEM_TIME保持一致
struct SystemTime
{
    int  year;		///< 年。
    int  month;		///< 月，January = 1, February = 2, and so on.
    int  day;		///< 日。
    int  wday;		///< 星期，Sunday = 0, Monday = 1, and so on
    int  hour;		///< 时。
    int  minute;	///< 分。
    int  second;	///< 秒。
    int  isdst;		///< 夏令时标识。
};
#endif

typedef struct Xpms_Search_AlarmInfo_Req
{
    char Uuid[100];
    SystemTime StarTime;	//报警信息查询起始时间(MC_SearchAlarmInfoByTime接口使用)
    SystemTime EndTime;     //报警信息查询结束时间(MC_SearchAlarmInfoByTime接口使用)
    int Channel;			//Channel < 0 表示全部查询，通道号是从0开始的
    int AlarmType;          //报警类型(暂时无用)
    int Number;             //请求要查的报警条数 ，Number <= 0 表示查全部
    int Index;				//需要从查询的结果中哪一条开始取
    char Res[32];
}XPMS_SEARCH_ALARMINFO_REQ;

typedef struct Xpms_Search_AlarmPic_Req
{
    char Uuid[64];
    uint64 ID;		//报警信息ID号
    char Res[32];	//缩略图格式如下："_wxh.jpeg"  如："_176x144.jpeg" [0]==1时默认为_176x144.jpeg
                    //空时为报警原图
}XPMS_SEARCH_ALARMPIC_REQ;

typedef struct XCloud_Search_Css_Hls_Req
{
	char szDevId[64];
	SystemTime StarTime;
	SystemTime EndTime;
	int Channel;			//Channel < 0 表示全部查询，通道号是从0开始的
	int nForceRefresh;  //0 1  如果有ForceRefresh字段，则表示更新最新的m3u8文件
}XCLOUD_SEARCH_CSS_HLS_REQ;

typedef enum EMSGLANGUAGE
{
	ELG_AUTO = 0,
    ELG_ENGLISH = 1,
    ELG_CHINESE = 2,
    ELG_JAPANESE = 3,
}EMSGLANGUAGE;

typedef enum EAPPTYPE
{
    EXMFamily = 1,
    EFamilyCenter = 2,
    EXMEye = 3,
    EFamily_BaiAn = 4,
}EAPPTYPE;

typedef struct SMCInitInfo
{
    char user[2048];
    char password[512];
    char token[256];	// Google报警需要256， 多个报警订阅用&&连接
    int language;       // EMSGLANGUAGE
    int appType;        // EAPPTYPE
    char szAppType[256];	// XXXXXX 第三方订阅报警URL
}SMCInitInfo;

typedef struct SMCInitInfoV2
{
	char user[2048]; // 用户名，不传SDK内部会默认使用当前账户(IOS不需要传)
	char password[512]; // 密码，不传SDK内部会默认使用当前账户(IOS不需要传)
	char userID[64];    // 账户ID，不传SDK内部会通过本地缓存获取(必须要账户登录之后才能拿到)
	char token[256];	// 多个报警订阅用&&连接
	int language;       // 语言类型 默认0SDK内部自动获取
	int appType;        // EAPPTYPE
	char szAppType[256];	// 与参数token对应；格式： xxxx&&xxxx(Android&&信鸽)  >>>另外可以传第三方订阅报警URL
}SMCInitInfoV2;

/**@enum ESortType
 * @brief 排序类型
 */
using ESortType = enum ESortType
{
	E_SORT_TYPE_ORDER = 0, /** 顺序，从开始时间向后查询 */
	E_SORT_TYPE_REVERSE_ORDER = 1, /** 倒序(默认)，当前时间向前查询 */
};

/**@struct SQueryDevHistoryParams
 * @brief 查询设备状态历史记录
 */
using SQueryDevHistoryParams = struct SQueryDevHistoryParams
{
	int nStartTime; /** utc秒，默认当前时间，向前查询（批量设备只能查询同一个时间范围） */
	int nEndTime; /** utc秒，默认当前时间，向前查询 */
	int nQueryCount; /** 查询条数，默认500，最多500（因为设备可能分配在不同的服务器，实际查询返回的最大条数是500的成倍增加）  */
	ESortType nSortType; /** 查询类型 @enum ESortType */
	SQueryDevHistoryParams()
	{
		nStartTime = 0;
		nEndTime = 0;
		nQueryCount = 500;
		nSortType = E_SORT_TYPE_REVERSE_ORDER;
	}
};

/**
 * @brief 批量设备报警消息查询请求参数
 */
using SBatchDevAlarmMsgQueryReqParams = struct SBatchDevAlarmMsgQueryReqParams
{
	int nStartTime;			///< 报警信息查询开始时间
	int nEndTime;    		///< 报警信息查询结束时间
	int nChannel;			///< Channel < 0 表示全部查询，通道号是从0开始的
	int nMaxNumber;         ///< 最大返回条数，最大不超过500 ，传0默认300条
	int nPageIndex;			///< 查询页数，从1开始，传1将重新刷新数据库，否者不会更新 ps:<=0会报错
	char szAlarmType[64]; 	///< 报警消息类型，保留字段，暂时未使用
	char Res[128];			///< 保留字段
};

/**
 * @brief 设备(单个)报警消息查询请求参数
 */
using SDevAlarmMsgQueryReqParams = struct SDevAlarmMsgQueryReqParams
{
	char szDevID[64];		///< 设备序列号
	char szAlarmType[128]; 	///< 查询报警消息类型
	int nStartTime;			///< 报警信息查询开始时间
	int nEndTime;    		///< 报警信息查询结束时间
	int nChannel;			///< Channel < 0 表示全部查询，通道号是从0开始的
	int nPageNum;			///< 查询页数，从1开始，传1将重新刷新数据库，否者不会更新 默认1
	int nPageSize;          ///< 单次分页查询个数，不传按原方案走，默认为20，可设置在1~20区间
	char Res[128];			///< 保留字段
};

/**
 * @brief 报警服务初始化接口
 * @param pInfo 报警初始化信息，详见@enum SMCInitInfoV2
 * @return 异步回调消息 ID：EMSG_MC_INIT_INFO = 6011 ///< 报警服务初始化
 *                    param1: >=0 成功，否则失败
 */
int MC_Init(UI_HANDLE hUser, SMCInitInfo *pInfo, int nSeq);

/**
 * @brief 报警初始化V2
 * @details 支持UserID报警服务初始化接口(同时兼容MC_Init)
 * @param pInfo 报警初始化信息，详见@enum SMCInitInfoV2
 * @return 异步回调消息 ID：EMSG_MC_INIT_INFO = 6011 ///< 报警服务初始化
 *                    param1: >=0 成功，否则失败
 */
int MC_InitV2(UI_HANDLE hUser, SMCInitInfoV2 *pInfo, int nSeq);

/**
 * @brief 定阅报警
 * @param uuid 客户唯一标识
 * @param devUsername 设备登录用户名
 * @param devPwd 设备密码
 * @param strDevName 设备名称
 * @param strVoice 报警产生设备播放的声音文件名
 * @return 异步回调消息 ID：EMSG_MC_LinkDev = 6000 ///< 报警订阅
 *                    param1: >=0 成功，否则失败
 */
int MC_LinkDev(UI_HANDLE hUser, const char *uuid, const char *devUsername, const char *devPwd, int nSeq = 0, const char *strDevName = NULL, const char *strVoice = NULL);

/**
 * @brief 通用报警接口，可以替换其他的报警订阅接口
 * @details 单个设备订阅，sAppToken必须和sAppType对应
 * @param sDevName 设备名称
 * @param sVoice 报警声音文件名称（IOS）
 * @param sDevUserName 设备登陆用户名，参数未使用
 * @param sDevUserPwd 设备登陆密码，参数未使用
 * @param sAppToken token，支持上层自定义传，如果此参数为NULL，默认使用报警初始化传的token  格式： xxxx&&xxxx(Android&&信鸽)
 * @param sAppType 报警类型，必须对应token，支持上层自定义传，如果此参数为NULL，默认使用报警初始化传的apptype 格式： xxxx&&xxxx(Android&&信鸽)
 * @return 异步回调消息 ID：EMSG_MC_ON_AlarmCb = 6007, ///< 报警订阅结果返回
 * 		              param1: pData字节流长度
 * 		              pData: 实时报警信息(JSON)
 * 		              str: 设备序列号
 */
int MC_LinkDevGeneral(UI_HANDLE hUser, const char *sDevId, const char *sDevName = "", const char *sVoice = "", const char *sDevUserName = "", const char *sDevUserPwd = "", const char *sAppToken = "", const char *sAppType = "", int nSeq = 0);

/**
 * @brief 批量报警订阅
 * @details app在登陆/退出的时候，如果账户下有很多设备，订阅/取消订阅会比较漫长，导致未能成功订阅/取消订阅
 * @param sDevIDs 设备序列号，不支持ip+port方式，格式：sn1;sn2;sn3;
 * @param sVoice 报警声音文件名称
 * @param sDevUserName 设备登陆用户名，参数未使用
 * @param sDevUserPwd 设备登陆密码，参数未使用
 * @param sAppToken token，支持上层自定义传，如果此参数为NULL，默认使用报警初始化传的token  格式： xxxx&&xxxx(Android&&信鸽)
 * @param sAppType 报警类型，必须对应token，支持上层自定义传，如果此参数为NULL，默认使用报警初始化传的apptype 格式： xxxx&&xxxx(Android&&信鸽)
 * @return 异步回调消息 ID：EMSG_MC_LinkDevs_Batch = 6019  ///< 批量报警订阅
 * 		              arg1: >=0 成功，< 0错误值，详见错误码
 * 		              Str: 返回订阅成功的设备序列号集合 以";"分割
 */
int MC_LinkDevsBatch(UI_HANDLE hUser, const char *sDevIDs, const char *sDevName = "", const char *sVoice = "", const char *sDevUserName = "", const char *sDevUserPwd = "", const char *sAppToken = "", const char *sAppType = "", int nSeq = 0);

/**
 * @brief 设备报警订阅
 * @param szDevId 设备序列号/IP（IP会导致SDK自动登录设备，获取序列号）
 * @param szDevName 设备名称
 * @param szRules 推送规则(Json格式) 示例：{"Rules":{"Level"（当前推送的消息等级）:"Full","ImpEvents"（消息类型数组）:["xxx","xxx","xxx","xxx","xxx","xxx"]}}
 * @param szVoice 报警声音文件名称（IOS）
 * @param szAppToken token  *支持上层自定义传，如果此参数为NULL，默认使用报警初始化传的token  格式： xxxx&&xxxx(Android&&信鸽)
 * @param szAppType 报警类型，必须对应token  *支持上层自定义传，如果此参数为NULL，默认使用报警初始化传的apptype 格式： xxxx&&xxxx(Android&&信鸽)
 * @return 异步回调消息 id:EMSG_MC_LinkDev = 6000 ///< 报警订阅
 *                    param1: >=0 成功，否则失败
 *                    Str:设备序列号
 */
int MC_DevAlarmSubscribe(UI_HANDLE hUser, const char *szDevId, const char *szDevName = "", const char *szRules = "", const char *szVoice = "", const char *szAppToken = "", const char *szAppType = "", int nSeq = 0);

/**
 * @brief 批量设备报警订阅
 * @param szDevSNs 设备序列号，不支持ip+port方式  *格式：sn1;sn2;sn3;
 * @param szDevName 设备名称，如果传，必须和sDevIDs一一对应， *格式：dev1;dev2;dev3; （dev1;;dev3;）
 * @param szRules 推送规则，必须和sDevIDs一一对应 *格式：szRules1;szRules2;szRules3;（szRules1;;szRules3;） 示例 {"Rules":{"Level":"Full","ImpEvents":["xxx","xxx","xxx","xxx","xxx","xxx"]}};{"Rules":{"Level":"Full","ImpEvents":["xxx","xxx","xxx","xxx","xxx","xxx"]}}
 * @param szVoice 报警声音文件名称
 * @param szAppToken token  *支持上层自定义传，如果此参数为NULL，默认使用报警初始化传的token  格式： xxxx&&xxxx(Android&&信鸽)
 * @param szAppType 报警类型，必须对应token  *支持上层自定义传，如果此参数为NULL，默认使用报警初始化传的apptype 格式： xxxx&&xxxx(Android&&信鸽)
 * @return 异步回调消息 id:EMSG_MC_LinkDevs_Batch = 6019 ///< 批量报警订阅
 *                    param1: >=0 成功，否则失败
 *                    Str:返回订阅成功的设备序列号集合， 以";"分割
 */
int MC_BatchDevAlarmSubscribe(UI_HANDLE hUser, const char *szDevSNs, const char *szDevName = "", const char *szRules = "", const char *szVoice = "", const char *szAppToken = "", const char *szAppType = "", int nSeq = 0);

/**
 * @brief 取消订阅报警
 * @param uuid 用户唯一标识
 * @return 异步回调消息 id:EMSG_MC_UnlinkDev = 6001  ///< 取消报警订阅
 *                    param1: >=0 成功，否则失败
 */
int MC_UnlinkDev(UI_HANDLE hUser, const char *uuid, int nSeq = 0);

/**
 * @brief 通用取消报警订阅接口,可以替换其他所有的报警订阅接口
 * @details 单个设备订阅
 * @param sDevId 设备序列号/IP（IP会导致SDK自动登录设备，获取序列号）
 * @param sAppToken token,支持上层自定义传，如果此参数为NULL，默认使用报警初始化传的token  格式： xxxx&&xxxx(Android&&信鸽)
 * @param nFlag 是否清除设备所有订阅关系 ,1表示:删除该设备的所有订阅关系（此时不需要AppToken字段）, 0或者无该字段表示:只删除指定Token的订阅关系
 * @return 异步回调消息 id:EMSG_MC_UnlinkDev = 6001 ///< 取消报警订阅
 *                    param1: >=0 成功，否则失败
 */
int MC_UnlinkDevGeneral(UI_HANDLE hUser, const char *sDevId, const char *sAppToken = "", int nFlag = 0, int nSeq = 0);

/**
 * @brief 取消设备下所有账号报警订阅
 * @param uuid 用户唯一标识
 * @return 异步回调消息 id:EMSG_MC_UnlinkDev = 6001  ///< 取消报警订阅
 *                    param1: >=0 成功，否则失败
 */
int MC_UnlinkAllAccountsOfDev(UI_HANDLE hUser, const char *uuid, int nSeq = 0);

/**
 * @brief 批量取消报警订阅
 * @details app在登陆/退出的时候，如果账户下有很多设备，订阅/取消订阅会比较漫长，导致未能成功订阅/取消订阅
 * @param sDevIDs 设备序列号，不支持ip+port方式,格式：sn1;sn2;sn3;
 * @param sAppToken token,支持上层自定义传，如果此参数为NULL，默认使用报警初始化传的token  格式： xxxx&&xxxx(Android&&信鸽)
 * @param nFlag 是否清除设备所有订阅关系 ,1表示:删除该设备的所有订阅关系（此时不需要AppToken字段）, 0或者无该字段表示:只删除指定Token的订阅关系
 * @return 异步回调消息 id:EMSG_MC_UnLinkDevs_Batch = 6020,  ///< 批量取消报警订阅
 * 		              arg1: >=0 成功，< 0错误值，详见错误码
 * 		              Str: 返回取消成功的设备序列号集合 以";"分割
 */
int MC_UnLinkDevsBatch(UI_HANDLE hUser, const char *sDevIDs, const char *sAppToken = "", int nFlag = 0, int nSeq = 0);

/**
 * @brief 取消异常报警订阅
 * @details 上层收到异常的报警订阅消息，比如不在设备列表中的设备报警，进行取消订阅
 * @param uuid 设备id，可以ip+port
 * @param apptoken APP的标识号
 * @return 异步回调消息 id:EMSG_MC_UnlinkDev = 6001  ///< 取消报警订阅
 * 		              arg1: >=0 成功，< 0错误值，详见错误码
 */
int MC_UnlinkDevAbnormal(UI_HANDLE hUser, const char *uuid, const char *apptoken, int nSeq = 0);

/**
 * @brief 删除报警信息
 * @details 此接口使用需谨慎
 * @param uuid 设备id，可以ip+port
 * @param deleteType 删除消息和图片为:MSG  删除视频:VIDEO,不传此字段  默认删除的是MSG
 * @param alarmID 报警id, 为NULL或空字符串，表示清空;若有多个,以；分割
 * @return 异步回调消息 id:EMSG_MC_UnlinkDev = 6001  ///< 取消报警订阅
 * 		              arg1: >=0 成功，< 0错误值，详见错误码
 */
int MC_Delete(UI_HANDLE hUser, const char *uuid, const char *deleteType, const char *alarmID, int nSeq = 0);

//接口废弃-zyj-161029
//int MC_DevConnect(UI_HANDLE hUser, const char *uuid, int nSeq = 0);
//int MC_DevDisConnect(UI_HANDLE hUser, const char *uuid, int nSeq = 0);

//接口废弃-zyj-161029
//int MC_SendControlData(UI_HANDLE hUser, const char *uuid, const char *buf, int nSeq = 0);

// 返回0:Unlinked  1:Linked(会很快返回,存在本地了)
/** @deprecated 接口废弃，不再以本地缓存的订阅状态为准，使用MC_GetDevAlarmSubStatusByServer接口代替 */
int MC_GetLinkState(const char *uuid);

 /**
  * @brief 通过订阅类型从服务器端获取设备报警订阅状态
  * @param szDevIds 设备序列号, ip+port
  * @param szAppType 目前包括: Android Hook IOS Google XG HuaWei Third  ALL(表示查询所有订阅类型)
  * @return 异步返回消息 ID：EMSG_MC_GET_DEV_ALARM_SUB_STATUS_BY_TYPE = 6021, ///< 从服务器端获取设备报警订阅状态
  *                    param1:结果，>=0成功; <0 失败，详见错误码
  *                    msg->Str() 设备序列号
  *                    pData:成功返回结果信息(JSON,需要app自己解析)，失败返回错误信息
  */
int MC_GetDevAlarmSubStatusByType(UI_HANDLE hUser, const char *szDevId, const char *szAppType, int nSeq);

/**
 * @brief 通过TKOEN从服务器端获取设备报警订阅状态
 * @param szDevIds 设备序列号, ip+port
 * @param szAppTokens 多个以&&分隔
 * @return 异步返回消息 ID：EMSG_MC_GET_DEV_ALARM_SUB_STATUS_BY_TOKEN = 6022, ///< 从服务器端获取设备报警订阅状态
 *                    param1:结果，>=0成功; <0 失败，详见错误码
 *                    msg->Str() 设备序列号
 *                    pData:成功返回结果信息(JSON,需要app自己解析)，失败返回错误信息
 */
int MC_GetDevAlarmSubStatusByToken(UI_HANDLE hUser, const char *szDevId, const char *szAppTokens, int nSeq);

/**
 * @brief 查询报警信息
 * @details 短连接，查询完了就关闭TCP连接，视频最多返回500条，报警消息最多返回200条，需要客户端重复查询
 * @param pXPMS_SEARCH_ALARMINFO_REQ 报警信息查询结构，详见 XPMS_SEARCH_ALARMINFO_REQ
 * @return 异步返回消息 ID：EMSG_MC_SearchAlarmInfo = 6003, ///< 按条件搜索报警消息
 *                    param1:>=0符合搜索条件的报警消息条数; <0 失败，详见错误码
 */
int MC_SearchAlarmInfo(UI_HANDLE hUser, XPMS_SEARCH_ALARMINFO_REQ *pXPMS_SEARCH_ALARMINFO_REQ, int nSeq = 0);

/**
 * @brief 以开始，结束时间为条件查询报警信息
 * @details 短连接，查询完了就关闭TCP连接，视频最多返回500条，报警消息最多返回200条，需要客户端重复查询
 * @param pXPMS_SEARCH_ALARMINFO_REQ 报警信息查询结构，详见 XPMS_SEARCH_ALARMINFO_REQ
 * @return 异步返回消息 ID：EMSG_MC_SearchAlarmInfo = 6003, ///< 按条件搜索报警消息
 *                    param1:>=0符合搜索条件的报警消息条数; <0 失败，详见错误码
 */
int MC_SearchAlarmInfoByTime(UI_HANDLE hUser, XPMS_SEARCH_ALARMINFO_REQ *pXPMS_SEARCH_ALARMINFO_REQ, int nSeq = 0);

/**
 * @brief 查询报警图片
 * @details 短pXPMS_SEARCH_ALARMPIC_REQ==NULL时,只是查询缓存数据有没有,不从服务器获取
 * @param fileName 报警图片文件路径
 * @param pXPMS_SEARCH_ALARMINFO_REQ 报警图片查询结构，详见 XPMS_SEARCH_ALARMPIC_REQ
 * @return 异步返回消息 ID：EMSG_MC_SearchAlarmPic = 6004, ///< 按条件搜索报警图片
 *                    param1:=0搜索成功;>0图片已有搜索记录，返回文件长度; <0 失败，详见错误码
 *                    msg->Str()  param1:>=0时返回图片文件路径，否则返回具体错误消息
 */
int MC_SearchAlarmPic(UI_HANDLE hUser, const char *fileName, XPMS_SEARCH_ALARMPIC_REQ *pXPMS_SEARCH_ALARMPIC_REQ, int nSeq = 0);

/**
 * @brief 下载报警图片
 * @details nWidth = 0 && nHeight == 0 表示原始图片，否则表示缩略图的宽和高
 * @param szDevSN 报警图片文件路径
 * @param szSaveFileName 报警图片文件路径
 * @param szAlaramJson 报警消息信息
 * @param nWidth 缩略图宽度
 * @param nHeight 缩略图高度
 * @return 异步返回消息 ID：EMSG_MC_SearchAlarmPicV2=4116  ///< 下载报警图片
 *                    param1:=0搜索成功;>0图片已有搜索记录，返回文件长度; <0 失败，详见错误码
 *                    msg->Str()  param1:>=0时返回图片文件路径，否则返回具体错误消息
 */
int MC_DownloadAlarmImage(UI_HANDLE hUser, const char *szDevSN, const char *szSaveFileName, const char *szAlaramJson, int nWidth = 0, int nHeight = 0, int nSeq = 0);

// szSaveFileNames多个
// 接口已废弃
int MC_DownloadAlarmImages(UI_HANDLE hUser, const char *szDevSN, const char *szSaveFileNames, const char *szAlaramJsons, int nWidth = 0, int nHeight = 0, int nSeq = 0);

/**
 * @brief 取消队列中所有未下载的图片下载
 * @details MC_SearchAlarmPic和MC_DownloadAlarmImage都可以取消
 */
int MC_StopDownloadAlarmImages(UI_HANDLE hUser, int nSeq);

// 获取域名转IP后的报警图片URL 接口废弃-zyj-161029
// char *MC_GetAlarmPicURL(char *strDNSPicURL, char strPicURL[512]);

// Get alarm record url
// szAlarmTime:formate 2017-10-19 15:07:44
// msgId:EMSG_MC_GetAlarmRecordUrl
// 废弃此接口
int MC_GetAlarmRecordUrl(UI_HANDLE hUser, const char *szDevSN, const char *szAlarmTime, int nSeq = 0);

////日历功能(可同时查看视频节点 和 报警消息节点)
//int MC_SearchDataByMothEx(UI_HANDLE hUser, int nMsgId, const char *devId, int nChannel, const char *szStreamType, int nDate, const char *szType, int nSeq);

/**
 * @brief 按月查询报警消息
 * @details 如果按天查询(暂时未支持)则Data对应的value为json数组，例："Date": [{"Time": "2017-11-01"},{"Time": "2017-11-02"}]
 * @param devId 设备序列号
 * @param nChannel 通道号
 * @param szStreamType 码流类型
 * @param nDate 日期
 * @return 异步返回消息 ID：EMSG_MC_SearchAlarmByMoth = 6014  ///< 按月查询报警消息
 *                    param1:>=0，成功; <0 失败，详见错误码
 *                    msg->Str()  服务器返回消息
 */
int MC_SearchAlarmByMoth(UI_HANDLE hUser, const char *devId, int nChannel, const char *szStreamType, int nDate, int nSeq = 0);

/**
 * @brief 按类型查询最后一条消息的时间
 * @details Date：Last
 * @param devId 设备序列号
 * @param szStreamType 码流类型
 * @param szAlramType 查询报警类型
 * @param nChannel 通道号
 * @return 异步返回消息 ID：EMSG_MC_SearchAlarmLastTimeByType = 6017, ///< 按类型查询最后一条报警时间
 *                    param1:>=0，成功; <0 失败，详见错误码
 *                    msg->Str()  服务器返回消息
 */
int MC_SearchAlarmLastTimeByType(UI_HANDLE hUser, const char *devId, const char *szStreamType, const char *szAlramType, int nChannel, int nSeq = 0);

/**
 * @brief 第三方报警服务器报警数据入口
 * @param szJson 报警数据
 * @return 异步返回消息 ID：EMSG_MC_ON_AlarmCb = 6015   ///<第三方报警服务器收到报警数据处理回调
 *                    param1:>=0，成功; <0 失败，详见错误码
 */
int MC_OnRecvAlarmJsonData(UI_HANDLE hUser, const char *szJson, int nSeq = 0);

/**
 * @brief 通用报警相关配置操作
 * @param sDevID 设备id，可以序列号/iP（ip的话，库里面会转成序列号）
 * @param sTypeName 报警消息类型，也是整个json的name， 例如："AlarmCenter"：报警订阅/消息查询等功能 ；"CssCenter"：云存储签名专用
 * @param sJson 消息json,必须以sAlarmType参数为name，格式必须保持和服务器一致
 * @return 异步返回消息 ID：EMSG_MC_AlarmJsonCfgOperation = 6018 ///<通用报警相关配置操作
 * 		             arg1: >=0 成功，< 0错误值，详见错误码
 * 		             Str: 传的参数sDevID（ip/序列号）
 * 		             pData:返回的整个json信息，失败也是
 */
int MC_AlarmJsonCfgOperation(UI_HANDLE hUser, const char *sDevID, const char *sTypeName, const char *sJson, int nSeq);

//http://host:6614/css_hls/VideoName
// HLS播放地址信息获取
int MC_CloudMediaSearchCssHls(UI_HANDLE hUser, XCLOUD_SEARCH_CSS_HLS_REQ *pInfo, int nSeq = 0);

/**
 * @brief 批量查询是否产生报警
 * @details 查询是否有新消息产生，支持不同设备不同时间的批量查询
 * @see http://10.2.11.100/pages/viewpage.action?pageId=25903371
 * @param hUser 客户端消息接收句柄
 * @param szDevIDs 设备序列号，批量以";"分隔
 * @param szSpecifiedTimes 指定时间点(此时间点后，不包含此时间点) *格式:%04d-%02d-%02d %02d:%02d:%02d  举例：2022-07-14 10:00:00\n
 * 						与szDevIDs必须一一对应，以";"分隔，否者返回EE_PARAM_ERROR
 * @return 异步返回消息 ID：EMSG_MC_WhetherTheBatchQueryGeneratesAnAlarm = 6023, ///<批量查询是否产生报警
 *                       param1: >=0 成功，否者失败
 *                       Str()：查询过的设备序列号列表
 *                       pDdta:结果信息(Json格式)
 */
int MC_WhetherTheBatchQueryGeneratesAnAlarm(UI_HANDLE hUser, const char *szDevIDs, const char *szSpecifiedTimes, int nSeq);

/**
 * @brief 查询设备状态历史记录
 * @param pParams 查询设备状态历史记录结构，详见 SQueryDevHistoryParams
 * @return 异步返回消息 ID：EMSG_MC_QUERY_DEVS_STATUS_HISTORY_RECORD = 6024 ///<查询设备(批量)状态历史记录
 *                       param1: >=0 成功，否则失败
 *                       Str()：查询成功的设备序列号列表
 *                       pDdta:结果信息(Json格式，数据内容APP需重新按时间排序)
 */
int MC_QueryDevsStatusHistoryRecord(UI_HANDLE hUser, const char *szDevSNs, SQueryDevHistoryParams *pParams, int nSeq = 0);

/**
 * @brief 账户报警订阅
 * @param szUserID 账户UserID，不传默认使用当前账户的UserID(RS服务返回)
 * @param szVoice 报警声音文件名称（IOS）
 * @param szAppToken 订阅令牌，不传默认使用MC_Init传入的参数；格式：xxxx&&xxxx(Android&&信鸽)
 * @param szAppType 报警类型，必须与参数szAppToken对应；不传默认使用MC_Init传入的参数；格式： xxxx&&xxxx(Android&&信鸽)
 * @return 异步返回消息 ID：EMSG_MC_LINK_BY_USERID = 6025  ///<通过UserID进行报警订阅
 *                    param1: >=0 成功，否则失败
 *                    Str:结果信息(JSON格式)
 */
int MC_LinkByUserID(UI_HANDLE hUser, const char *szUserID = "", const char *szVoice = "", const char *szAppToken = "", const char *szAppType = "", int nSeq = 0);

/**
 * @brief 取消账户报警订阅
 * @param szUserID 账户UserID，不传默认使用当前账户的UserID(RS服务返回)
 * @param szAppToken 订阅令牌，不传默认使用MC_Init传入的参数；格式：xxxx&&xxxx(Android&&信鸽)
 * @param nClearFlag 是否清除所有订阅关系 *1表示:删除所有订阅关系（此时不需要AppToken字段）, 0或者无该字段表示:只删除指定Token的订阅关系
 * @return 异步返回消息 ID：EMSG_MC_UNLINK_BY_USERID  = 6026  ///<通过UserID进行报警取消订阅
 *                    param1: >=0 成功，否则失败
 *                    Str:结果信息(JSON格式)
 */
int MC_UnLinkByUserID(UI_HANDLE hUser, const char *szUserID = "", const char *szAppToken = "", int nClearFlag = 0, int nSeq = 0);

/**
 * @brief 查询云报警消息列表(携带缩略图地址)
 * @param pXPMS_SEARCH_ALARMINFO_REQ 请求参数信息结构体 详见@struct XPMS_SEARCH_ALARMINFO_REQ
 * @param nWidth 缩略图宽，原图默认传0
 * @param nHeight 缩略图高，原图默认传0
 * @details 接口内部自动循环查询，直到传递的时间范围内查不到结果
 * @return 异步回调消息 id:EMSG_MC_SEARCH_CLOUD_ALARM_INFO = 6027  ///<云报警消息列表查询(结果携带缩略图url)
 *                     param1: >=0 成功，否则失败
 *                     Str:设备序列号
 *                     pData：消息列表信息
 */
int MC_SearchCloudAlarmInfoByTime(UI_HANDLE hUser, XPMS_SEARCH_ALARMINFO_REQ *pXPMS_SEARCH_ALARMINFO_REQ, int nWidth = 0, int nHeight = 0, int nSeq = 0);

/**
 * @brief 云报警消息图片下载
 * @details 接口内部最多并发下载3张图片
 * @param szDevSN  设备序列号
 * @param szFileName 本地存储文件名 绝对路径
 * @param szAlaramJson 报警消息信息
 * @param bIsDownloadByUrl  是否通过url下载固定格式大小的缩略图  *0:不判断url，还是按照接口参数里面的长宽决定下载 1:只通过url下载图片
 * @param nWidth  缩略图宽，原图默认传0，bIsDownloadByUrl等于1时无效
 * @param nHeight 缩略图高，原图默认传0，bIsDownloadByUrl等于1时无效
 * @return 异步回调消息  id:EMSG_MC_DOWNLOAD_CLOUD_ALARM_IMAGE = 6028  ///< 云报警消息图片下载
 *                      param1: >=0 成功，否则失败
 *                      Str:设备序列号
 *                      pData：消息列表信息
 */
int MC_DownloadCloudAlarmImage(UI_HANDLE hUser, const char *szDevSN, const char *szFileName, const char *szAlaramJson, int nIsDownloadByUrl = 0, int nWidth = 0, int nHeight = 0, int nSeq = 0);

/**
 * @brief 根据时间点获取视频片段信息（批量）
 * @param szReqJson APP与SDK内部使用的Json，后面大部分多参数的接口都使用此方法，示例参考example
 * @see http://10.2.11.100/display/cloud/PMS_V2
 * @example
 * {
 *  "msg": "video_clip", 或者 "msg": "short_video_clip"  ///< 查看短视频的请求
 *  "sn": "c142dd39f8222e1d", ///< 设备序列号
 * 	"ch": 0, ///< 【可选】不填写此字段表示查询所有通道
 * 	"time":[ "2023-02-28 17:00:00","2023-02-28 18:00:00","2023-02-28 19:00:00"....], ///< 报警时间点
 * }
 * @return 异步回调消息 id:EMSG_MC_BATCH_SEARCH_VIDEO_CLIP_INFO = 6029  ///< 根据时间点获取视频片段信息（批量）
 *                    param1: >=0 成功，否则失败
 *                    Str:结果信息
 */
int MC_BatchSearchVideoClipInfo(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 设置报警消息已读标志
 * @param szDevSN 设备序列号
 * @param szAlarmIDs 报警消息ID，多个以";"分隔
 * @return 异步回调消息  id:EMSG_MC_SET_ALARM_MSG_READ_FLAG = 6030  ///< 设置报警消息已读标志
 *                     param1: >=0 成功，否则失败
 */
int MC_SetAlarmMsgReadFlag(UI_HANDLE hUser, const char *szDevSN, const char *szAlarmIDs, int nSeq = 0);

/**
 * @brief 批量设备报警消息查询
 * @details 客户端如果没有传入序列号，则查询当前账户下的所有设备(不包括分享的设备！)
 * @param szDevSNs 序列号，多个以;分隔
 * @param pInfo 请求的参数信息 详见@struct SBatchDevAlarmMsgQueryReqParams
 * @return 异步回调消息  id:EMSG_MC_BATCH_DEV_ALARM_MSG_QUERY = 6031  ///< 批量设备报警消息查询
 *                     param1: >=0 成功，代表数据大小，否则失败；
 *                     param2:报警条数；
 *                     param3：查询结束标志；
 *                     Str:查询设备列表；
 *                     pData:报警数据
 */
int MC_BatchDevAlarmMsgQuery(UI_HANDLE hUser, const char *szDevSNs, SBatchDevAlarmMsgQueryReqParams *pInfo, int nSeq = 0);

/**
 * @brief 设备报警消息查询
 * @details 支持分页&报警类型选择查询，同时兼容老的方式查询  ps:普通报警消息，分页查询无效!!!
 * @param pInfo 请求的参数信息 详见@struct SDevAlarmMsgQueryReqParams
 * @return 异步回调消息  id:EMSG_MC_DEV_ALARM_MSG_QUERY = 6032, ///< 设备报警消息查询(支持分页&报警类型选择查询)
 *                     param1: >=0 成功，代表数据大小，否则失败；
 *                     param2:报警条数；
 *                     param3：查询结束标志；
 *                     Str:设备序列号；
 *                     pData:报警数据
 */
int MC_DevAlarmMsgQuery(UI_HANDLE hUser, SDevAlarmMsgQueryReqParams *pInfo, int nSeq = 0);
