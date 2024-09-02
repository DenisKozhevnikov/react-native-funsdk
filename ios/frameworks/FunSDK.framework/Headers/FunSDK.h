/*********************************************************************************
 *Author:    Yongjun Zhao(赵永军)
 *Description:
 *History:
 Date:    2014.01.01/Yongjun Zhao
 Action：Create
 **********************************************************************************/
#pragma once
#ifndef FUNSDK_H
#define FUNSDK_H

#if defined(TARGET_OS_IOS)
#define OS_IOS 1
#endif

#include <string>
#include "XTypes.h"
#ifndef FUN_ONLY_ALRM_MSG
#include "GetInfor.h"
#include "netsdk.h"
#ifdef SUP_IRCODE
#include "irsdk_c.h"
#endif
#endif
#include "JPGHead.h"

#ifdef SUP_MEDIA_SUPER_RESOLUTION
#ifdef OS_ANDROID
#include <android/asset_manager_jni.h>
#include <android/asset_manager.h>
#endif
#endif

class XMSG;

//设备类型定义规则:
//产品类型目前是一个int，32位
//4位:版本号----------------------------------默认为0
//// 版本号1解析规则
//4位:产品大类：未知/IPC/NVR/DVR/HVR------------默认为0
//4位:镜头类型：未知/鱼眼/180/普通------------默认为0
//4位:厂家分类：未知/XM/JF/定制---------------默认为0
//16位：产品序列：（最多65535）
//示例：
//DEV_CZ_IDR 定制门铃是 0x11130001 ----> 二进制 0001 0001 0001 0011 0000000000000001 ---> 1->版本号, 1->IPC, 1->鱼眼, 3->定制, 1->产品序列
//EE_DEV_WBS 无线基站是 0x12310001 ----> 二进制 0001 0010 0011 0001 0000000000000001 ---> 1->版本号, 2->NVR, 3->普通镜头, 1->XM, 1->产品序列
typedef enum EFUN_DEV_TYPE
{
    EE_DEV_NORMAL_MONITOR,                              //传统监控设备
    EE_DEV_INTELLIGENTSOCKET,                           //智能插座
    EE_DEV_SCENELAMP,                                   //情景灯泡
    EE_DEV_LAMPHOLDER,                                  //智能灯座
    EE_DEV_CARMATE,                                     //汽车伴侣
    EE_DEV_BIGEYE,                                      //大眼睛
    EE_DEV_SMALLEYE,                                    //小眼睛/小雨点
    EE_DEV_BOUTIQUEROBOT,                               //精品机器人 雄迈摇头机
    EE_DEV_SPORTCAMERA,                                 //运动摄像机
    EE_DEV_SMALLRAINDROPS_FISHEYE,                      //鱼眼小雨点
    EE_DEV_LAMP_FISHEYE,                                //鱼眼灯泡
    EE_DEV_MINIONS,                                     //小黄人
    EE_DEV_MUSICBOX,                                    //智能音响 wifi音乐盒
    EE_DEV_SPEAKER,                                     //wifi音响
    EE_DEV_LINKCENTERT = 14,                            //智联中心
    EE_DEV_DASH_CAMERA,                                 //勇士行车记录仪
    EE_DEV_POWERSTRIP,                                  //智能排插
    EE_DEV_FISH_FUN,                                    //鱼眼模组
    EE_DEV_DRIVE_BEYE = 18,                             //大眼睛行车记录仪
    EE_DEV_SMARTCENTER  = 19,                           //智能中心
    EE_DEV_UFO = 20,                                    //飞碟
    EE_DEV_IDR = 21,                                    //门铃--xmjp_idr_xxxx
    EE_DEV_BULLET = 22,                                 //E型枪机--XMJP_bullet_xxxx
    EE_DEV_DRUM = 23,                                   //架子鼓--xmjp_drum_xxxx
    EE_DEV_CAMERA = 24,                                 //摄像机--camera_xxxx
    EE_DEV_FEEDER = 25,                                 //喂食器设备--feeder_xxxx
    EE_DEV_PEEPHOLE = 26,                               //猫眼设备--xmjp_peephole
    EE_DEV_DOORLOCK = 0x11110027,                       //门锁设备--xmjp_stl_xxxx
    EE_DEV_DOORLOCK_V2 = 0x11110031, 					//门锁设备支持音频和对讲--xmjp_stl_xxxx
    EE_DEV_SMALL_V = 0x11110032,						//小V设备--camera_xxxx
    EE_DEV_DOORLOCK_PEEPHOLE = 0x11110033,				//门锁猫眼
    EE_DEV_XIAODING = 0x11110034,                       //小丁设备
    EE_DEV_SMALL_V_2 = 0x11110035,						//小V200万（XM530）设备
	EE_DEV_BULLET_ESC_WB3F = 0x11110036,				//Elsys WB3F
	EE_NO_NETWORK_BULLET = 0x11310037,					//没有外网的枪机设备
	EE_DEV_ESC_WY3 = 0x11110038,						//Elsys 的设备
	EE_DEV_ESC_WR3F = 0x11110039,						//ESC-WR3F
	EE_DEV_ESC_WR4F = 0x11110040,						//ESC-WR4F Elsys的设备
	EE_DEV_K_FEED = 0x11310041,							//小K宠物喂食器
	EE_DEV_B_FEED = 0x11310042,							//小兔看护宠物喂食器
	EE_DEV_C_FEED = 0x11310043,							//小C宠物保鲜喂食器
	EE_DEV_F_FEED = 0x11310044,							//小方宠物喂水器
	EE_DEV_CAT = 0x11310045,							//小方宠物喂水器
	EE_DEV_BULLET_EG = 0x11310028,                      //EG型枪机--XMJP_bullet_xxxx
	EE_DEV_BULLET_EC = 0x11310029,                      //EC型枪机--XMJP_bullet_xxxx
	EE_DEV_BULLET_EB = 0x11310030,						//EB型枪机--XMJP_bullet_xxxx
	EE_DEV_CZ_IDR = 0x11130001,                         //定制门铃1--dev_cz_idr_xxxx
	EE_DEV_LOW_POWER = 0x11030002,						//低功耗无线消费类产品
    EE_DEV_NSEYE = 601,                                 //直播小雨点
	/// 此后严格遵守设备类型命名规则
	EE_DEV_WBS =  0x12310001,   // 无线基站
    EE_DEV_WNVR = 0x12310002,   // 无线NVR
	EE_DEV_WBS_IOT = 0x12310003,   // 无线基站支持IOT
}EFUN_DEV_TYPE;

typedef struct SDBDeviceInfo
{
    char    Devmac[64];            // DEV_SN / IP / DNS
    char    Devname[128];        // 名称   使用HTML编码中文1个8位（&#12455;）15(汉字） * 8 + 1（英文或数字） = 121
    char    devIP[64];        // 名称
    char    loginName[16];        // 用户名
    char    loginPsw[MAX_DEV_NAMEPASSWORD_LEN];        // 密码
    int     nPort;              // 端口映射端口
    
    int nType;      // --设备类型   EFUN_DEV_TYPE
    int nID;        // --本设备ID,内部使用
}SDBDeviceInfo;

typedef struct STime{
    int dwYear;
    int dwMonth;
    int dwDay;
    int dwHour;
    int dwMinute;
    int dwSecond;
}STime,*LPSTime;

// 库对象全局变量设置
typedef enum EFUN_ATTR
{
    EFUN_ATTR_APP_PATH = 1, // 废弃，未使用
    EFUN_ATTR_CONFIG_PATH = 2, // 一些缓存信息保存文件路径
    EFUN_ATTR_UPDATE_FILE_PATH = 3,     // 升级文件存储目录
    EFUN_ATTR_SAVE_LOGIN_USER_INFO = 4, // GET 获取登陆用户信息
    EFUN_ATTR_AUTO_DL_UPGRADE = 5,      // 是否自动下载升级文件0:NO 1:WIFI下载 2:网络通就下载 // 功能已废弃
    EFUN_ATTR_FUN_MSG_HANDLE = 6,       // 接收FunSDK返回的设备断开等消息
    EFUN_ATTR_SET_NET_TYPE = 7,         // ENET_MOBILE_TYPE(0:未知 1:WIFI 2:移动网络 4:物理网卡线)
    EFUN_ATTR_GET_IP_FROM_SN = 8,       // 通过序列号获取局域网IP
    EFUN_ATTR_TEMP_FILES_PATH = 9,      // GET临时文件目录
    EFUN_ATTR_USER_PWD_DB = 10,          // 用户密码数据保存文件
    EFUN_ATTR_LOGIN_ENC_TYPE = 11,      // 指定登录加密类型，默认为0:MD5&RSA 1:RSA(需要设备支持)
    EFUN_ATTR_LOGIN_USER_ID = 12,       // Login  user id
    EFUN_ATTR_CLEAR_SDK_CACHE_DATA = 13,// Clear sdk cache data
    EFUN_ATTR_DSS_STREAM_ENC_SYN_DEV = 14,   // DSS码流校验规则是否同步设备方式设置（0:通用方式校验，1:跟设备登录密码相同方式校验）
    EFUN_ATTR_CDATACENTER_LANGUAGE = 15,// 设置语言类型,FunSDK初始化结构体参数里面的语言设置，初始化过后，app后续会再次更改语言类型
    EFUN_ATTR_LOGIN_SUP_RSA_ENC = 16, // 登录加密是否支持，0:不支持(直接登陆，且不获取加密信息了，rsa/aes都不支持了)  1:支持(默认)（ 为了临时解决设备端对登录RSA加密校验方式和sdk这边的方式不同）
	EFUN_ATTR_JUDEGE_RPSVIDEO_ABILITY = 17, // 是否只进行rps在线状态判断，不进行能力级判断（"OtherFunction/SupportRPSVideo"）0:只判断在线状态，不判断能力级， 1:同时判断
    EFUN_ATTR_LOGIN_AES_ENC_RESULT = 18, // 默认值0：99999获取加密信息，未返回明确结果，则使用明文登录 1：未返回明确结果，则返回错误-400102，不会去登录
    EFUN_ATTR_FACE_CHECK_OCX = 19, // 判断当前app账户证书合法性 0:非法 1:合法, 默认合法;app调用FUN_XMCloundPlatformInit接口时sdk会主动调用此属性或者上层APP主动调用此属性
    EFUN_ATTR_GET_ALL_DECODER_FRAME_BITS_PS = 20, // 统计所有decoder对象累加的码流平均值,即当前播放多通道的网速 单位：byte(字节)
    EFUN_ATTR_LOGIN_RPS_STATE_ALLOW = 21, // 登录设备之前是否rps状态需要查询得到非E_FUN_NotAllowed结果 0:不需要  1:需要 (只是判断条件之一),调用FUN_XMCloundPlatformInit接口自动设置为1
    EFUN_ATTR_SUP_RPS_VIDEO_DEFAULT = 22, // RPS视频能力级默认值  0:默认不支持 1:默认支持
    EFUN_ATTR_SET_DSS_REAL_PLAY_FLUENCY = 23, // DSS视频播放流畅度设置  (等级设置值:8~12,其他值无效!),设置之后不再根据I帧间隔动态改变
	EFUN_ATTR_SET_CLOUD_UPGRADE_CHECK_URL = 24, // 云端升级检测url自定义设置
	EFUN_ATTR_SET_CLOUD_UPGRADE_DOWNLOAD_URL = 25, // 云端升级固件下载url自定义设置
	EFUN_ATTR_SET_RPS_DATA_ENCRYPT_ENABLE = 26,	// RPS协议数据交互加密开关  0:关闭 1:开启(默认值)
	EFUN_ATTR_SET_HTTP_PROTOCOL_USER_AGENT = 27, // http协议用户代码信息设置
	EFUN_ATTR_SET_MULTI_VIEW_DROP_FRAME_NUMBER = 28, // 多目信息帧发生改变，回调给app之后，默认丢弃视频帧个数  *默认值:0
	EFUN_ATTR_GET_USER_ACCOUNT_DATA_INFO = 29, // 获取用户账户数据信息
	EFUN_ATTR_SET_SUPPORT_CFG_CLOUD_UPGRADE = 30, // 是否默认支持设备云端升级
	EFUN_ATTR_DEV_TOKEN_ERROR_LISTENER = 31, // 设备TOKEN错误(137)监听，通过消息ID:5549异步回调
	EFUN_ATTR_QUERY_P2P_STATUS_ENABLE_FORM_SERVER = 32, // @deprecated废弃使用EFUN_ATTR == 33代替; 从服务器查询P2P状态使能  TRUE(非0):查询 FALSE(0):不查询 *默认TRUE(查询)
	EFUN_ATTR_QUERY_P2P_STATUS_ENABLE = 33, // 查询P2P状态使能  详见@enum EQueryP2PEnable
	EFUN_ATTR_SET_CLOUD_DOWNLOAD_NETPTL = 34, /** 设置云服务数据下载网络协议  详见@enum ECloudDownloadNetPtl */
	EFUN_ATTR_SUP_HISI_H265_DEC = 35, /** 是否支持hisi的h.265解码 0：不支持(默认值，默认使用ffmpeg) 1：支持 */
	EFUN_ATTR_DEV_LOGIN_ENC_TOKEN_WHERE_TO_GET_IT = 36, /** 设置从哪里获取设备登录加密TOKEN ps:0 : RS服务获取 1: JVSS服务获取 */
	EFUN_ATTR_MQTT_CLIENTID = 37, /** MQTT clientID */
	EFUN_ATTR_SET_NETIP_PTL_SEND_PKT_MAX_SIZE = 38, ///< 设置NetIP协议发送包最大字节数，默认64K
	EFUN_ATTR_ENABLE_NEW_SERVER_FOR_UPGRADES = 39, ///< 启用升级新服务器(SDK内部与升级服务器交互域名)  0:自动选择 1：全部走新服务器地址
	EFUN_ATTR_SET_P2P_PROXY_SUPPORT_HD = 41, ///< 设置P2P代理(转发)模式支持高清实时预览  0:不支持高清(自动切换到标清) 1:支持高清(最终由设备&服务器决定)
	EFUN_ATTR_DEV_SDCARD_RECORD_PRIVATE_KEY = 42, ///< SD卡录像回放数据加密专有字符串(序列号+此字符串(取前36个字节，如果不够则用'\0'补齐36个))
    EFUN_ATTR_SET_RPS_PROTOCOL_MODE = 43, ///< 设置设备端和APP端连接RPSAccess服务器的协议模式，默认 E_RPS_PTL_MODE_AUTO 详见@enume ERPSProtocolMode
    EFUN_ATTR_SET_RECV_ALARM_PUSH_ALL_INFO = 44, ///< 接收内部报警推送服务推送全部内容  0:默认格式(SDK内部自组) 1:SDK内部自组格式+"AllPushInfo"(推送全部内容) ps:如果存在"MessageType"是"MSG_SEND_REQ的话，只有"CustomInfo"字段(与"AllPushInfo"互斥且内容相同)
    EFUN_ATTR_SET_DEVSN_QUERY_STATUS_TYPE_MASK_VALUE = 45, ///< 设置查询序列号设备状态类型掩码值 详见@enum EDevStatusType    默认值:-1   注意：设置的是全局属性，影响全部非低功耗序列号添加的设备查询
}EFUN_ATTR;

typedef enum EOOBJECT_ID
{
    EOOBJECT_MEDIA_SYN = 1,
    EOOBJECT_USER_SERVER = 2,
}EOOBJECT_ID;

typedef enum ENET_MOBILE_TYPE
{
	ENET_TYPE_UNKNOWN = 0, // 未知
    ENET_TYPE_WIFI = 1,     // WIFI
    ENET_TYPE_MOBILE = 2,   // 移动网络
    ENET_TYPE_NET_LINE = 4, // 物理网卡线
}ENET_MOBILE_TYPE;

typedef enum E_FUN_PTZ_COMMAND
{
    EE_PTZ_COMMAND_UP,
    EE_PTZ_COMMAND_DOWN,
    EE_PTZ_COMMAND_LEFT,
    EE_PTZ_COMMAND_RIGHT,
    EE_PTZ_COMMAND_LEFTUP,
    EE_PTZ_COMMAND_LEFTDOWN,
    EE_PTZ_COMMAND_RIGHTUP,
    EE_PTZ_COMMAND_RIGHTDOWN,
    EE_PTZ_COMMAND_ZOOM,
    EE_PTZ_COMMAND_NARROW,
    EE_PTZ_COMMAND_FOCUS_FAR,
    EE_PTZ_COMMAND_FOCUS_NEAR,
    EE_PTZ_COMMAND_IRIS_OPEN,
    EE_PTZ_COMMAND_IRIS_CLOSE
}E_FUN_PTZ_COMMAND;

//DSS通道状态
typedef enum E_DSS_CHANNEL_STATE
{
    DSS_DEC_STATE_NOLOGIN = -3, 	//前端未登录
    DSS_DEC_STATE_NOCONFIG,			//前端未配置
    DSS_DEC_STATE_STREAM_FORBIDDEN, //禁止该路推流
    DSS_DEC_STATE_NOT_PUSH_STRREAM, //未推流状态
    DSS_DEC_STATE_PUSHING_STREAM,	//正在推流
    DSS_DEC_STATE_MULITCODE_STREAM, //混合编码通道
}E_DSS_CHANNEL_STATE;

typedef enum E_SYS_MODIFY_DEV_INFO
{
	E_SYS_DEV_INFO_ADD = 0,    // 添加设备信息到本地缓存
	E_SYS_DEV_INFO_MODIFY = 1, // 修改本地缓存设备信息
	E_SYS_DEV_INFO_DELETE = 2, // 删除本地缓存设备信息
}E_SYS_MODIFY_DEV_INFO;

/**
 * @brief 状态查询类型
 * @details 一般当做掩码值使用   示例: 0x1 << E_DevStatus_P2P | 0x1 << E_DevStatus_P2P_V0  
 */
typedef enum EDevStatusType
{
    E_DevStatus_P2P = 0,        ///< P2P要用新的状态服务查下
    E_DevStatus_TPS_V0 = 1,     ///< @deprecated 老的那种转发，用于老程序（2016年以前的）的插座，新的插座程序使用的是TPS
    E_DevStatus_TPS = 2,        ///< @deprecated 透传服务
    E_DevStatus_DSS = 3,        ///< 媒体直播服务
    E_DevStatus_CSS = 4,        ///< @deprecated 云存储服务
    E_DevStatus_P2P_V0 = 5,     ///< /P2P用老的方式,通过穿透库查询获取到的设备P2P状态
    E_DevStatus_IP = 6,         ///< IP方式
    E_DevStatus_RPS = 7,        ///< RPS可靠的转发
    E_DevStatus_IDR = 8,        ///< 门铃状态
    E_DevStatus_RTC = 9,        ///< @deprecated WEB-RTC状态
    E_DevStatus_XMSDK = 10,     ///< @deprecated XMNetSDK状态
    E_DevStatus_XTS = 11,       ///< @deprecated XTS状态，IPC使用，最稳定的状态
    E_DevStatus_XTC = 12,       ///< @deprecated XTC状态，NVR使用
    DEV_STATE_SIZE,             ///< NUM....
}EDevStatusType;

/**
 * @enum EQueryP2PEnable
 * @brief p2p状态查询使能
 */
using EQueryP2PEnable = enum EQueryP2PEnable{
	E_QUERY_P2P_ALL_NOT = 0, /** 都不查询 */
	E_QUERY_P2P_FORM_EZNAT_LIB = 1, /** 穿透库接口查询 */
	E_QUERY_P2P_FORM_P2P_STATUS = 2, /** p2p-status查询 */
	E_QUERY_P2P_ALL_QUERY = 3, /** 穿透库接口 & p2p-status查询 */
};

/**
 * @enum ECloudDownloadNetPtl
 * @brief 云端数据下载协议
 */
using ECloudDownloadNetPtl = enum ECloudDownloadNetPtl
{
	E_CLOUD_DOWNLOAD_NETPTL_HTTP = 0, /** 只支持http协议进行云存储数据下载 */
	E_CLOUD_DOWNLOAD_NETPTL_HTTPS = 1, /** 默认, 允许支持https协议进行云存储数据下载，但是前提是需要通过css服务器下发的"Schema"字段判断是否支持 */
};

const static char* kAVTalkCtrlVideoPause = "video_pause";  ///< 音视频对讲操作命令:视频暂停
const static char* kAVTalkCtrlVideoContinue = "video_continue";  ///< 音视频对讲操作命令:视频恢复
const static char* kAVTalkCtrlVideoSwitchingResolution = "switching_resolution";  ///< 音视频对讲操作命令:切换分辨率

/**
 * @enum EEncoderPreSet
 * @brief 编码器的预设配置，以平衡编码速度、压缩效率和输出视频质量
 */
using EEncoderPreSet = enum EEncoderPreSet
{
	E_ENCODER_PRESET_DEFAULT = 0, 	///< 默认值(E_ENCODER_PRESET_VERYFAST),内部兼容使用
	E_ENCODER_PRESET_ULTRAFAST = 1, ///< 最快的预设，但输出视频质量可能较低
	E_ENCODER_PRESET_SUPERFAST = 2, ///< 较快的预设，适用于需要更快速编码的情况。
	E_ENCODER_PRESET_VERYFAST = 3, 	///< 默认预设，提供了合理的速度和质量平衡。
	E_ENCODER_PRESET_MEDIUM = 4, 	///< 逐渐增加的质量，但编码速度逐渐减慢。
	E_ENCODER_PRESET_SLOW = 5, 		///< 较高的质量，但编码速度非常慢。
};

/**
 * @enum EAVTalkSendMediaType
 * @brief 发送的数据类型
 * @details 开启音视频对讲的时候，通知设备接下来发送的数据类型包含哪些
 */
using EAVTalkSendMediaType = enum EAVTalkSendMediaType
{
	E_AVTALK_SEND_MEDIA_TYPE_ALL = 0, ///< 发送音视频数据【默认值】
	E_AVTALK_SEND_MEDIA_TYPE_AUDIO = 1, ///< 仅发送音频数据
	E_AVTALK_SEND_MEDIA_TYPE_VIDEO = 2, ///< 仅发送视频数据
};

/**
 * @enum ECloudDownloadNetPtl
 * @brief 标识设备端和APP端连接RPSAccess服务器的协议模式
 */
using ERPSProtocolMode = enum ERPSProtocolMode
{
	E_RPS_PTL_MODE_AUTO = 0, ///< 优先采用KCP协议，如果KCP失败，则自动切换为TCP协议
	E_RPS_PTL_MODE_TCP = 1, ///< 只采用 TCP 方式	只采用TCP方式访问RPSAccess，失败之后不进行自动切换
	E_RPS_PTL_MODE_KCP = 2, ///< 只采用 KCP 方式访问RPSAccess， 失败之后不进行自动切换
};

typedef struct SInitParam
{
    int nAppType;
    char nSource[64]; // "xmshop"：商城（默认）, "kingsun"：勤上
    char sLanguage[32]; //中文（zh）、英文（en）
}SInitParam;

#ifdef SUP_PREDATOR
typedef struct _SPredatorAudioFileInfo
{
	int year;
	int month;
	int day;
	int hour;
	int minute;
	int second;
	int nOperationtype; //文件操作类型 1:发送文件 2:删除文件 3:取消文件传输
	char szFileName[18]; //文件名称
}SPredatorAudioFileInfo;
#endif

typedef struct _SSubDevInfo //子设备信息， 检查更新时，Type可选， 默认“IPC”，其它需赋值； 开始升级时，暂时只需要SN、 SoftWareVer，其它可选
{
    char strSubDevSN[32];
    char strBuildTime[32];
    char strSoftWareVer[64];
    char strDevType[8];   //IPC、DVR and so on
}SSubDevInfo;

/**@struct SDevTalkParams
 * @brief 设备对讲参数信息
 */
using SDevTalkParams = struct SDevTalkParams
{
	int nSupIpcTalk; /** 是否支持IPC对讲，非0支持,0不支持，能力级:SupportIPCTalk */
	int nDevChannel; /** 设备通道号，nSupIpcTalk != 0时生效，-1表示对所有连接的前端IPC单向广播，>=0表示指定某通道进行对讲 */
	int nVersion; /** 私有头组装版本 0:00 00 01 FA, 8字节头默认版本， 1:00 00 01 EA, 16字节头版本 */
	int nSampleRate; /** 采样频率  默认8000 */
	int nSampleBits; /** 采样位数  默认16bit */
	int nChannels; /** 通道数  默认单通道 */
	SDevTalkParams()
	{
		nSupIpcTalk = 0;
		nDevChannel = -1;
		nVersion = 0;
		nSampleRate = 8000;
		nSampleBits = 16;
		nChannels = 1;
	}
};

#ifndef FUN_ONLY_ALRM_MSG

#ifdef FUN_TEST_STATE
/**@brief 设置全局变量属性，关闭新消息通道服务（xmsdk->xts/c）*此方法必须在FunSDk.Init之前调用 */
void FUN_SetNotSupXMSDKAttr();
#endif

/**@brief 禁用外网
 * @details 禁用外网，只允许局域网访问，相关外网的功能禁用（登录服务器、报警、状态、认证等后台发起的需要联外网的功能）
 * @warning 此方法必须在FunSDK初始化(FUN_Init)之前调用
 */
void Fun_DisableConnectExtranet();

#ifdef SUP_XMNAT_NABTO
/**@brief  设置临时资源目录
 * @details 设置特殊版本xmnat_nabto临时资源目录
 * @warning 此方法必须在FunSDK初始化之前调用并且需要开启功能宏：SupNabto
 * @param[in] sPath 临时资源目录
 */
int Fun_SetXMNatNabtoPath(const char *sPath);

/**@brief  设置日志等级
 * @details 设置xmnat_nabto日志等级 *Android.mk需要开启功能宏：SupNabto
 * @param[in] sLogLevel 日志等级:"error", "warn", "info", "debug", "trace" *默认:"debug"
 */
int Fun_SetXMNatNabtoLogLevel(const char *sLogLevel);

/**@brief  获取Nabto Device ID
 * @details 获取Nabto Device ID ，如果获取到为空的不显示（表明不是Nabto的设备，方便排查是否已经绑定Nabto ID或者已升级新固件）
 * @param[in] sDevSn 设备序列号
 * @param[out] sDevID Nabto Device ID
 */
int Fun_GetXMNabtoDevID(const char *sDevSn, char *sDevID);
#endif

/**@brief 库初始化
 * @details 整个程序只需要调用一次
 * @param[in] nParam 暂时未使用
 * @param[in] pParam 初始化参数，详见@struct SInitParam
 * @param[in] nCustom 设备登录密码加密类型 详见@enum E_PWDCustomType
 * @param[in] pServerAddr  p2p服务地址，默认使用通用p2p域名
 * @param[in] nServerPort p2p服务端口，默认使用通用p2p端口
 * @return == EE_OK(0)
 */
int FUN_Init(int nParam = 0, SInitParam *pParam = NULL, const int nCustom = 0, const char *pServerAddr = NULL, const int nServerPort = 0);

/** @deprecated 接口废弃，使用FUN_InitExV2取代 */
int FUN_InitEx(int nParam = 0, SInitParam *pParam = NULL, const char* strCustomPWD = "", const char *strCustomServerAddr = NULL, const int nCustomServerPort = 0);

/**@brief 库初始化
 * @details 特殊定制的设备"密码加前缀"或"定制p2p服务"的时候使用
 * @param[in] nParam 暂时未使用
 * @param[in] pParam 初始化参数，详见@struct SInitParam
 * @param[in] nPWDCustomeType 设备登录密码加密类型 详见@enum E_PWDCustomType
 * @param[in] strCustomPWD 设备登录密码加密前缀，结合nPWDCustomeType使用
 * @param[in] strCustomServerAddr  p2p服务地址，默认使用通用p2p域名
 * @param[in] nCustomServerPort p2p服务端口，默认使用通用p2p端口
 * @return == EE_OK(0)
 */
int FUN_InitExV2(int nParam, SInitParam *pParam, int nPWDCustomeType, const char* strCustomPWD, const char *strCustomServerAddr = NULL, const int nCustomServerPort = 0);

void FUN_TestTest(int hUser, int nParam1, int nParam2, const char *szParam);

/**@brief 反初始化
 * @details 基本不需要调用，整个进程运行期间只需要初始化一次SDK(FUN_Init)，直到杀死进程
 * @param[in] nType 0：注销报警服务 1：不注销报警服务
 */
void FUN_UnInit(int nType = 0);

/**@brief 设备网络服务相关初始化
 * @details 加载设备之前调用，参数nCustom、pServerAddr、nServerPort废弃，只为兼容以前的版本
 * @param nCustom 废弃
 * @param pServerAddr 废弃
 * @param nServerPort 废弃
 * @return == EE_OK(0)成功，否者失败
 */
int FUN_InitNetSDK(const int nCustom = 0, const char *pServerAddr = NULL, const int nServerPort = 0);

/**@brief 设备网络服务相关反初始化，登出时调用
 * @details 1.清空录像缩略图下载缓存队列 2.清除所有设备连接信息 3.清空设备状态 4.清空设备authcode
 */
void FUN_UnInitNetSDK();

/**@brief 云账户系统初始化
 * @details 开发平台账户系统初始化
 * @param[in] szIP 废弃
 * @param[in] nPort 废弃
 * @return == EE_OK(0)
 */
int FUN_SysInit(const char *szIP, int nPort);

/**@brief 本地账户系统初始化
 * @details 本地账户系统初始化
 * @param[in] szDBFile 保存本地账户设备信息数据库文件
 * @return == EE_OK(0)
 */
int FUN_SysInit(const char *szDBFile);

/**@brief AP模式账户系统初始化
 * @details 设备AP模式(一般设备重置键连续按三次进入AP模式)，手机WIFI连接设备热点，AP登录账户
 * @param[in] szDBFile 保存本地账户设备信息数据库文件
 * @return == EE_OK(0)
 */
int FUN_SysInitAsAPModel(const char *szDBFile);

/**
 * @brief 初始化一些账户系统需要使用的基础信息
 * @details 可以兼容 Fun_SysInitUserAgentInfo、Fun_SysInitVerificationCodeSize、Fun_SysInitAccountAccessToken
 * @param szInfoJson 参数信息(JSON格式) 参考如下：
 * @example
 * {
 *    "msg" : "at_basic_info"
 *    "useragent" : "", ///< 【可选】用户代理信息，用于记录访问当前服务器的客户标识
 *    "codesize" : "6",  ///< 【可选】服务器下发验证码长度 默认"6"
 *    "language" ： "zh_CN", ///< 【可选】 语言
 *    "region" : "", ///< 【可选】地区
 *    "accesstoken" : "", ///< 【可选】访问令牌信息  【慎用】会覆盖当前账户信息，为了类似于jlink，账户登录不在SDK内部做的客户端使用
 *    "logintype" : "" ///< 【可选】登录类型 通用传"", 第三方传"wx" "fb" "gg" "line"等 【慎用】同上
 * }
 */
void Fun_SysInitBasicInfo(const char *szInfoJson);

/**@brief 密码数据迁移
 * @details 如果APP版本更新之后，本地缓存的设备密码文件路径发生变更，则需要调用此接口进行密码数据迁移。\n
 * * 		 通过参数传的密码文件&&密钥文件，把数据迁移到当前APP密码保存文件下。\n
 * 		 注意: \n
 * 		 1.支持旧版本文件xxxx/password.txt(文件名必须是password.txt)数据迁移。\n
 * 		 2.迁移之后请自行删除临时文件。\n
 * 		 3.必须在本地密码缓存文件路径初始化之后调用
 * @param[in] sPwdFile 需要迁移的存储密码数据文件，旧版本：password.txt 新版本：eketfo.txt
 * @param[in] sPwdAesKeyFile AES密钥文件，新版本才需要传此文件：local_eketkey.txt
 * @return >=0成功，其他失败，详见错误码。
 */
int Fun_ThePwdDataMigration(const char *sPwdFile, const char *sPwdAesKeyFile);

/**@brief 同Fun_ThePwdDataMigration 密码数据迁移
 * @param sPwdFile 同上
 * @param sPwdAesKeyFile 同上
 * @param bIsCover 是否覆盖本地密码  true：覆盖 false：当本地密码存在时，不覆盖
 * @return >=0成功，其他失败，详见错误码。
 */
int Fun_ThePwdDataMigrationV2(const char *sPwdFile, const char *sPwdAesKeyFile, bool bIsCover);

/**@brief 设置服务IP和Port
 * @details 服务IP/Port不是默认，使用此接口进行配置
 * @param szKey 键值，不同服务器使用不同的键值对应
 * @param szServerIP 域名或IP  *设置https端口的时候，如果端口不是默认443端口，则服务器ip格式一定要https://xxxxx
 * @param nServerPort 端口
 * @see WIKI:http://10.2.11.100/pages/viewpage.action?pageId=22450648
 * @return == EE_OK(0)
 */
int FUN_SysSetServerIPPort(const char *szKey, const char *szServerIP, int nServerPort);

/*********************************************
* 方法名: 初始化服务器用户代理信息
* 描  述: 初始化服务器用户代理信息，用于记录访问当前服务器的客户标识，目前只用于账户服务XMAccount
* 返回值:
*      [无]
* 参  数:
*      输入(in)
*      		[sInfo] 用户代理信息，使用当前手机信息组成:设备机型_操作系统_随机码
****************************************************/
void Fun_SysInitUserAgentInfo(const char *sInfo);

/*********************************************
* 方法名: 初始化app证书
* 描  述: XM云平台账户注册信息
* 返回值:
*      [无]
* 参  数:
*      输入(in)
*          [uuid]  客户唯一标识
*          [appKey] 应用key
*          [appSecret] 应用密钥
*          [movedCard] 移动取模基数
*      输出(out)
*          [无]
****************************************************/
int FUN_XMCloundPlatformInit(const char *uuid, const char *appKey, const char *appSecret, int movedCard);

/*******************用户服务相关的接口**************************
* 方法名: 初始化验证码长度
* 描  述: 初始化服务器下发验证码长度，支持4位/6位等验证码长度设置
*         设置后，re:注册  fp:找回密码 login:登陆 bin:绑定 ucan：注销等同步支持
* 注 意: 同步接口，设置后立即生效
* 返回值:
*      [无]
* 参  数:
*      输入(in)
*          [szVerCodeSize:支持的验证码长度 "4"/"6"  *同服务器定义]
*      输出(out)
*          [无]
****************************************************/
void Fun_SysInitVerificationCodeSize(const char *szVerCodeSize);

/**
 * @brief 初始化账户访问令牌信息
 * @details 初始化账户访问令牌信息，后续账户相关接口使用此访问令牌，和获取设备列表接口互斥
 * @param szLoginType 登录类型 通用传"", 第三方传"wx" "fb" "gg" "line"等
 * @param szAccessToken 访问令牌信息
 */
void Fun_SysInitAccountAccessToken(const char *szLoginType, const char *szAccessToken);

/**
 * @brief 获取当前登录参数信息
 * @param szLoginParams[out] 参数信息 格式:loginType=%s&&accessToken=%s  数组大小2048
 * @return 无
 */
char *Fun_SysGetCurLoginParams(char szLoginParams[2048]);

/**
 * @brief 同步设备信息到数据中心(SDK本地数据中心)
 * @details 仅支持JVSS服务下发的Json数据格式
 * @details 同步设备列表信息到SDK内部缓存数据中心（同步），并且Android相应的设备进行报警推送服务初始化（异步）。
 * @param szDevInfos 设备列表信息 @warning 服务器下发的整个json，不要单独截取
 */
int Fun_SysSyncDevInfoToDataCenter(const char *szDevInfos);

/**@brief 获取视频请求统计信息
 * @details 规则：只对设备登录成功之后或者不需要登录的DSS&GWM进行视频播放结果，视频播放成功(收到第一个I帧，APP提示缓冲结束)次数进行统计
 * @return 视频请求统计信息字符串，示例：[{"vidr":1,"vids":1,"vidt":"IP"},{"vidr":1,"vids":1,"vidt":"RPS"}]
 */
const char *Fun_GetVideoPlayStatistics();

/** @brief 删除视频请求统计信息,客户端在上报成功之后调用此接口进行本地数据清空 */
void Fun_DelVideoPlayStatistics();

#define LOG_UI_MSG  1
#define LOG_FILE    2
#define LOG_NET_MSG 4
/*日志功能方法*/
void Fun_Log(const char *szLog);
void Fun_LogInit(UI_HANDLE hUser, const char *szServerIP, int nServerPort, const char *szLogFile, int nLogLevel = 0x3);
void Fun_SendLogFile(const char *szFile);

// 崩溃信息 + 崩溃之前的SDK信息另存文件保存
void Fun_Crash(char *crashInfo);

/*******************SDK编译**************************
* 方法名: FunSDK编译版本信息
* 描  述: FunSDK编译版本日期，版本号
* 返回值:
*      compiletime=%s&number=1.0.1  编译日期&FunSDK版本号
*      版本号组成：1.0.0：主版本号.次版本号.修订号
*      		         主版本号：全盘重构时增加；重大功能或方向改变时增加；大范围不兼容之前的接口时增加；
*			         次版本号：增加新的业务功能时增加；
*			         修订号：增加新的接口时增加；在接口不变的情况下，增加接口的非必填属性时增加；增强和扩展接口功能时增加。
* 参  数:
*      输入(in)
*      输出(out)
*          [无]
* 结果消息：
* 		[无]
****************************************************/
char *Fun_GetVersionInfo(char szVersion[512]);

// 后台，前台切换函数
void Fun_SetActive(int nActive);

/*********************************************
* 方法名: 设置p2p数据交互加密开关
* 描  述: 设置p2p数据交互加密开关
* 返回值:
*      [无]
* 参  数:
*      输入(in)
*      [nEnable: 加密使能 0:关闭, 1:开启(默认)]
*      输出(out)
*          [无]
* 结果消息：
* 		[无]
****************************************************/
int Fun_SetP2PDataEncryptEnable(int nEnable);

//About Languae
int Fun_InitLanguage(const char *szLanguaeFileName);
int Fun_InitLanguageByData(const char *szBuffer);
const char *Fun_TS(const char *szKey, const char *szDefault = NULL);

#ifdef OS_IOS
UI_HANDLE FUN_RegWnd(LP_WND_OBJ pWnd);
void FUN_UnRegWnd(UI_HANDLE hWnd);
void FUN_ClearRegWnd();

/**
 * @brief 停止rps服务
 * @details app进程杀死的时候调用此接口
 */
void Fun_StopRpsServer();
#endif

/*系统功能方法*/
//---用户注册相关接口---
#ifndef CUSTOM_MNETSDK
/** @deprecated */
int FUN_SysRegUserToXMExtend(UI_HANDLE hUser, const char *UserName, const char *pwd, const char *checkCode, const char *phoneNO, const char *source, const char *country, const char *city, int nSeq = 0);
/** @deprecated */
int FUN_SysRegisteByEmailExtend(UI_HANDLE hUser, const char *userName, const char *password, const char *email, const char *code, const char *source, const char *country, const char *city, int nSeq = 0);

/** @deprecated 请使用FUN_SysRegUserToXM接口*/
int FUN_SysNoValidatedRegisterExtend(UI_HANDLE hUser, const char *userName, const char *pwd, const char *source, const char *country, const char *city, int nSeq  =0);

/** @deprecated ARSP XMeye用*/
int FUN_SysUser_Register(UI_HANDLE hUser, const char *UserName,const char *Psw,const char *email, int nSeq = 0);    //注册用户
#endif
//通用用户注册接口
/**
 * @brief 通用用户注册接口
 * @param UserName 用户名
 * @param pwd 密码
 * @param checkCode 验证码
 * @param phoneNO 手机号
 * @return 异步回调消息 ID：EMSG_SYS_REGISER_USER_XM = 5011,      // 用户注册
 *                    param1: >=0 成功，否则失败
 */
int FUN_SysRegUserToXM(UI_HANDLE hUser, const char *UserName, const char *pwd, const char *checkCode, const char *phoneNO, int nSeq);

/**
 * @brief 通过邮箱注册账户
 * @param UserName 用户名
 * @param pwd 密码
 * @param email 邮箱地址
 * @param code 验证码
 * @return 异步回调消息 ID：EMSG_SYS_REGISTE_BY_EMAIL = 5042,  // 邮箱注册
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysRegisteByEmail(UI_HANDLE hUser, const char *userName, const char *password, const char *email, const char *code, int nSeq);

/** @deprecated 使用FUN_SysRegisteByEmail或FUN_SysRegUserToXM(手机)代替，验证码填写为空即可 */
int FUN_SysNoValidatedRegister(UI_HANDLE hUser, const char *userName, const char *pwd, int nSeq  = 0);


/**
 * @brief 注销用户账号
 * @details 通过验证码注销用户账号。checkCode传空时：1.用户绑定过手机号或者邮箱时，系统会默认发送验证码到绑定的手机号和邮箱中
 *                                             2.用户没有绑定过手机号或者邮箱时，会直接注销用户信息
 *                             checkCode传入值时：如果值校验成功，则注销用户信息
 * @param checkCode 验证码
 * @return 异步回调消息 ID：EMSG_SYS_CANCELLATION_USER_XM = 5075,		  // 注销用户账号
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysCancellationAccount(UI_HANDLE hUser, const char *checkCode, int nSeq = 0);

//---用户忘记/修改密码相关接口---
#ifndef CUSTOM_MNETSDK

/**
 * @brief 修改用户密码
 * @details 支持修改非当前登录账户密码(UserName和当前登录账户名不一致时)
 * @param UserName 用户名
 * @param old_Psw 旧密码
 * @param new_Psw 新密码
 * @return 异步回调消息 ID：EMSG_SYS_PSW_CHANGE = 5003,        // 修改用户密码
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysPsw_Change(UI_HANDLE hUser, const char *UserName,const char *old_Psw,const char *new_Psw, int nSeq = 0);
/** @deprecated 通过邮箱找回密码 */
int Fun_SysGetPWByEmail(UI_HANDLE hUser, const char* UserName, int nSeq = 0);
#endif

/**
 * @brief 邮箱获取验证码
 * @details 用户注册时使用，邮件会显示“Customer”
 * @param email 邮箱地址
 * @return 异步回调消息 ID：EMSG_SYS_SEND_EMAIL_CODE = 5041,     // 发送邮箱验证码
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysSendEmailCode(UI_HANDLE hUser, const char *email, int nSeq); //邮箱获取验证码(用户注册)

/**
 * @brief 邮箱获取验证码
 * @details 用户注册时使用,邮件会显示username
 * @param email 邮箱地址
 * @param username 用户名称
 * @return 异步回调消息 ID：EMSG_SYS_SEND_EMAIL_CODE = 5041,     // 发送邮箱验证码
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysSendEmailCodeEx(UI_HANDLE hUser, const char *email, const char *username, int nSeq);

/**
 * @brief 手机获取验证码
 * @details 用户注册时使用,邮件会显示用户名
 * @param email 邮箱地址
 * @param username 用户名称
 * @return 异步回调消息 ID：EMSG_SYS_GET_PHONE_CHECK_CODE = 5010, // 获取手机验证码(用户注册时使用)
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysSendPhoneMsg(UI_HANDLE hUser, const char *UserName, const char *phoneNO, int nSeq = 0);    //手机获取验证码(用户注册)

/**
 * @brief 邮箱获取验证码
 * @details 用户修改/重置密码时使用,邮件会显示"Customer"
 * @param email 邮箱地址
 * @return 异步回调消息 ID： EMSG_SYS_SEND_EMAIL_FOR_CODE = 5043, // 发送邮箱验证码（修改密码、重置密码）
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysSendCodeForEmail(UI_HANDLE hUser, const char *email, int nSeq); // 获取邮箱验证码（修改密码、重置密码）

/**
 * @brief 邮箱获取验证码
 * @details 用户修改/重置密码时使用,邮件会显示username
 * @param email 邮箱地址
 * @param username 用户名称
 * @return 异步回调消息 ID： EMSG_SYS_SEND_EMAIL_FOR_CODE = 5043, // 发送邮箱验证码（修改密码、重置密码）
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysSendCodeForEmailEx(UI_HANDLE hUser, const char *email, const char *username, int nSeq);

/**
 * @brief 修改用户登录密码
 * @param UserName 用户名
 * @param oldPwd 旧密码
 * @param newPwd 新密码
 * @return 异步回调消息 ID： EMSG_SYS_EDIT_PWD_XM = 5013,      // 修改用户登录密码
 *                    param1: >=0 成功，否则失败
 */
int FUN_SysEditPwdXM(UI_HANDLE hUser, const char *UserName, const char *oldPwd, const char *newPwd, int nSeq);

/**
 * @brief 忘记密码
 * @details 在不知道旧密码的情况下修改密码
 * @param phoneOrEmail 接受验证码的手机号码或邮箱地址
 * @return 异步回调消息 ID： EMSG_SYS_FORGET_PWD_XM = 5014,      // 忘记用户登录密码
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysForgetPwdXM(UI_HANDLE hUser, const char *phoneOrEmail, int nSeq);

/**
 * @brief 通过邮箱修改密码
 * @param email 邮箱地址
 * @param newpwd 新密码
 * @return 异步回调消息 ID： EMSG_SYS_PSW_CHANGE_BY_EMAIL = 5045, // 通过邮箱修改密码（重置密码）
 *                    param1: >=0 成功，否则失败
 */
int FUN_SysChangePwdByEmail(UI_HANDLE hUser, const char *email, const char *newpwd, int nSeq);

/**
 * @brief 重置登录密码
 * @param phoneOrEmail 接受验证码的手机号码或邮箱地址
 * @param newPwd 新密码
 * @return 异步回调消息 ID： EMSG_SYS_RESET_PWD_XM = 5016,       // 重置用户登录密码
 *                    param1: >=0 成功，否则失败
 */
int FUN_ResetPwdXM(UI_HANDLE hUser, const char *phoneOrEmail, const char *newPwd, int nSeq);

/** @deprecated 登入 */
int FUN_SysLoginToXM(UI_HANDLE hUser, const char *UserName, const char *pwd, int nSeq);

/**
 * @brief 登出
 * @details 1.当前所有设备链接清除   2.当前登录账户信息清除
 * @return 异步回调消息 ID： EMSG_SYS_LOGOUT = 5047, // 同步退出
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysLogout(UI_HANDLE hUser, int nSeq = 0); //同步退出

/** @deprecated */
int FUN_XMVideoLogin(UI_HANDLE hUser, const char *szUser, const char *szPwd, int nSeq);

/** @deprecated */
int FUN_XMVideoLogout(UI_HANDLE hUser, int nSeq);

//---检验用户账号相关接口---
/** @deprecated */
int FUN_SysSendBindingPhoneCode(UI_HANDLE hUser, const char *phone, const char *userName, const char *pwd, int nSeq = 0);

/** 获取验证码(用于当前账户绑定手机号，替换FUN_SysSendBindingPhoneCode) */
/**
 * @brief 获取手机验证码
 * @details 用于当前账户绑定手机号
 * @param phone 接受验证码的手机号码
 * @return 异步回调消息 ID： EMSG_SYS_SEND_BINDING_PHONE_CODE = 5050, // 绑定安全手机(1)—发送验证码
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int Fun_SysGetVerCodeForBindPhone(UI_HANDLE hUser, const char *szPhone, int nSeq = 0);

/** @deprecated */
int FUN_SysBindingPhone(UI_HANDLE hUser, const char *userName, const char *pwd, const char *phone, const char *code, int nSeq  =0);

/**
 * @brief 当前账户绑定手机号
 * @param phone 绑定的手机号码
 * @param code 验证码
 * @return 异步回调消息 ID： EMSG_SYS_BINDING_PHONE = 5051, // 绑定安全手机(2)—验证code并绑定
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int Fun_SysAccountBindPhone(UI_HANDLE hUser, const char *phone, const char *code, int nSeq = 0);

/** @deprecated */
int FUN_SysSendBindingEmailCode(UI_HANDLE hUser, const char *email, const char *userName, const char *pwd, int nSeq);

/**
 * @brief 获取邮箱验证码
 * @details 用于当前账户绑定邮箱
 * @param szEmail 接受验证码的邮箱地址
 * @param szUserName 用户名
 * @return 异步回调消息 ID： EMSG_SYS_SEND_BINDING_EMAIL_CODE = 5054, // 绑定安全邮箱(1)—发送验证码
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int Fun_SysGetVerCodeForBindEmail(UI_HANDLE hUser, const char *szEmail, const char *szUserName, int nSeq);

/** @deprecated 当前登录账户绑定邮箱，无需重新传用户名、密码 */
int FUN_SysBindingEmail(UI_HANDLE hUser, const char *userName, const char *pwd, const char *email, const char *code, int nSeq);

/**
 * @brief 当前账户绑定邮箱
 * @param szEmail 绑定的邮箱地址
 * @param szVerCode 验证码
 * @return 异步回调消息 ID： EMSG_SYS_BINDING_EMAIL = 5055, // 绑定安全邮箱(2)—验证code并绑定
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int Fun_SysAccountBindEmail(UI_HANDLE hUser, const char *szEmail, const char *szVerCode, int nSeq = 0);

/**
 * @brief 校验邮箱验证码
 * @details 用于校验修改密码，重置密码时接受到的验证码
 * @param email 接收到验证码的邮箱地址
 * @param code 验证码
 * @return 异步回调消息 ID： EMSG_SYS_CHECK_CODE_FOR_EMAIL = 5044,// 验证邮箱验证码（修改密码、重置密码）
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysCheckCodeForEmail(UI_HANDLE hUser, const char *email, const char *code, int nSeq);

/**
 * @brief 验证修改密码的验证码是否正确
 * @details 用于校验修改密码，重置密码时接受到的验证码
 * @param phoneOrEmail 接受到验证码的手机号或邮箱地址
 * @param checkNum 验证码
 * @return 异步回调消息 ID： EMSG_SYS_REST_PWD_CHECK_XM = 5015,  // 验证验证码
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_CheckResetCodeXM(UI_HANDLE hUser, const char *phoneOrEmail, const char *checkNum, int nSeq);

/**
 * @brief 当前登录账号绑定微信账号
 * @param wxLoginCode 微信登录Code
 * @return 异步回调消息：id: = EMSG_SYS_ACCOUNT_BINDWX = 8932,    ///< 当前账号绑定微信
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysBindWXAccount(UI_HANDLE hUser, const char *wxLoginCode, int nSeq);

/**
 * @brief 当前登录账号解绑微信账号
 * @return 异步回调消息：id: = EMSG_SYS_ACCOUNT_UNBINDWX = 8933,    ///< 当前账号解绑微信
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysUnBindWXAccount(UI_HANDLE hUser, int nSeq);

/** @deprecated */
int FUN_CheckPwdStrength(UI_HANDLE hUser, const char *newPwd, int nSeq);

/**
 * @brief 检测用户名是否已被注册
 * @param userName 用户名
 * @return 异步回调消息：id: = EMSG_SYS_CHECK_USER_REGISTE = 5046, // 检测用户名是否已注册
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysCheckUserRegiste(UI_HANDLE hUser, const char *userName, int nSeq =0);

/**
 * @brief 检测手机号是否已被注册
 * @param phone 手机号
 * @return 异步回调消息：id: = EMSG_SYS_CHECK_USER_PHONE = 8501, // 检测手机号是否已注册
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
FUN_HANDLE FUN_CheckUserPhone(UI_HANDLE hUser, const char *phone, int nSeq);

/**
 * @brief 检测邮箱是否已被注册
 * @param mail 邮箱地址
 * @return 异步回调消息：id: = EMSG_SYS_CHECK_USER_MAIL = 8502, // 检测邮箱是否已注册
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
FUN_HANDLE FUN_CheckUserMail(UI_HANDLE hUser, const char *mail, int nSeq);

//---用户信息相关接口---
/**
 * @brief 获取用户信息
 * @details 获取当前账户信息userName pwd不需要传，否者需要传
 * @param userName 用户名
 * @param pwd 密码
 * @return 异步回调消息：id: = EMSG_SYS_GET_USER_INFO = 5049, // 获取用户信息
 *                    param1: >=0 成功，否则失败
 *                    str: 服务器返回内容
 */
int FUN_SysGetUerInfo(UI_HANDLE hUser, const char *userName, const char *pwd, int nSeq = 0);

//---其他---
/** @deprecated */
int FUN_SysCheckDeviceReal(UI_HANDLE hUser, const char *twoDimensionCode, int nSeq = 0);//检测产品是否为正品

//---设备列表相关接口---
/**
 * @brief 通过文件添加设备
 * @details 本地登陆使用
 * @param szPath 文件路径
 * @return 异步回调消息：id: = EMSG_SYS_ADD_DEV_BY_FILE = 5060,            //通过文件添加设备-本地登陆使用
 *                    param1: >=0 成功，否则失败
 */
int Fun_SysAddDevByFile(UI_HANDLE hUser, const char *szPath, int nSeq = 0); //通过文件添加设备-本地登陆使用

/**
 * @brief 云账户登录
 * @details 获取当前账户信息userName pwd不需要传，否者需要传
 * @param szUserName 用户名
 * @param szPassword 密码
 * @return 异步回调消息：id: = EMSG_SYS_CLOUD_ACCOUNT_LOGTIN = 5207, ///< 云账户登录
 *                    param1: >=0 成功，否则失败
 *                    str: 账户系统AccessToken
 */
int FUN_SysCloudAccountLogin(UI_HANDLE hUser, const char *szUserName, const char *szPassword, int nSeq = 0);

/**
 * @brief 第三方账户登录
 * @details 获取当前账户信息userName pwd不需要传，否者需要传
 * @param szUnionId  唯一ID
 * @param szType 第三方类型(例:微信“wx_xx”，Google“gg_xx”，Facebook“fb_xx”，line是“line_xx”  xx是username，暂时未使用，可以传任意字符串 *区分大小写)
 * @return 异步回调消息：id: = EMSG_SYS_THIRD_PARTY_ACCOUNT_LOGTIN = 5208, ///< 第三方登录
 *                    param1: >=0 成功，否则失败
 *                    str: 账户系统AccessToken
 */
int FUN_SysThirdPartyAccountLogin(UI_HANDLE hUser, const char *szUnionId, const char *szType, int nSeq = 0);

/**
 * @brief 手机短信登录
 * @details 通过FUN_SysGetLoginAccountCode接口获取短信验证码
 * @param szPhone 手机号
 * @param szCheckCode 验证码
 * @return 异步回调消息：id: = EMSG_SYS_PHONE_SMS_LOGTIN = 5209, ///< 手机短信登录
 *                    param1: >=0 成功，否则失败
 *                    str: 账户系统AccessToken
 */
int FUN_SysPhoneSMSLogin(UI_HANDLE hUser, const char *szPhone, const char *szCheckCode, int nSeq = 0);

/**
 * @brief 获取用户设备列表
 * @param szUser 用户名
 * @param szPwd 密码
 * @return 异步回调消息：id: = EMSG_SYS_GET_DEV_INFO_BY_USER = 5000, // 获取设备信息
 *                    param1: >=0 设备数量，否则失败
 *                    pData: SDBDeviceInfo(*设备数量param1)结构体字节流
 *                    str: 组成的信息-->name=%s;uaes=%s;paes=%s;sysUserName=%s;
 *
 */
int FUN_SysGetDevList(UI_HANDLE hUser, const char *szUser, const char *szPwd, int nSeq = 0); //获取用户设备信息

/**
 * @brief 获取当前账户下设备列表
 * @details 需要登录账户后调用
 * @return  异步回调消息：id:EMSG_SYS_GET_CURRENT_USER_DEV_LIST = 5093,//获取当前用户设备列表
 *                     param1:>=0 代表账户下设备数量，否则失败
 *                     pData：SDBDeviceInfo(*设备数量param1)结构体字节流
 *                     Str：组成的信息-->name=%s;uaes=%s;paes=%s;sysUserName=%s;
 */
int FUN_SysGetCurrentUserDevList(UI_HANDLE hUser,int nSeq);//仅获取设备列表

/**
 * @brief 通过短信验证码获取设备列表
 * @param phoneOrEmail 接收验证码的手机号或邮箱地址
 * @param nCheckCode 验证码
 * @param nApptype app类型，暂时未使用
 * @return  异步回调消息：id:EMSG_SYS_GET_CURRENT_USER_DEV_LIST = 5093,//获取当前用户设备列表
 *                     param1:>=0 代表账户下设备数量，否则失败
 *                     pData：SDBDeviceInfo(*设备数量param1)结构体字节流
 *                     Str：组成的信息-->name=%s;uaes=%s;paes=%s;sysUserName=%s;
 */
int FUN_SysSmsGetDevList(UI_HANDLE hUser, const char *phoneOrEmail, const char *nCheckCode, int nApptype, int nSeq = 0);

/**
 * @brief 获取验证码
 * @details 短信登陆使用
 * @param phoneOrEmail 接收验证码的手机号或者邮箱
 * @return  异步回调消息：id:EMSG_SYS_GET_LOGIN_ACCOUNT_CODE = 5076,		  // 获取登陆账户验证码
 *                     param1:>=0 代表账户下设备数据，否则失败
 */
int FUN_SysGetLoginAccountCode(UI_HANDLE hUser, const char *phoneOrEmail, int nSeq = 0);

/**
 * @brief 第三方获取列表接口（微信、QQ、微博、Facebook、Google等）
 * @param unionId 唯一ID
 * @param szType 第三方类型(例:微信“wx”， Google“gg_xx”，Facebook“fb_xx”，line是“line_xx” xx 是username，暂时未使用，可以传任意字符串 *区分大小写)
 * @param nApptype app类型，暂时未使用
 * @return  异步回调消息：id:EMSG_SYS_GET_DEV_INFO_BY_USER = 5000, // 获取设备信息
 *                     param1:>=0 代表账户下设备数量，否则失败
 *                     pData：SDBDeviceInfo(*设备数量param1)结构体字节流
 *                     Str：组成的信息-->name=%s;uaes=%s;paes=%s;sysUserName=%s;
 */
int FUN_SysGetDevListEx(UI_HANDLE hUser, const char *unionId, const char *szType, int nApptype, int nSeq = 0);

/**
 * @brief 本机号码一键登录并获取设备列表
 * @detail 上层传入Token进行登录操作
 * @param hUser 消息接收对象
 * @param szAppToken 登录用令牌，需上层传入
 * @param szAppID 登录用应用程序id，需上层传入
 * @param nSeq 自定义值
 * @return 异步返回消息ID：EMSG_SYS_LOCAL_PHONE_LOGIN = 5212,    ///< 本机号码一键登录并获取设备列表
 *                param1: >=0 成功，否则失败
 */
int Fun_LoginByLocalPhoneNumber(UI_HANDLE hUser, const char* szAppToken,const char* szAppID, int nSeq = 0);

/**
 * @brief 添加设备
 * @param pDevInfo SDBDeviceInfo设备信息
 * @param szExInfo 格式 param1=value1&param2=value2 <p>
 *                 “ma=true&delOth=true”设置此帐户为此设备的主帐户，且其他的设备列表下删除此设备<p>
 *                 “ext=XXXXXXXX”设置设备的用户自定义信息 	 例如：设置第三方设备"ext=DevType_DH";
 *                 “cryNum=XXXXXXXX”特征码(弱绑定授权码)
 * @param szExInfo2 设备token信息 示例：{"AdminToken":"M6NymdA1qfOCXmqXXZ4sF9Qje3RRKkVRF3pbzyKfFUk="}
 * @return  异步回调消息：id:EMSG_SYS_ADD_DEVICE = 5004,
 *                     param1:>=0 代表账户下设备数量，否则失败
 *                     pData:SDBDeviceInfo设备信息
 *                     Str:结果信息(JSON格式)
 */
int FUN_SysAdd_Device(UI_HANDLE hUser, SDBDeviceInfo *pDevInfo, const char *szExInfo = "", const char *szExInfo2 = "", int nSeq = 0);

//设备是否开启微信报警推送  *有缺陷，废除（微信报警状态会改变的，打开/关闭），使用 FUN_SysWXAlarmStateCheck每次去服务器查询
/** @deprecated */
int FUN_SysDevWXPMS(const char *szDeviceSN);

/**
 * @brief 登录帐户是否是主帐户
 * @param szDeviceSN 设备序列号
 * @return  1表示当前登录账户是该设备的主账户，0则表示不是
 */
int FUN_SysDevIsMasterAccount(const char *szDeviceSN);

/**
 * @brief 获取设备的备注信息
 * @param szDeviceSN 设备序列号
 * @param comment 用于获取设备备注信息
 * @return  0表示成功获取设备备注信息,否则失败
 */
int FUN_SysGetDevComment(const char *szDeviceSN, char comment[512]);

/**
 * @brief 按字段获取设备信息
 * @detail 1.获取设备信息通用接口，后面增加新字段的话，也不要再更改SDK了。。
*          2.IOS使用此接口，Android使用JNI层提供的接口，参数不一样。。
 * @param szDevId 设备序列号 或 ip+port
 * @param szField json字段
 * @param szValue 输出的信息
 * @param nMaxSize 设备信息最大拷贝长度
 * @return 返回的数据长度
 */
int Fun_SysGetDevInfoByField(const char *szDevId, const char *szField, char *szValue, int nMaxSize);

/**
 * @brief 修改缓存设备信息
 * @detail 修改缓存设备信息，不会影响服务器端存储的设备信息，下次获取设备列表的时候修改的缓存信息作废。为了兼容客户端添加，删除设备时，未重新获取设备列表刷新数据。
 * @param szDevId 设备序列号 或 ip+port
 * @param nSystemTime 设备添加的系统时间
 * @param nNumberOfSharedAccounts 分享账户数量
 * @param nOptionType 操作类型  0：添加 1：修改 2：删除 对应枚举 E_SYS_MODIFY_DEV_INFO
 * @param szExJson nOptionType == 0 || nOptionType == 1时生效，如果需要添加，修改其他的字段信息，通过此json传递，
*          必须是 {"Name" : xxxx(string || int || ...)}]
 * @return 0表示成功，否则失败
 */
int Fun_SysModifyCacheDevInfo(const char *szDevId, uint64_t nSystemTime, int nNumberOfSharedAccounts, int nOptionType, const char *szExJson = "");

/**
 * @brief 修改用户设备信息
 * @param SDBDeviceInfo SDBDeviceInfo设备信息
 * @param UserName 用户名
 * @param Psw 设备密码
 * @return  异步回调消息：id:EMSG_SYS_CHANGEDEVINFO = 5005,  // 修改用户设备信息
 *                     param1:>=0 成功，否则失败
 *                     pData:SDBDeviceInfo设备信息
 */
int FUN_SysChangeDevInfo(UI_HANDLE hUser, struct SDBDeviceInfo *ChangeDevInfor, const char *UserName,const char *Psw, int nSeq = 0);

/**
 * @brief 获取设备登录令牌信息
 * @param szDevIDs 设备序列号，多个设备序列号用“,”分割
 * @return 异步回调消息 消息ID：EMSG_SYS_GET_DEV_ENC_TOKEN_FORM_RS = 5094, ///< 获取设备登录令牌信息;
 *                       param1: >=0 成功，否则失败
 *                       Str:结果信息(JSON格式)
 */
int Fun_SysGetDevEncToken(UI_HANDLE hUser, const char *szDevIDs, int nSeq = 0);

/** @deprecated */
int FUN_SysDelete_Dev(UI_HANDLE hUser, const char *Delete_DevMac,const char *UserName,const char *Psw, int nSeq = 0);            //删除设备

/** 删除设备 替代FUN_SysDelete_Dev */
/**
 * @brief 删除设备
 * @param szDelDevID 设备序列号
 * @return 异步回调消息 消息ID：EMSG_SYS_DELETE_DEV = 5006,        // 删除设备
 *                       param1: >=0 成功，否则失败
 *                       Str:结果信息(JSON格式)
 */
int Fun_SysDeleteDevice(UI_HANDLE hUser, const char *szDelDevID, int nSeq = 0);

/**
 * @brief 批量删除设备
 * @param szDevIDs 设备序列号，多个设备序列号用“；”分割
 * @return  异步返回消息ID： EMSG_SYS_BATCH_DELETE_DEVS = 5211, ///< 批量删除设备;
 *                param1: >=0 成功，否则失败
 */
int Fun_SysBatchDeleteDevices(UI_HANDLE hUser, const char *szDelDevIDs, int nSeq = 0);

/** @deprecated 废弃，使用FUN_SysChangeDevInfo接口代替*/
int FUN_SysChangeDevLoginPWD(UI_HANDLE hUser, const char *uuid, const char *oldpwd, const char *newpwd, const char *repwd, int nSeq = 0);// 修改设备密码(服务器端)

/**
 * @brief 获取设备状态
 * @param devId 设备序列号，多个设备序列号用“；”分割
 * @return  异步返回消息ID： EMSG_SYS_GET_DEV_STATE = 5009,        // 获取设备状态
 *                param1: >=0 成功，否则失败
 */
int FUN_SysGetDevState(UI_HANDLE hUser, const char *devId, int nSeq = 0);

/**
 * @brief 分类型获取设备状态
 * @detail 会去服务器查询设备状态，查询结果每一个设备单独返回
 * @param sDevIds 设备序列号/ip 多个设备使用";"分隔
 * @param nQueryType 查询类型，详见枚举EDevStatusType
 * @return  异步返回消息ID： EMSG_SYS_GET_DEV_STATE = 5009,        // 获取设备状态
 *                    param1: >=0 成功，否则失败
 *                    Str():设备序列号
 */
int FUN_SysGetDevStateByType(UI_HANDLE hUser, const char *sDevIds, int nQueryType, int nSeq = 0);

/**
 * @brief 获取批量设备状态
 * @details 1.去服务器查询，每个设备单独返回状态查询结果
            2.可完全替代FUN_SysGetDevState(nQueryTypeMask传-1)、FUN_SysGetDevStateByType(示例：要查询RPS状态 nQueryTypeMask传E_DevStatus_RPS)
 * @param szDevIDs 设备ID，多个设备间使用";"分隔
 * @param nQueryTypeMask 查询类型掩码值，二进制位值详见@enum EDevStatusType，-1根据当前设备类型获取相关状态  ps:示例：((1 << E_DevStatus_RPS) | (1 << E_DevStatus_DSS))
 * @return 异步回调消息：id:EMSG_SYS_GET_DEV_STATE = 5009,        // 获取设备状态
 *                    param1:状态结果掩码值，二进制位值0不在线，1在线，详见枚举EDevStatusType,
 *                    Str:设备序列号
 */
int FUN_SysBatchGetDevsStatus(UI_HANDLE hUser, const char *szDevIDs, int nQueryTypeMask, int nSeq = 0);

/**
 * @brief 批量查询多个设备多个服务状态
 * @details 仅支持序列号查询
 * @param szDevIDs 设备序列号，多个设备间使用";"分隔
 * @param nQueryTypeMask 查询类型掩码值，SDK内部不会有默认查询类型，二进制位值详见枚举 EDevStatusType  ps:示例：((1 << E_DevStatus_RPS) | (1 << E_DevStatus_DSS))
 * @return 异步回调消息：id:EMSG_SYS_QUERY_DEVS_STATUS = 5210, ///< 批量查询多个设备多个服务状态
 *                    param1:==0成功，否则失败，
 *                    param2：查询类型掩码值,
 *                    Str:设备序列号
 *                    pData:结果信息
 */
int Fun_SysQueryDevsStatusV2(UI_HANDLE hUser, const char *szDevIDs, int nQueryTypeMask, int nTimeout = 8000, int nSeq = 0);

/**
 * @brief 添加设备状态变化监听
 */
int FUN_SysAddDevStateListener(UI_HANDLE hUser);

/**
 * @brief 移除设备状态变化监听
 */
int FUN_SysRemoveDevStateListener(UI_HANDLE hUser);

int FUN_SysGetDevLog(UI_HANDLE hUser, const char *ip, int nSeq = 0); //未实现？

/**
 * @brief 用户账号绑定（第三方登陆后）
 * @details name，pwd不为空时，绑定现有的帐户和密码
                     为空时，自动生成一个用户名和密码
 * @param name 用户名
 * @param pwd 密码
 * @return 异步回调消息：id:EMSG_SYS_BINDING_ACCOUNT = 8504
 *                    param1:>=0成功，否则失败，
 *                    Str:用户名密码字段，形如 "uname=%s;upwd=%s;"
 */
int FUN_SysBindingAccount(UI_HANDLE hUser, const char *name, const char *pwd, int nSeq = 0);

/**
 * @brief 第三方绑定用户（微信、QQ、微博、Facebook、Google等）
 * @details 获取第三方登陆uname upass，然后与用户进行绑定, 用户名密码需上层传递，和SDK内部缓存的当前登录用户名密码无关联
 * @param name 用户名
 * @param pwd 密码
 * @param szUnionId 唯一ID
 * @param szType 绑定的第三方类型(例:微信“wx”， Google“gg_xx”，Facebook“fb_xx” xx 是username，暂时未使用，可以传任意字符串 *区分大小写
 * @param nApptype app类型
 * @return 异步回调消息：id:EMSG_SYS_THIRD_PARTY_BINDING_ACCOUNT = 5079,  // 第三方绑定账户
 *                    param1:>=0成功，否则失败，
 *                    Str: 第三方绑定结果信息
 *                    pData：第三方登录信息
 */
int FUN_SysThirdPartyBindAccount(UI_HANDLE hUser, const char *szUserName, const char *szUserPwd, const char *szUnionId, const char *szType, int nApptype, int nSeq = 0);

/**
 * @brief 获取支持手机验证的全球区号
 * @details 获取全球哪些国家支持手机短信验证
 * @return 异步回调消息：id:EMSG_SYS_GET_PHONE_SUPPORT_AREA_CODE = 5081,  // 获取支持手机验证的全球区号
 *                    param1:>=0成功，否则失败，
 *                    str：返回的json信息
 */
int FUN_SysGetPhoneSupportAreaCode(UI_HANDLE hUser, int nSeq = 0);

/**
 * @brief 获取支持手机验证的全球区号和区域URL
 * @return 异步回调消息：id:EMSG_SYS_GET_PHONE_SUPPORT_AREA_CODE_AND_URL = 5206,  ///< 获取支持手机验证的全球区号和区域URL
 *                    param1: >=0 成功，否则失败,
 *                    Str:服务器返回结果信息
 */
int FUN_SysGetPhoneSupportAreaCodeAndUrl(UI_HANDLE hUser, int nSeq = 0);

/**
 * @brief 全球区域手机短信验证
 * @details 全球国家区域的手机短信验证：支持多种类型的短信验证
 * @param szPhone 手机号码
 * @param szType 发送验证码功能类型 re:注册  fp:找回密码 login:登陆 bin:绑定 ucan：注销
 * @return 异步回调消息：id:EMSG_SYS_SEND_GLOBAL_PHONE_CODE = 5082, // 全球国家区域手机短信验证
 *                    param1:>=0成功，否则失败，
 *                    str：返回的type，就是传的参数szType，用来区分哪种类型返回的结果
 *                    pData：找回密码的时候返回当前手机号绑定的用户名，其他类型不返回
 */
int FUN_SysSendGlobalPhoneCode(UI_HANDLE hUser, const char *szPhone, const char *szType, int nSeq = 0);

/**
 * @brief 开启微信报警监听
 * @param szDeviceSN 设备序列号
 * @return 异步回调消息：id:EMSG_SYS_WX_ALARM_LISTEN_OPEN = 5064,         // 开启微信报警监听
 *                    param1:>=0成功，否则失败，
 *                    Str:服务器返回结果信息
 */
int FUN_SysOpenWXAlarmListen(UI_HANDLE hUser, const char *szDeviceSN, int nSeq = 0);

/**
 * @brief 关闭微信报警监听
 * @param szDeviceSN 设备序列号
 * @return 异步回调消息：id:EMSG_SYS_WX_ALARM_LISTEN_CLOSE = 5065,        // 关闭微信报警监听
 *                    param1:>=0成功，否则失败，
 *                    Str:服务器返回结果信息
 */
int FUN_SysCloseWXAlarmListen(UI_HANDLE hUser, const char *szDeviceSN, int nSeq = 0);

/**
 * @brief 开启微信报警监听
 * @param szDeviceSN 设备序列号
 * @return 异步回调消息：id:EMSG_SYS_WX_ALARM_WXPMSCHECK = 5066,          // 微信报警状态查询
 *                    param1:>=0成功，否则失败，
 *                    Str:服务器返回结果信息
 */
int FUN_SysWXAlarmStateCheck(UI_HANDLE hUser, const char *szDeviceSN, int nSeq = 0);

/**
 * @brief 第三方登录报警订阅监听开启
 * @details 第三方登录报警订阅
 * @param szDeviceSN 设备序列号，不支持ip：port
 * @param sThirdPartyType 第三方登录类型，例如"line"/"wx"等
 * @return 异步回调消息：id:EMSG_SYS_THIRD_PARTY_ALARM_LISTEN_OPEN = 5083,         // 开启第三方报警监听
 *                    param1:>=0成功，否则失败，
 *                    str：结果信息
 */
int FUN_SysThirdPartyOpenAlarmListen(UI_HANDLE hUser, const char *szDeviceSN, const char *sThirdPartyType, int nSeq = 0);

/**
 * @brief 第三方登录报警订阅监听关闭
 * @details 第三方登录报警取消订阅
 * @param szDeviceSN 设备序列号，不支持ip：port
 * @param sThirdPartyType 第三方登录类型，例如"line"/"wx"等
 * @return 异步回调消息：id:EMSG_SYS_THIRD_PARTY_ALARM_LISTEN_CLOSE = 5084,        // 关闭第三方报警监听
 *                    param1:>=0成功，否则失败，
 *                    str：结果信息
 */
int FUN_SysThirdPartyCloseAlarmListen(UI_HANDLE hUser, const char *szDeviceSN, const char *sThirdPartyType, int nSeq = 0);

/**
 * @brief 第三方登录报警订阅监听状态查询
 * @details 第三方登录报警订阅信息查询
 * @param szDeviceSN 设备序列号，不支持ip：port
 * @param sThirdPartyType 第三方登录类型，例如"line"/"wx"等
 * @return 异步回调消息：id:EMSG_SYS_THIRD_PARTY_ALARM_STATE_CHECK = 5085,          // 第三方报警状态查询
 *                    param1:>=0成功，否则失败，
 *                    str：结果信息
 */
int FUN_SysThirdPartyAlarmStateCheck(UI_HANDLE hUser, const char *szDeviceSN, const char *sThirdPartyType, int nSeq = 0);

/**
 * @brief 保存APP信息
 * @param szAppInfo APP相关信息
 * @param nExpireTime APP相关信息的过期时间，默认30分钟过期，单位毫秒
 * @return 异步回调消息：id:EMSG_SYS_APP_INFO_SAVE = 5203, ///< 保存APP相关信息
 *                     param1: >=0 成功，否则失败,
 *                     Str:服务器返回结果信息
 */
int Fun_SysAppInfoSave(UI_HANDLE hUser, const char *szAppInfo, int nExpireTime, int nSeq = 0);

/**
 * @brief 获取APP信息
 * @param szFindKey Fun_SysAPPInfoSave接口返回的Key
 * @return 异步回调消息：id:EMSG_SYS_APP_INFO_QUERY = 5204, ///< 获取APP相关信息
 *                     param1: >=0 成功，否则失败,
 *                     Str:服务器返回结果信息
 */
int Fun_SysAppInfoQuery(UI_HANDLE hUser, const char *szFindKey, int nSeq = 0);

/** @deprecated */
// *废弃不使用，使用caps服务查询 接口：Fun_SysGetDevAbilitySetFromServer
// EMSG_SYS_CHECK_CS_STATUS     = 5067,        // 实时从服务器上查询云存储状态
// szDevices需要查询设备序列号，多个设备用","号分隔
int Fun_SysGetDevsCSStatus(UI_HANDLE hUser, const char *szDevices, int nSeq);

/**
 * @brief 获取设备所在的账户信息
 * @param szDevice 设备序列号
 * @return 异步回调消息：id:EMSG_SYS_DULIST = 5068,                   // 获取设备所在的帐户信息
 *                     param1: >=0 成功，否则失败,
 *                     Str:服务器返回结果信息
 */
int Fun_SysGetDevUserInfo(UI_HANDLE hUser, const char *szDevice, int nSeq);

/**
 * @brief 指定设备的主帐户
 * @param szDevice 设备序列号
 * @param szMAUserId 指定主账户userID
 * @return 异步回调消息：id:EMSG_SYS_MDSETMA = 5069,                   // 指定设备的主帐户
 *                     param1: >=0 成功，否则失败,
 *                     Str:服务器返回结果信息
 */
int Fun_SysSetDevMasterAccount(UI_HANDLE hUser, const char *szDevice,  const char *szMAUserId, int nSeq);

/**
 * @brief 修改登录用户名
 * @details 只能修改微信等绑定帐户自动生成
 * @param szNewUserName 新用户名
 * @return 异步回调消息：id:EMSG_SYS_MODIFY_USERNAME = 5070,              // 修改登录用户名（只能修改微信等绑定帐户自动生成）
 *                     param1: >=0 成功，否则失败,
 */
int Fun_SysModifyUserName(UI_HANDLE hUser, const char *szNewUserName, int nSeq);

/**
 * @brief 从服务器端更新当前账号是否为该设备的主账号
 * @param szDevice 序列号
 * @return 异步回调消息：id:EMSG_SYS_IS_MASTERMA = 5072,                  // 获取当前账号是否为该设备的主账号
 *                     param1: >=0 成功，否则失败,
 *                     Str:服务器返回结果信息
 */
int Fun_SysIsDevMasterAccountFromServer(UI_HANDLE hUser, const char *szDevice, int nSeq);

// 接口废弃，使用Fun_SysGetDevCapabilitySet代替
// EMSG_SYS_GET_ABILITY_SET = 5073
// 从服务器获取设备的能力集 *只返回"caps"对象给请求端
int Fun_SysGetDevAbilitySetFromServer(UI_HANDLE hUser,const char *szDevSysInfo, int nSeq);

/**
 * @brief 从服务器获取设备的能力集
 * @details 从服务器获取设备的能力集,返回服务器下发的整个json对象给请求端，为了兼容旧版本，新增的接口，后续APP兼容后完全替代Fun_SysIsDevMasterAccountFromServer接口
 * @param szDevSysInfo 请求的整个json字段(请求端自行组装)
 * @return 异步回调消息：id:EMSG_SYS_GET_DEV_CAPABILITY_SET = 5089, // 获取设备能力集  用来替代EMSG_SYS_GET_ABILITY_SET
 *                     param1: >=0 成功，否则失败
 *                     Str：服务器返回的结果信息
 *                     pData: 设备序列号
 */
int Fun_SysGetDevCapabilitySet(UI_HANDLE hUser,const char *szDevSysInfo, int nSeq);

/**
 * @brief 批量获取设备能力级
 * @details 1.如果查询超过20个设备，尽量分批次查询 2.参考链接：wiki：http://10.2.11.100/pages/viewpage.action?pageId=25902177
 * @param szDevsSysInfo 客户端自行组装批量查询的JSON
 * @return 异步回调消息：消息ID：EMSG_SYS_BATCH_GET_DEV_CAPABILITY_SET = 5092, //  批量获取设备能力集
 *                     param1: >=0 成功，否则失败
 *                     Str:结果信息(JSON格式)
 */
int Fun_SysBatchGetDevCapabilitySet(UI_HANDLE hUser, const char *szDevsSysInfo, int nSeq);

/**
 * @brief 在服务器端验证设备校验码是否合法
 * @param szDevId 设备序列号
 * @param szDevCode 设备校验码
 * @return 异步回调消息：消息ID：EMSG_SYS_CHECK_DEV_VALIDITY = 5074,           // 在服务器端验证设备校验码合法性
 *                     param1: >=0 成功，否则失败
 *                     Str:结果信息(JSON格式)
 *                     data：返回设备信息字节流
 */
int Fun_SysCheckDevValidityFromServer(UI_HANDLE hUser,const char *szDevId,const char *szDevCode, int nSeq);

/**
 * @brief 用户解除微信绑定
 * @return 异步回调消息：消息ID：EMSG_SYS_USER_WX_UNBIND = 5078, 			  // 微信用户解除绑定
 *                     param1: >=0 成功，否则失败
 *                     Str:结果信息(JSON格式)
 */
int FUN_SysUserWXUnbind(UI_HANDLE hUser, int nSeq = 0);

/**
 * @brief 发送链接邮件用于注册用户
 * @param szEmail 邮箱
 * @param szPassword 账户密码
 * @return 异步回调消息：id:EMSG_SYS_SEND_EMAIL_LINK_TO_REGISTER_USER = 5097, ///< 发送链接邮件用于注册用户
 *                    param1: >=0 成功，否则失败,
 *                    Str:UserId信息
 */
int Fun_SysSendEmailLinkToRegisterUser(UI_HANDLE hUser, const char *szEmail, const char *szPassword, int nSeq = 0);

/**
 * @brief 检测用户是否已激活
 * @param szUserID 用户ID
 * @return 异步回调消息：id:EMSG_SYS_CHECK_USER_IS_ACTIVATED = 5099, ///< 检测用户是否已激活
 *                    param1: >=0 成功, -604056表示未激活
 */
int Fun_SysCheckUserIsActivated(UI_HANDLE hUser, const char *szUserID, int nSeq = 0);

/**
 * @brief 发送链接邮件用于重置密码
 * @param szEmail 邮箱
 * @return 异步回调消息：id:EMSG_SYS_SEND_EMAIL_LINK_TO_RESET_PASSWORD = 5201, ///< 发送链接邮件用于重置密码
 *                    param1: >=0 成功，否则失败,
 *                    Str: 结果信息
 */
int Fun_SysSendEmailLinkToResetPassword(UI_HANDLE hUser, const char *szEmail, int nSeq = 0);

/**
 * @brief 检测邮箱重置密码链接是否激活
 * @param szUserID 用户ID
 * @return 异步回调消息：id:EMSG_SYS_CHECK_RESET_PASSWORD_IS_ACTIVATED = 5202, ///< 检测邮箱重置密码链接是否激活
 *                    param1: >=0 成功, -604027表示用户找回密码失败 -604065表示用户未找回密码，app端应继续监听；-604028表示用户找回密码链接过期
 *                    Str: 结果信息
 */
int Fun_SysCheckResetPasswordIsActivated(UI_HANDLE hUser, const char *szUserID, int nSeq = 0);

/**
 * @brief 修改云账户昵称
 * @param szNickname 账户昵称
 * @return 异步回调消息：id:EMSG_SYS_MODIFY_ACCOUNT_NICKNAME = 5205, ///< 修改云账户昵称
 *                    param1: >=0 成功, -604027表示用户找回密码失败 -604065表示用户未找回密码，app端应继续监听；-604028表示用户找回密码链接过期
 *                    Str: 结果信息
 */
int Fun_SysModifyAccountNickname(UI_HANDLE, const char *szNickname, int nSeq = 0);

/**
 * @brief 获取开放平台签名算法信息
 * @details 同步接口，返回JSON格式数据
 * @param[out] szOutSignInfo 返回的签名相关的信息，包含时间、签名、AES密钥
 * @param nMaxStrSize  szOutSignInfo的最大长度限制
 * @example {"time_millis":"00000631716796478433","signature":"c81920f6486d5f3166196b24b3127676","aes_key":"6796478433f1227a"}
 */
int Fun_SysGetOpenPlatformSignAlgorithmInfo(char *szOutSignInfo, int nMaxStrSize);

/**
 * @brief 影子服务器获取设备配置
 * @details 1.建议使用Fun_GetDevCfgsFromShadowService
 *          2.接口支持单个/多个配置同时获取，SDK内部会缓存到内存当中，重启APP则清空。   // Dev--->CfgName  CfgName--->CfgJson
 * @param sDeviceSN 设备序列号，不支持ip+port方式
 * @param sRequestJsons 请求的配置json数组，支持多个配置同时获取<p>
 * 示例：Json数组：["SofiaWare:0", "Channel:-1"]  、 Json对象："ConfigList": ["SofiaWare:0", "Channel:-1"] ，建议使用第一种<p>
 *      配置格式：ConfigName:LastTime  *LastTime--> 0：直接从服务器获取最新的一次配置， -1：从本地缓存中获取lasttime，没有获取过配置(本地缓存空)则填写为0，否者是上次获取配置的时间
 * @param nTimeout 超时时间
 * @return 异步回调消息：id:EMSG_SYS_GET_CFGS_FROM_SHADOW_SERVER = 5087, // 通过影子服务器批量获取配置
 *                    param1: >=0 成功，否则失败,
 *                    Str:设备序列号
 *                    pData：服务器返回结果信息
 */
int FUN_SysGetCfgsFormShadowServer(UI_HANDLE hUser, const char *sDeviceSN, const char *sRequestJsons, int nTimeout = 5000, int nSeq = 0);

/**
 * @brief 影子服务设备配置状态监听
 * @details 1.建议使用Fun_AddShadowServiceListener
 *          2.定时查询功能，查询结果有变化通知上层，接口支持单个/多个配置同时监听
 * @param sDeviceSN 设备序列号，不支持ip+port方式
 * @param sCfgNames 监听的配置名，SofiaWare;Channel ';'分隔
 * @return 异步回调消息：id:EMSG_SHADOW_SERVICE_START_DEV_LISTENING = 8803, ///< 开始设备影子服务监听
 *                    param1: >=0 成功，否则失败,
 *                    Str:设备序列号
 *                    pData：配置状态变化结果，json格式与查询接口FUN_SysGetCfgsFormShadowServer一致
 */
int FUN_SysAddShadowServerListener(UI_HANDLE hUser, const char *sDeviceSN, const char *sCfgNames);

/**
 * @brief 移除影子服务设备配置监听
 * @details 建议使用Fun_RemoveShadowServiceListener
 * @param sDeviceSN 设备序列号
 */
int FUN_SysRemoveShadowServerListener(const char *sDeviceSN);

/**
 * @brief 影子服务器获取设备配置
 * @details 接口支持单个/多个配置同时获取，SDK内部会缓存到内存当中，重启APP则清空。   // Dev--->CfgName  CfgName--->CfgJson
 * @param szDeviceSN 设备序列号，不支持ip+port方式
 * @param szCfgsJson 请求的配置json数组，支持多个配置同时获取<p>
 * 示例：<p>
 * {<p>
 *      "msg" : "getcfg",<p>
 *      "cfglist" : ["SofiaWare", "Channel"]<p>
 * }<p>
 * @param nTimeout 超时时间
 * @return 异步回调消息：id:EMSG_SHADOW_SERVICE_GET_DEV_CONFIGS = 8800, ///< 获取设备配置
 *                    param1: >=0 成功，否则失败,
 *                    Str:设备序列号
 *                    pData：服务器返回结果信息
 */
int Fun_GetDevCfgsFromShadowService(UI_HANDLE hUser, const char *szDeviceSN, const char *szCfgsJson, int nTimeout = 5000, int nSeq = 0);

/**
 * @brief 设置设备离线配置到影子服务
 * @param szDeviceSN 设备序列号，不支持ip+port方式
 * @param szCfgsJson 设备配置信息<p>
 * 示例：<p>
 * {<p>
 *      "msg" : "setcfg",<p>
 *      "cfglist" : <p>
 *      {<p>
 *			"cpu":60,<p>
 *      	"mem":60,<p>
 *		}<p>
 * }<p>
 * @return 异步回调消息：id:EMSG_SHADOW_SERVICE_SET_DEV_OFFLINE_CFGS = 8801, ///< 设置设备离线配置
 *                    param1: >=0 成功，否则失败,
 *                    Str:设备序列号
 *                    pData：结果信息
 */
int Fun_SetDevOffLineCfgsToShadowService(UI_HANDLE hUser, const char *szDeviceSN, const char *szCfgsJson, int nTimeout = 5000, int nSeq = 0);

/**
 * @brief 影子服务设备配置状态监听
 * @details WebSocket主动上报，只对设备订阅，不支持单独配置订阅
 * @param szDeviceSNs 设备序列号，多个以;分隔，不支持ip+port方式
 * @return 1.异步回调消息：开启监听结果：id:EMSG_SHADOW_SERVICE_START_DEV_LISTENING = 8803, ///< 开始设备影子服务监听
 *                                  param1: >=0 成功，否者失败,
 *                                  Str:设备序列号
 *                                  pData：结果信息
 *         2.异步回调消息：配置状态变化结果通知： id:EMSG_SHADOW_SERVICE_DEV_CONFIGS_CHANGE_NOTIFY = 8802, ///< 设备配置变化通知
 *                                         param1: >=0 成功，否则失败,
 *                                         Str:设备序列号
 *                                         pData：配置状态变化结果，json格式与查询接口Fun_GetDevCfgsFromShadowService格式一致
 */
int Fun_AddShadowServiceListener(UI_HANDLE hUser, const char *szDeviceSNs, int nTimeout = 5000, int nSeq = 0);

/**
 * @brief 移除影子服务设备配置监听
 * @param szDeviceSNs 设备序列号，多个以;分隔，不支持ip+port方式
 * @return 异步回调消息：停止监听结果：id:EMSG_SHADOW_SERVICE_STOP_DEV_LISTENING = 8804, ///< 停止设备影子服务监听
 *                                param1: >=0 成功，否则失败,
 *                                Str:设备序列号
 *                                pData：结果信息
 */
int Fun_RemoveShadowServiceListener(UI_HANDLE hUser, const char *szDeviceSNs, int nTimeout = 5000, int nSeq = 0);

/**
 * @brief 客户端到JF服务器网络速度测试
 * @param SpeedFileSize 测速文件大小  *1、5、10(默认值)、20 单位：MBytes
 * @return 异步回调消息：停止监听结果：id:EMSG_SYS_NET_SPEED_TEST = 8900, ///< 客户端到JF服务器网络速度测试
 *                                param1: >=0 成功，否则失败,
 *                                param2:下载速度(byte),
 *                                param3:上传速度(byte)
 */
int Fun_SysNetSpeedTest(UI_HANDLE hUser, int SpeedFileSize, int nSeq = 0);

/*设备功能方法*/
//---获取/设置对象属性---
int FUN_GetIntAttr(FUN_HANDLE hObj, int nId);
int FUN_GetIntAttr(FUN_HANDLE hObj, int nId, int nDefValue);
int FUN_GetStrAttr(FUN_HANDLE hObj, int nId, char *pStr, int nMaxSize);
int FUN_SetIntAttr(FUN_HANDLE hObj, int nId, int nValue);
int FUN_SetStrAttr(FUN_HANDLE hObj, int nId, const char *szValue);
int FUN_GetAttr(FUN_HANDLE hObj, int nId, char *pResult);
int FUN_SetAttr(FUN_HANDLE hObj, int nId, char *pResult);
int FUN_DestoryObj(FUN_HANDLE hObj, Bool bSyn = false);

//#define DSS_SERVER "DSS_SERVER"协
//#define SQUARE "SQUARE"
//#define XM030 "XM030"
//#define UPGRADE_SERVER "UPGRADE_SERVER"
int FUN_UpdateServerInfo(const char *szServerKey, const char *szIPPort); // 未使用
// 获取/设置库的全局属性,详见EFUN_ATTR枚举
int FUN_GetFunIntAttr(EFUN_ATTR nId);
int FUN_GetFunStrAttr(EFUN_ATTR nId, char *pStr, int nMaxSize);
/**
 * @brief 获取属性值比较长的数据
 */
std::string FUN_GetLongFunStrAttr(EFUN_ATTR nId);
int FUN_SetFunIntAttr(EFUN_ATTR nId, int nValue);
int FUN_SetFunStrAttr(EFUN_ATTR nId, const char *szValue);
int FUN_GetAttr(EFUN_ATTR nId, char *pResult);
int FUN_SetAttr(EFUN_ATTR nId, char *pResult);
int Fun_GetObjHandle(EOOBJECT_ID nId);
int Fun_GetDevHandle(const char *szDevId);

//---其他方法    使用GetObjHandle获得对象ID,通过SendMsg完成发送消息处理功能---
int FUN_SendMsg(FUN_HANDLE hObj, UI_HANDLE hUser, int nMsgId, int nParam1 = 0, int nParam2 = 0, int nParam3 = 0, const char *szParam = "", const void *pData = 0, int nDataLen = 0, int nSeq = 0);
/////////////////////////////////////////// 设备公开与相关共享操作  ////////////////////////////////////////////////////
FUN_HANDLE FUN_GetPublicDevList(UI_HANDLE hUser, int nSeq);
FUN_HANDLE FUN_GetShareDevList(UI_HANDLE hUser, int nSeq);
//param:title&location&description(标题&地址&描述)
FUN_HANDLE FUN_SetDevPublic(UI_HANDLE hUser, const char *szDevId, const char *param, int nSeq);
//param:title&location&description(标题&地址&描述)
FUN_HANDLE FUN_ShareDevVideo(UI_HANDLE hUser, const char *szDevId, const char *param, int nSeq);
FUN_HANDLE FUN_CancelDevPublic(UI_HANDLE hUser, const char *szDevId, int nSeq);
FUN_HANDLE FUN_CancelShareDevVideo(UI_HANDLE hUser, const char *szDevId, int nSeq);
FUN_HANDLE FUN_SendComment(UI_HANDLE hUser, const char *videoId, const char *context, int nSeq);
FUN_HANDLE FUN_GetCommentList(UI_HANDLE hUser, const char *videoId, int nPage, int nSeq);
FUN_HANDLE FUN_GetVideoInfo(UI_HANDLE hUser, const char *szVideoId, int nSeq);
FUN_HANDLE FUN_GetShortVideoList(UI_HANDLE hUser, int nSeq);
FUN_HANDLE FUN_EditShortVideoInfo(UI_HANDLE hUser, const char *szVideoId, const char *szTitle, const char *szDescription, const char *style, int nSeq);
FUN_HANDLE FUN_DeleteShortVideo(UI_HANDLE hUser, const char *szVideoId, int nSeq);
FUN_HANDLE FUN_GetUserPhotosList(UI_HANDLE hUser, int page,  int nSeq);
FUN_HANDLE FUN_CreateUserPhotos(UI_HANDLE hUser, const char *photosName, const char *szLocation, const char *szDescription, const char *style, int nSeq);
FUN_HANDLE FUN_EditUserPhotos(UI_HANDLE hUser, const char *photosName, const char *szLocation, const char *szDescription, const char *style, const char *photosId, int nSeq);
FUN_HANDLE FUN_UpLoadPhoto(UI_HANDLE hUser, const char *photosId, const char *szTitle, const char *szLocation, const char *szDescription, const char *szPhotoFileName, int nCoverPic, int nSeq);
FUN_HANDLE FUN_EditPhotoInfo(UI_HANDLE hUser, const char *photosId, const char *photoId, const char *szTitle, const char *szLocation, const char *szDescription, int nSeq);
FUN_HANDLE FUN_GetPhotoList(UI_HANDLE hUser, const char *photosId, int nPage, int nSeq);
FUN_HANDLE FUN_DeletePhoto(UI_HANDLE hUser, const char *photoId, int nSeq);
FUN_HANDLE FUN_DeletePhotos(UI_HANDLE hUser, const char * photosId, int nSeq);
FUN_HANDLE FUN_CSSAPICommand(UI_HANDLE hUser, const char *szDevId, const char *cmd, const char *param, int nSeq);
FUN_HANDLE FUN_CSSAPICommandCFS(UI_HANDLE hUser, const char *szDevId, const char *cmd, const char *param, const char *date, int nSeq);
FUN_HANDLE FUN_KSSAPICommand(UI_HANDLE hUser, const char *object, const char *bucket, const char *auth, const char *date, const char *fileName, int nSeq);
FUN_HANDLE FUN_KSSAPIUpLoadVideo(UI_HANDLE hUser, const char *userName, const char *pwd, const char *title, const char *location, const char *description, const char *categroyId, const char *videoFileName, const char *picFileName, const char *style, int nSeq);
FUN_HANDLE FUN_KSSAPIUpLoadPhoto(UI_HANDLE hUser, const char *object, const char *bucket, const char *auth, const char *signature,const char *policy, const char *fileName, int nSeq);

//---设备相关操作接口---
/////////////////////////////////////////// 设备相关操作  ////////////////////////////////////////////////////
// 设备登录，如果本地数据库中没有此设备，则创建
int FUN_DevLogin(UI_HANDLE hUser, const char *szDevId, const char *szUser, const char *szPwd, int nSeq);
//适用于门铃，使设备进入休眠状态--EMSG_DEV_SLEEP
int FUN_DevSleep(UI_HANDLE hUser, const char *szDevId, int nSeq);
//适用于门铃，唤醒设备，使之进入唤醒状态--EMSG_DEV_WAKE_UP
int FUN_DevWakeUp(UI_HANDLE hUser, const char *szDevId, int nSeq);

/*******************设备相关的接口**************************
 * 方法名:设备唤醒
 * 描  述: 适用于门铃，唤醒设备，使之进入唤醒状态，通过参数控制设备是否进行后台登录 *true：后台登录 false：不进行后台登录
 * 返回值:
 * 参  数:
 *      输入(in)
 *          [szDevId:设备序列号]
 *          [bDevLogin:唤醒成功后是否进行立马后台登录设备]
 *      输出(out)
 *          [无]
 * 结果消息：
 *         消息id:EMSG_DEV_WAKE_UP = 5142
 *         param1:==EE_OK：成功；<0：失败，详见错误码说明
 ****************************************************/
int FUN_DevWakeUpCtlLogin(UI_HANDLE hUser, const char *szDevId, Bool bDevLogin, int nSeq);

/**
 * @brief 设备重连使能
 * @details 是否允许设备发生断线自动重连(解决部分低功耗设备准备休眠后，进入休眠后又被SDK唤醒)
 * @details 以下几种情况会自动恢复设备重连机制：1.任何需要登录设备的接口调用 2.重新唤醒 3.设备登出(FUN_DevLogout)重新登录后 4.长时间未恢复使能(24秒)，正常禁用后APP基本马上就会登出设备，加此逻辑防止APP未登出
 * @param szDevID 设备ID
 * @param nDisable 使能 0:不允许重连 1：允许自动重连
 */
void Fun_DevIsReconnectEnable(const char *szDevID, Bool nEnable);

/**
 * @brief 设备唤醒接口
 * @details 兼容 FUN_DevWakeUp、FUN_DevWakeUpCtlLogin接口，调用此接口后，SDK内部发生唤醒也会使用szReqExJson字段的内容！！！
 * @details szReqExJson字段也可以接口设置，保存在本地文件，直到下次覆盖、否者会一直生效
 * @details 异步回调消息：id:5142 param1: >=0 成功，否者失败
 * @param szDevId 设备序列号(不支持ip)
 * @param szReqExJson 唤醒设备的一些附加信息(必须是JSON格式) 示例：{"ExtInfo":{"Cmd":"xxx","Args":"xxx"}}
 * @param bDevLogin 后台登录设备使能  0:不登录  1：唤醒成功后自动登录
 */
int Fun_DevWakeUpExt(UI_HANDLE hUser, const char *szDevId, const char *szReqExJson = "", Bool bDevLogin = TRUE, int nSeq = 0);

/*******************设备相关的接口**************************
* 方法名: 设备连接网络状态获取
* 描  述: 设备连接网络状态获取, rts网络类型会动态改变
* 返回值:
*      网络类型
* 参  数:
*      输入(in)
*          [szDevId:设备序列号]
*      输出(out)
*          [无]
* 结果消息：
* 		消息id:EMSG_DEV_GET_CONNECT_TYPE = 5151
* 		param1: >= 0 设备网络类型, < 0 失败，见错误码
* 		Str: 设备序列号
****************************************************/
int FUN_DevGetConnectType(UI_HANDLE hUser, const char *szDevId, int nSeq);

int FUN_DevGetChnName(UI_HANDLE hUser, const char *szDevId, const char *szUser, const char *szPwd, int nSeq = 0);
// 云台控制
int FUN_DevPTZControl(UI_HANDLE hUser, const char *szDevId, int nChnIndex, int nPTZCommand, bool bStop = false, int nSpeed = 4, int nSeq = 0);
// 设备配置获取与设置 - 废弃
/** @deprecated */
int FUN_DevGetConfig(UI_HANDLE hUser, const char *szDevId, int nCommand, int nOutBufLen, int nChannelNO = -1, int nTimeout = 15000, int nSeq = 0);
/** @deprecated */
int FUN_DevSetConfig(UI_HANDLE hUser, const char *szDevId, int nCommand, const void *pConfig, int nConfigLen, int nChannelNO = -1, int nTimeout = 15000, int nSeq = 0);

// 设备配置获取与设置(Json格式)
int FUN_DevGetConfig_Json(UI_HANDLE hUser, const char *szDevId, const char *szCommand, int nOutBufLen, int nChannelNO = -1, int nTimeout = 15000, int nSeq = 0);
int FUN_DevSetConfig_Json(UI_HANDLE hUser, const char *szDevId, const char *szCommand, const void *pConfig, int nConfigLen, int nChannelNO = -1, int nTimeout = 15000, int nSeq = 0);
int FUN_DevGetConfigJson(UI_HANDLE hUser, const char *szDevId, const char *szCmd, int nChannelNO = -1, int nCmdReq = 0, int nSeq = 0, const char *pInParam = NULL, int nCmdRes = 0, int nTimeout = 0);
int FUN_DevSetConfigJson(UI_HANDLE hUser, const char *szDevId, const char *szCmd, const char *pInParam, int nChannelNO = -1, int nCmdReq = 0, int nSeq = 0, int nCmdRes = 0, int nTimeout = 0);

/**
 * @brief 设备配置获取(不通过缓存)
 * @details SDK内部有部分配置会有缓存，并不一定每次都会从设备重新获取。 *SystemInfo、SystemFunction、fVideo.AudioSupportType
 * @details @async 消息ID：5128; param1: >=0 成功，否者失败 param2:通道号(ps:获取SystemInfo的时候，此字段代表当前设备网络类型) param3:配置ID Str:配置名 pData:结果信息
 * @param szDevId 设备序列号或者IP
 * @param szCmdName 配置名称
 * @param nChannelIndex 通道号索引
 * @param nCmdReqId  配置ID(与设备交互信令ID)
 * @param pInParam 配置完整数据
 * @param nCmdRes 保留字段 暂未使用
 * @param nTimeout 超时时间  *<=0库里面默认根据网络类型设置
 */
int Fun_DevGetConfigJsonWithoutCache(UI_HANDLE hUser, const char *szDevId, const char *szCmdName, int nChannelIndex = -1, int nCmdReqId = 0, int nSeq = 0, const char *pInParam = NULL, int nCmdRes = 0, int nTimeout = 15000);

/** @deprecated 接口废弃，使用FUN_DevConfigJson_NotLoginPtl接口代替 */
int FUN_DevConfigJson_NotLogin(UI_HANDLE hUser, const char *szDevId, const char *szCmd, const char *pInParam, int nCmdReq, int nChannelNO = -1, int nCmdRes = 0, int nTimeout = 15000, int nSeq = 0);

/**
 * @brief 设备配置获取、设置(not login)
 * @details 不登陆设备，直接获取，支持客户端链接主动关闭
 * @details @async 消息ID：5150; param1: >=0 成功，否者失败 param2:通道号 param3:配置ID pData:结果信息
 * @param szCmd 配置命令字
 * @param pInParam 配置协议-json格式
 * @param nCmdReq 配置ID
 * @param nCmdRes 暂时未使用
 * @param nTimeout 超时时间  *<=0库里面默认根据网络类型设置
 * @param nActiveClose 是否立即主动关闭  1:主动关闭 0：不主动关闭，sdk内部20s超时自动关闭，再次调用接口重新计时
 * @return >=0消息发送成功，否者失败
 */
int Fun_DevConfigJson_NotLoginPtl(UI_HANDLE hUser, const char *szDevId, const char *szCmd, const char *pInParam, int nCmdReq, int nChannelNO = -1, int nCmdRes = 0, int nTimeout = 15000, int nSeq = 0, int nActiveClose = 1);

// 设备通用命令交互
// nIsBinary >= 0 || nInParamLen > 0传入的为二进制字节数组
int FUN_DevCmdGeneral(UI_HANDLE hUser, const char *szDevId, int nCmdReq, const char *szCmd, int nIsBinary, int nTimeout, char *pInParam = NULL, int nInParamLen = 0, int nCmdRes = -1, int nSeq = 0);
// 查询设备缩略图
int FUN_DevSearchPic(UI_HANDLE hUser, const char *szDevId, int nCmdReq, int nRetSize, int nTimeout, char *pInParam, int nInParamLen, int nCount, int nCmdRes = -1, const char * szFileName = NULL, int nSeq = 0);
int FUN_StopDevSearchPic(UI_HANDLE hUser, const char *szDevId, int nSeq);
int FUN_DevGetAttr(UI_HANDLE hUser, const char *szDevId, int nCommand, int nOutBufLen, int nChannelNO = -1, int nTimeout = 15000, int nSeq = 0);
int FUN_DevSetAttr(UI_HANDLE hUser, const char *szDevId, int nCommand, const void *pConfig, int nConfigLen, int nChannelNO = -1, int nTimeout = 15000, int nSeq = 0);
int FUN_DevLogout(UI_HANDLE hUser, const char *szDevId);
int FUN_DevReConnect(UI_HANDLE hUser, const char *szDevId); //未实现
int FUN_DevReConnectAll(UI_HANDLE hUser);
// 获取DSS支持的能力级--详细见EDEV_STREM_TYPE
uint FUN_GetDSSAbility(const char *szDevId, int nChannel);

/*******************DSS相关的接口**************************
* 方法名: 获取DSS通道主辅码流状态(当前缓存)
* 描  述: 通过DSS服务器返回的信息，获取DSS主辅码流状态
* 返回值:
*      [通道状态] 详见枚举E_DSS_CHANNEL_STATE
* 参  数:
*      输入(in)
*          [szDevId:设备序列号]
*          [nChannel:设备通道号 *从0开始]
*          [nStreamType:码流类型  *0：主码流 1：辅码流]
*      输出(out)
*          [无]
* 结果消息：无
****************************************************/
int FUN_GetDSSChannelState(const char *sDevId, int nChannel, int nStreamType);

/*******************DSS相关的接口**************************
* 方法名: 获取DSS支持混合通道号
* 描  述: 通过dss服务器返回的信息，获取DSS混合通道号(*返回的混合通道号从0开始)
* 返回值:
*      [编解码类型] >=0 支持,第几通道
*      			 <0    不支持
* 参  数:
*      输入(in)
*          [szDevId:设备序列号]
*          [nStreamType:码流类型]
*      输出(out)
*          [无]
* 结果消息：无
****************************************************/
int FUN_GetDSSMixedChannel(const char *szDevId, int nStreamType);

/** @deprecated 接口废弃，名称容易误认为只修改设备密码，使用FUN_DevSetLocalUserNameAndPwd代替 */
int FUN_DevSetLocalPwd(const char *szDevId, const char *szUser, const char *szPwd);

/** 设置本地缓存设备用户名密码 */
int Fun_DevSetLocalUserNameAndPwd(const char *szDevId, const char *szUser, const char *szPwd);

/**
 * @brief 设置登录令牌信息(加密后的数据)到本地缓存
 * @details 登录设备优先使用Token进行校验
 * @param szDevId  设备序列号
 * @param szEncToken (加密后的数据)登录令牌信息
 */
int Fun_DevSetLocalEncToken(const char *szDevId, const char *szEncToken);

/**
 * @brief 设置设备信息到本地缓存
 * @details 用于代替FUN_DevSetLocalPwd、Fun_DevSetLocalEncToken接口 ps:设置先后顺序必须先设置用户名密码再设置TOKEN
 * @param szDevId 设备序列号或者IP、域名
 * @param szUser 设备用户名 ps:本地只能存储一个，相互覆盖
 * @param szPwd  设备密码  ps:对应用户名
 * @param szEncToken 设备TOKEN(加密的数据)
 */
int Fun_DevSetDevInfoToLocal(const char *szDevId, const char *szUser, const char *szPwd, const char *szEncToken);

char *FUN_DevGetLocalPwd(const char *szDevId, char szPwd[MAX_DEV_NAMEPASSWORD_LEN]);
char *FUN_DevGetLocalUserName(const char *szDevId, char szUserName[64]);

/**
 * @brief 获取登录令牌信息(加密后的数据)
 * @param szDevId  设备序列号
 * @param szEncToken (加密后的数据)登录令牌信息
 */
char *FUN_DevGetLocalEncToken(const char *szDevId, char szEncToken[MAX_DEV_TOKEN_LEN]);

int Fun_DevSetPid(const char *szDevId, const char *szPid);
char *Fun_GetDevPid(const char *szDevId, char szPid[MAX_DEV_PID]);

/**
 * @brief 通过键值ID获取随机秘钥(直到APP卸载保持有效)
 * @param szKeyID 键值ID
 * @param nRandKeyLen 随机密码长度  最大63(MAX_RAND_KEY > nRandKeyLen)字节
 * @param[out] szRandKey 随机秘钥字符串 ps:本地无缓存的时候生成，有的话直接返回
 * @return >= 0成功否者失败
 */
int Fun_GetLocalCacheRandKey(const char *szKeyID, int nRandKeyLen, char szRandKey[MAX_RAND_KEY]);

/**
 * @brief 通过键值ID删除随机秘钥
 * @param szKeyID 键值ID
 * @param nRandKeyLen 随机密码长度  最大64字节
 * @param[out] szRandKey 本地无缓存的时候生成，有的话直接返回
 * @return >= 0成功否者失败
 */
void Fun_DelLocalCacheRandKey(const char *szKeyID);

/**
 * @brief 加密生成蓝牙TOKEN
 * @param szDevID 设备序列号
 * @param szInfoJson 蓝牙信息
 * @param[out] szToken 蓝牙TOKEN
 */
char *Fun_EncBleToken(const char *szDevID, const char *szInfoJson, char szToken[MAX_BEL_ENC_TOKEN]);

/**
 * @brief 解密蓝牙TOKEN
 * @param szDevID 设备序列号
 * @param szToken 蓝牙TOKEN
 * @param szInfo 解密后的蓝牙信息
 */
char *Fun_DecBleToken(const char *szDevID, const char *szToken, char szInfo[MAX_BEL_ENC_TOKEN]);

// 快速配置接口
// WIFI配置配置接口（WIFI信息特殊方式发送给设备-->接收返回（MSGID->EMSG_DEV_AP_CONFIG））
int FUN_DevStartAPConfig(UI_HANDLE hUser, int nGetRetType, const char *ssid, const char *data, const char *info, const char *ipaddr, int type, int isbroad, const unsigned char wifiMac[6], int nTimeout = 10000);
void FUN_DevStopAPConfig(int nStopType = 0x3);

//录像查询
//(EMSType.XXXX << 26) | (1 << EMSSubType.XXXXX & 0x3FFFFFF);
int FUN_DevFindFile(UI_HANDLE hUser, const char *szDevId, H264_DVR_FINDINFO* lpFindInfo, int nMaxCount, int waittime = 10000, int nSeq = 0);
int FUN_DevFindFileByTime(UI_HANDLE hUser, const char *szDevId, SDK_SearchByTime* lpFindInfo, int waittime = 2000, int nSeq = 0);
FUN_HANDLE FUN_DevDowonLoadByFile(UI_HANDLE hUser, const char *szDevId, H264_DVR_FILE_DATA *pH264_DVR_FILE_DATA, const char *szFileName, int nSeq = 0);
FUN_HANDLE FUN_DevDowonLoadByTime(UI_HANDLE hUser, const char *szDevId, H264_DVR_FINDINFO *pH264_DVR_FINDINFO, const char *szFileName, int nSeq = 0);

/**
 * @brief 下载SD卡图片集合
 * @param szDevId 设备序列号或者IP、域名
 * @param pH264_DVR_FILE_DATA_IMG_LIST 所要下载的文件信息
 * @param szFileListMsk  掩码（图片下载序列）例如："0xffffffff,0xffffffff"
 * @param szFileDirName 文件保存路径（需要最后有"/"）  例如"sdcard/data/Android/"
 * @return
 * 异步结果通知：
 * what:
 *  EMSG_ON_FILE_DOWNLOAD = 5116, 下载开始结果通知
    EMSG_ON_FILE_DLD_COMPLETE = 5117, 下载完成结果通知
    EMSG_ON_FILE_DLD_POS = 5118, 下载进度结果通知   arg1:总个数 arg2：已下载的个数 arg3：当前下载图片所在列表中的位置 str:当前下载图片绝对路径
 */
FUN_HANDLE FUN_DevImgListDowonLoad(UI_HANDLE hUser, const char *szDevId, H264_DVR_FILE_DATA_IMG_LIST *pH264_DVR_FILE_DATA_IMG_LIST, const char *szFileListMsk, const char *szFileDirName, int nSeq);
int FUN_DevStopDownLoad(FUN_HANDLE hDownload);

// 录像缩略图下载（最新固件才会支持2017.07.19）
// 异步消息EMSG_DOWN_RECODE_BPIC_START、EMSG_DOWN_RECODE_BPIC_FILE、EMSG_DOWN_RECODE_BPIC_COMPLETE
// 返回nDownId：可用于FUN_CancelDownloadRecordImage，取消下载用
int FUN_DownloadRecordBImage(UI_HANDLE hUser, const char *szDevId, int nChannel, int nTime, const char *szFileName, int nTypeMask = -1, int nSeq = 0);
int FUN_DownloadRecordBImages(UI_HANDLE hUser, const char *szDevId, int nChannel, int nStartTime, int nEndTime, const char *szFilePath, int nTypeMask = -1, int nSeq = 0, int nMaxPicCount = 0x7fffffff);

// nDownId:开始的返回值，如果==0表示全部停止
int FUN_CancelDownloadRecordImage(const char *szDevId, int nDownId);

// 设置设备下载队列最多任务数(初始默认为48)（录像缩略图下载SDK中是有个下载队列，排队下载）
// nMaxSize == 0取消限制； nMaxSize > 0：下载最大排队任务数
int FUN_SetDownRBImageQueueSize(const char *szDevId, int nMaxSize);

////////升级相关函数////////////////////
//升级检测
/** @deprecated 接口废弃，使用FUN_DevCheckUpgradeAllNet代替(设备端检测升级失败后，p2p模式也允许去服务器检测升级信息) */
int FUN_DevCheckUpgrade(UI_HANDLE hUser, const char *szDevId, int nSeq = 0); // 返回MSGID:EMSG_DEV_CHECK_UPGRADE
int FUN_DevCheckUpgradeAllNet(UI_HANDLE hUser, const char *szDevId, int nSeq = 0); // 支持转发/p2p云服务查询
/** @deprecated 接口废弃，使用FUN_DevCheckUpgradeExAllNet代替(设备端检测升级失败后，p2p模式也允许去服务器检测升级信息) */
int FUN_DevCheckUpgradeEx(UI_HANDLE hUser, const char *szDevId, const SSubDevInfo *szSubDevInfo = NULL, int nSeq = 0);
int FUN_DevCheckUpgradeExAllNet(UI_HANDLE hUser, const char *szDevId, const SSubDevInfo *szSubDevInfo = NULL, int nSeq = 0);// 支持转发/p2p云服务查询

// 设备升级
int FUN_DevStartUpgrade(UI_HANDLE hUser, const char *szDevId, int nType, int nSeq = 0);
int FUN_DevStartUpgradeByFile(UI_HANDLE hUser, const char *szDevId, const char *szFileName, int nSeq = 0);
int FUN_DevStartUpgradeEx(UI_HANDLE hUser, const char *szDevId, int nType, const SSubDevInfo *szSubDevInfo = NULL, int nSeq = 0);
int FUN_DevStartUpgradeByFileEx(UI_HANDLE hUser, const char *szDevId, const char *szSubDevId, const char *szFileName, int nSeq = 0);

int FUN_DevStopUpgrade(UI_HANDLE hUser, const char *szDevId, int nSeq = 0);

/**
 * @brief 升级检测（拓展模块）
 * @details 拓展模块系统信息需要客户端获取，传入到SDK
 * @details 异步回调消息：id:5552 param1: >=0 成功 代表升级类型，详见@enum EDEV_UPGRADE_TYPE，否者失败 Str:升级信息
 * @param szReqJson 升级检测请求信息
 * @example
 * {
 *  "DevID":"xx",      ///< 设备ID
 *  "Type":"Mcu",  ///< 升级类型  *这个字段用Mcu表示要升级的是单片机，也可以用来表示锁板程序
 *	"SystemInfoEx": ///< 拓展模块系统信息
 *	{
 *	}
 * }
 * @return >=0代表成功，否者失败
 */
int FUN_DevExModulesCheckUpgrade(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 开始升级（拓展模块）
 * @details 需要结合FUN_DevExModulesCheckUpgrade接口使用，如果FUN_DevExModulesCheckUpgrade接口未检测到结果，使用此接口无效
 * @details 异步回调消息：id:5553 升级开始结果回调 param1: >=0 成功，否者失败
 * @details 异步回调消息：id:5555 升级进度回调 param1:升级步骤 详见@enum EUPGRADE_STEP，param2：进度0~100，当param1 == EUPGRADE_STEP_COMPELETE时，>0代表成功，否者失败
 * @param szReqJson 请求信息
 * @example
 * {
 *  "DevID": "xx", ///< 设备ID
 *  "Type" : "Mcu" ///< 升级类型  *这个字段用"Mcu"表示要升级的是单片机，也可以用来表示锁板程序
 * }
 * @return >=0代表成功，否者失败
 */
int FUN_DevExModulesStartUpgrade(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 通过本地文件进行设备升级（拓展模块）
 * @details 异步回调消息：id:5553 升级开始结果回调 param1: >=0 成功，否者失败
 * @details 异步回调消息：id:5555 升级进度回调 param1:升级步骤 详见@enum EUPGRADE_STEP， param2：进度0~100  当param1 == EUPGRADE_STEP_COMPELETE时，>0代表成功，否者失败
 * @param szReqJson 请求信息
 * @example
 * {
 *  "DevID": "xx", ///< 设备ID
 *  "FileName" : "", ///< 本地文件绝对路径
 *  "Type" : "Mcu" ///< 升级类型  *这个字段用Mcu表示要升级的是单片机，也可以用来表示锁板程序
 * }
 * @return >=0代表成功，否者失败
 */
int FUN_DevExModulesStartUpgradeByFile(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 停止升级（拓展模块）
 * @param szDevId 设备ID
 */
int FUN_DevExModulesStopUpgrade(UI_HANDLE hUser, const char *szDevId, int nSeq = 0);

/*******************IPC升级相关的接口**************************
* 方法名: NVR给IPC升级
* 描  述: NVR给IPC升级，设备主动去服务器下载固件，升级
* 返回值:
*          [无]
* 参  数:
*      输入(in)
*          [szDevID:设备序列号/ip]
*          [nChannel:通道号，升级的IPC通道号]
*          [nUpgType:升级类型，目前默认0]
*          [nTimeout:超时时间，单位ms， 默认120000ms，因为NVR给IPC升级，IPC切到升级状态时间比较长]
*      输出(out)
*          [无]
* 结果消息：
*        消息id:1.EMSG_DEV_START_UPGRADE_IPC = 5163,       // IPC开始升级
*        	             参数说明：param1：>= 0 成功, < 0 失败，见错误码
*              2.EMSG_DEV_ON_UPGRADE_IPC_PROGRESS = 5164, // IPC升级信息回调
*              	参数说明： param1： 升级当前状态，详见枚举EUPGRADE_STEP
*              	       param2：>= 0 ,对应当前升级进度， 只有param1==10的时候，需要判断param2是否<0(失败，见错误码)
****************************************************/
int FUN_DevStartUpgradeIPC(UI_HANDLE hUser, const char *szDevID, int nChannel, int nUpgType = 0, int nTimeout = 120000, int nSeq = 0);
int FUN_DevStopUpgradeIPC(UI_HANDLE hUser, const char *szDevID, int nSeq = 0);

// 接口废弃，使用FUN_DevStartWifiConfigByAPLogin接口代替
int FUN_DevSetWIFIConfig(UI_HANDLE hUser, const char *pCfg, int nCfgLen, const char *szUser, const char *szPwd, int nTimeout, int nSeq);

// WIFI配置配置接口（这种方式需要可以登录设备，通过协议把SSID和密码发给设备）
// 手机APP通过局域网登录时（过程：调用接口->回调返回结果）（MSGID->EMSG_DEV_SET_WIFI_CFG））
int FUN_DevStartWifiConfig(UI_HANDLE hUser, const char *szDevId, const char *szSSID, const char *szPassword, int nTimeout = 120000);
// 手机APP通过设备热点连接时（过程：手机连接设备热点->调用接口->返回1->切换到家里的WIFI->返回结果）（MSGID->EMSG_DEV_SET_WIFI_CFG））
int FUN_DevStartWifiConfigByAPLogin(UI_HANDLE hUser, const char *szDevId, const char *szSSID, const char *szPassword, int nTimeout = 120000);
void FUN_DevStopWifiConfig();

/*******************对讲相关的接口**************************
* 方法名: 开启对讲
* 描  述: 开启对讲
* 返回值:
*         操作句柄
* 参  数:
*      输入(in)
*          [nSupIpcTalk:是否支持IPC对讲，非0支持,0不支持，能力级获取SupportIPCTalk]
*          [nChannel:-1表示对所有连接的IPC单向广播 ， >=0表示指定某通道进行对讲  *nSupIpcTalk = 0时不需要使用]
*      输出(out)
*          [无]
* 结果消息：
* 		消息ID：EMSG_START_PLAY = 5501
****************************************************/
/** @deprecated 接口废弃，使用Fun_DevStartTalk代替 */
FUN_HANDLE FUN_DevStarTalk(UI_HANDLE hUser, const char *szDevId, Bool bSupIpcTalk = FALSE, int nChannel = -1, int nSeq = 0);

/**
 * @brief 开启对讲功能
 * @param szDevId 设备序列号 || ip+port
 * @param pInfo 对讲参数，详见@struct SDevTalkParams
 * @return @async 消息ID：5111; param1: >=0 成功，否者失败
 * @return >=0消息发送成功，否者失败
 */
FUN_HANDLE Fun_DevStartTalk(UI_HANDLE hUser, const char *szDevId, SDevTalkParams *pInfo, int nSeq = 0);

int FUN_DevSendTalkData(const char *szDevId, const char *pPCMData, int nDataLen);
void FUN_DevStopTalk(FUN_HANDLE hPlayer);

/**
 * @brief 开启音视频对讲(Client-->Dev)
 * @details 异步回调消息：id:5556 param1: >=0 成功，否者失败
 * @param szDevID 设备ID
 * @param szReqJson 请求信息
 * @example
 * {
 * 	  "protocoltype" : 0, ///< 传输数据格式协议类型枚举，暂定netip+xm私有码流格式【默认值:0】
 * 	  "version" : 1, ///< XM私有码流头信息格式  0:V1版本【默认值】 1:V2版本
 * 	  "mediatype" : 0, ///< 发送数据的媒体类型 详见@enum EAVTalkSendMediaType 【默认值：E_AVTALK_SEND_MEDIA_TYPE_ALL】
 * 	  "channel" : 0, ///< 通道号 【默认值:-1】
 * 	  "timestamp" : "1697694748000", ///< 第一个I帧时间戳，也就是最开始时间戳
 * 	  "timeout" : 5000, ///< 数据发送超时时间
 * 	  "maxduration" : 3000, ///< 最大缓存数据时长，单位ms，超出直接全部丢弃缓存中的帧数据【默认值：3000,最低1000ms】
 *    "videoinfo"
 *    {
 *    	 "encodetype" : "H264", ///< 编码类型【必传】
 *    	 "srcwidth" : 80, ///< 输入源宽度  80~【必传】
 *    	 "srcheight" : 80, ///< 输入源高度 80~【必传】
 *    	 "dstwidth" : 80, ///< 输出源宽度  80~【默认值:srcwidth】
 *    	 "dstheight" : 80, ///< 输出源高度 80~【默认值:srcheight】
 *    	 "fps" : 8, ///< 帧率【默认值:10】
 *    	 "gopsize" : 2, ///< I帧间隔 2是I帧帧率倍数不是个数【默认值:2】
 *    	 "qp" : 27, ///< 量化参数，值越大，图片质量越低 【默认值:27】
 *    	 "preset" : 2, ///< 编码器的预设配置，值越大编码速度越慢，图片质量越高【默认值:2】【注意：仅支持设置H264】
 *    },
 *    "audioinfo"
 *    {
 *    	"encodetype" : "g711a", ///< 编码类型【必传】
 *    	"channels" : 1, ///< 通道数量【默认值:1】
 *    	"bit" : 16, ///< 比特率【默认值:16】
 *    	"samplerate" : 8000, ///< 采样率【默认值:8000】
 *    	"fps" : 50, ///< 帧率【默认值:50】
 *    }
 * }
 */
FUN_HANDLE Fun_DevStartAVTalk(UI_HANDLE hUser, const char *szDevID, const char *szReqJson, int nTimeout, int nSeq = 0);

/**
 * @brief 发送音视频对讲数据(Client-->Dev)
 * @details SDK内部会对数据进行转换(仅支持传入的数据格式 音频:PCM 视频:YUV420) (暂未实现)
 * @details 数据转换成的格式信息，是通过Fun_DevStartAVTalk设置的
 * @param hPlayer 操作句柄,开启音视频对讲返回值
 * @param pAVData 音视频数据(完整一帧数据)
 * @param nDataLen 数据长度
 * @param szFrameInfo 帧信息(时间戳等信息)
 * @example
 * {
 * 	  "timestamp" : "123456789", ///< 时间戳，整型字符串，精确到毫秒
 * 	  "type" : 1 ///< 1:视频 2：音频
 * }
 */
int Fun_DevSendAVTalkData(FUN_HANDLE hPlayer, const char *szFrameInfo, const char *pAVData, int nDataLen);

/**
 * @brief 关闭音视频对讲(Client-->Dev)
 * @details @details 异步回调消息：id:5558 param1: >=0 成功，否者失败
 * @param hPlayer
 */
void Fun_DevStopAVTalkData(FUN_HANDLE hPlayer);

/**
 * @brief 控制音视频对讲(Client-->Dev)
 * @details 异步回调消息：id:5559 param1: >=0 成功，否者失败  param2对应传入参数nControl
 * @param hPlayer 媒体功能控制句柄
 * @param szCtrlJson 配置信息JSON
 * @example
 * {
 * 	 "command":"video_pause", ///< 控制命令字段 "video_continue","switching_resolution"
 * 	 "info":   ///< 详细配置信息
 *   {
 *   	"srcwidth":80, ///< 输入源宽度  80~【必传】
 *   	"srcheight":80, ///< 输入源高度 80~【必传】
 *   	"dstwidth":80, ///< 输出源宽度  80~【默认值:srcwidth】
 *   	"dstheight":80, ///< 输出源高度 80~【默认值:srcheight】
 * 	 }
 * }
 */
int Fun_DevControlAVTalk(FUN_HANDLE hPlayer, const char *szCtrlJson, int nSeq = 0);

int FUN_DevOption(const char *szDevId, MsgOption *pOpt);
int FUN_DevOption(UI_HANDLE hUser, const char *szDevId, int nOptId, void *pData = NULL, int nDataLen = 0, int param1 = 0, int param2 = 0, int param3 = 0, const char *szStr = "", int seq = 0);

//废弃，代码未实现！！
int FUN_DevStartSynRecordImages(UI_HANDLE hUser, const char *szDevId, int nChannel, const char *bufPath, time_t beginTime, time_t endTime, int nSeq);
int FUN_DevStopSynRecordImages(UI_HANDLE hUser, const char *szDevId, int nSeq);

//局域网搜索
int FUN_DevSearchDevice(UI_HANDLE hUser, int nTimeout, int nSeq);

// 开启上报数据
int FUN_DevStartUploadData(UI_HANDLE hUser, const char *szDevId, int nUploadDataType, int nSeq);

/*******************数据上报通用协议**************************
* 方法名: 开启上报数据通用接口
* 描  述: 开启上报数据通用接口
* 返回值:
*
* 参  数:
*      输入(in)
*          [sDevId:设备序列号/ip]
*          [sJson:通用json协议，不需要带SessionId]
*          [nChannel:通道号，目前未使用， 传 0]
*          [nUploadDataType:数据上报类型  *通用传8]
*      输出(out)
*          [无]
* 结果消息：
* 		消息ID：    EMSG_DEV_START_UPLOAD_DATA = 5135,
*
* 		消息ID：    EMSG_DEV_ON_UPLOAD_DATA = 5137, // 数据上报消息ID
* 		       *参数说明： param1： 数据长度，可能是-1
*              	       param2：上报类型
*              	       pData：结果信息（json）
****************************************************/
int FUN_DevGeneralStartUploadData(UI_HANDLE hUser, const char *sDevId, const char *sJson, int nChannel, int nUploadDataType, int nSeq = 0);

// 关闭上报数据
int FUN_DevStopUploadData(UI_HANDLE hUser, const char *szDevId, int nUploadDataType, int nSeq);

/*******************数据上报通用协议**************************
* 方法名: 关闭上报数据通用接口
* 描  述: 关闭上报数据通用接口
* 返回值:
*
* 参  数:
*      输入(in)
*          [sDevId:设备序列号/ip]
*          [sJson:通用json协议，不需要带SessionId]
*          [nChannel:通道号，目前未使用， 传 0]
*          [nUploadDataType:通用上报类型：传8]
*      输出(out)
*          [无]
* 结果消息：
* 		消息ID：    EMSG_DEV_STOP_UPLOAD_DATA = 5136
****************************************************/
int FUN_DevGeneralStopUploadData(UI_HANDLE hUser, const char *sDevId, const char *sJson, int nChannel, int nUploadDataType, int nSeq = 0);

//注意：设置本地报警接受者，不再使用FUN_DevGetAlarmState(此名字含义不明显)， 使用FUN_DevSetAlarmListener
FUN_HANDLE FUN_DevGetAlarmState(UI_HANDLE hUser, int nSeq);
FUN_HANDLE FUN_DevSetAlarmListener(UI_HANDLE hUser, int nSeq);
//获取dss真实通道数 在线返回通道数，不在线返回0 *通道数， 通道号要区分
int FUN_GetDevChannelCount(const char *szDevId);

/*******************数据上报通用协议**************************
* 方法名: 将错误码添加到监听器
* 描  述: 将错误码添加到监听器。 允许多次调用，监听多个错误码。
* 返回值:
*
* 参  数:
*      输入(in)
*          [hUser:结果接收者]
*          [nErrorCode:错误码  *SDK内部以nErrorCode为Key(唯一值)]
*      输出(out)
*          [无]
* 结果消息：
* 		消息ID：    EMSG_DEV_ERROR_CODE_MONITOR = 5166
****************************************************/
int Fun_DevErrorCodeAddToMonitor(UI_HANDLE hUser, int nErrorCode);
// 将错误码从监听器移除
int Fun_DevErrorCodeRemoveFromTheMonitor(UI_HANDLE hUser, int nErrorCode);

#ifdef SUP_PREDATOR
//捕食器文件相关操作
int FUN_DevPredatorFileOperation(UI_HANDLE hUser, SPredatorAudioFileInfo *pFileInfo, const char *szDevId, const char *szFilePath, int nSeq);
//捕食器文件保存
int Fun_DevPredatorFileSave(UI_HANDLE hUser, const char *szDevId, const char *szFilePath, int nSeq);
#endif

// 获取设备能力级
// 返回 > 0表示有此功能能力  <=0表示无
// 智能录像放回能力 "OtherFunction/SupportIntelligentPlayBack"
int FUN_GetDevAbility(const char *szDevId, const char *szAbility);

// 分类型获取设备状态（直接获取缓存中的状态）
// nType: 详细说明见枚举EFunDevStateType
// 返回值见枚举EFunDevState
int FUN_GetDevState(const char *szDevId, int nType);

/*******************设备状态相关接口**************************
* 方法名: 获取缓存中的所有状态
* 描  述: 获取设备缓存中的所有网络类型在线/不在线状态（0/1）
* 返回值:
*      [所有网络状态] <0 错误值，详见错误码
*      			 >=0 网络状态码
* 参  数:
*      输入(in)
*          [szDevId:设备序列号]
*      输出(out)
*          [无]
* 结果消息：无
****************************************************/
int FUN_GetDevAllNetState(const char *szDevId);

/**
 * @brief 获取设备主控低功耗状态
 * @details 从本地缓存中获取，目前只有E_FUN_ON_LINE和E_FUN_ON_SLEEP
 * @param szDevID 设备序列号
 * @return 返回低功耗状态 详见@enum EFUN_SATE
 */
int Fun_GetDevMasterControlState(const char *szDevSN);

/**
 * @brief 获取设备外网IP地址
 * @details 从本地缓存中获取，需要状态查询接口FUN_SysGetDevState调用后使用
 * @param szDevSN 设备序列号(IP或者域名添加的设备不支持)
 * @param[out] szDstWanIP 设备外网IP
 * @param nMaxSize 可拷贝最大字节，一般为szDstWanIP数组字节大小
 * @return <0失败，详见错误码说明
 */
int Fun_GetDevWanIP(const char *szDevSN, char *szDstWanIP, int nMaxSize);

/** @deprecated FUN_SetDevInfoByShared接口废弃，使用Fun_AddDevInfoToDataCenter代替 */
/**
 * @brief 添加设备信息到数据中心(SDK本地数据中心)
 * @details 为了兼容未保存在服务器账户上的设备 \n
 * 			报警初始化alc服务（通过序列号获取服务器地址，开启服务）
 * @param pDevInfo 设备信息，详见结构体@struct SDBDeviceInfo
 * @param nWxpms 是否开启微信报警
 * @param nMa 是否是主账号
 * @param sComments 附加信息
 */
void Fun_AddDevInfoToDataCenter(SDBDeviceInfo *pDevInfo, int nWxpms, int nMa, const char* szComments);

/** @deprecated Fun_DeleteDevInfoByShared接口废弃，使用Fun_DeleteDevsInfoFromDataCenter代替 */

/**
 * @brief 从数据中心删除设备信息(SDK本地数据中心)
 * @details 为了兼容未保存在服务器账户上的设备 \n
 * 删除设备相关信息：关闭设备连接；清空设备状态；本地密码清空；dss本地缓存密码清空；自动取消报警订阅；关闭alc服务；devToken清空
 * @param sDevIds  设备序列号 多个设备时以';'分隔
 */
void Fun_DeleteDevsInfoFromDataCenter(const char *szDevIds);

/*******************设备相关接口**************************
* 方法名: 添加分享的设备的主账号UserId
* 描  述: APP获取到分享的设备，把UserId信息添加到SDK，SDK在获取云存储等服务的时候会使用。
* 返回值:[无]
* 参  数:
*      输入(in)
*          [sDevId:设备序列号]
*      输出(out)
*          [无]
* 结果消息：无
****************************************************/
int Fun_AddSharedDevMaUserId(const char *sDevId, const char *sUserId);

/**
 * @brief 判断设备是否在局域网内（不进行局域网搜索）
 * @details 仅支持序列号查找
 * @param szDevId  设备序列号
 * @param devInfo 搜索到的设备信息(IOS需分配对象空间)
 * @return 1代表设备在局域网内，否者不在
 */
int Fun_DevIsSearched(const char *szDevId, SDK_CONFIG_NET_COMMON_V2 *devInfo);

/**
 * @brief 局域网搜索设备
 * @param szDevSN 设备序列号(不支持IP或域名)
 * @param nTimeout 超时时间
 * @param[out] pOutDevInfo 搜索到的设备信息(IOS需分配对象空间)
 */
 int Fun_DevLANSearch(const char *szDevSN, int nTimeout, SDK_CONFIG_NET_COMMON_V2 *pOutDevInfo);

/**
 * @brief 检测局域网设备TCP服务
 * @param pDevInfo 局域网设备信息结构体
 * @param nTimeout 超时时间
 * @return 0:连接失败 1:连接成功
 */
int Fun_DevIsDetectTCPService(SDK_CONFIG_NET_COMMON_V2 *pDevInfo, int nTimeout);

/**
 * @brief 添加局域网内设备到SDK缓存
 * @details 便于蓝牙配网后快速访问设备
 * @param pDevsInfo 设备信息结构体(多个设备信息时传入首地址)
 * @param nDevCount 设备个数
 * @return == 0
 */
int Fun_AddLANDevsToCache(SDK_CONFIG_NET_COMMON_V2 *pDevsInfo, int nDevCount);

//EMSG_SYS_CLOUDUPGRADE_CHECK
int Fun_SysCloudUpGradeCheck(UI_HANDLE hUser,  const char *szDevId, int nSeq = 0);
//EMSG_SYS_CLOUDUPGRADE_DOWNLOAD
int Fun_SysCloudUpGradeDownLoad(UI_HANDLE hUser, const char *szDevId, int nSeq = 0);
//EMSG_SYS_STOP_CLOUDUPGRADE_DOWNLOAD
int Fun_SysStopCloudUpGradeDownLoad(UI_HANDLE hUser, const char *szDevId, int nSeq = 0);

/**
 * @brief 从服务器检测升级信息
 * @param szCustomJson 请求信息(JSON)
 * @param szCmd 命令字段，多模块传"listModule"，普通的传"list"，其他适服务器提供协议文档而定
 * @details 异步回调消息：id:5096 param1: >=0 成功，否者失败 Str:结果信息(JSON格式)
 */
int Fun_SysCheckUpgradeForServer(UI_HANDLE hUser, const char *szRequestJson, const char *szCmd, int nTimeout, int nSeq);

/**
 * @brief 开始从服务器下载升级固件
 * @details 接口为了单独下载固件，支持多模块固件下载和通用固件下载，客户端通过蓝牙协议发送固件给设备端
 * @param szFilePath 升级文件存放目录  具体文件名命名方式：%s_%d_%s_%s(DevID_0_Date_FileName)
 * @param szUpgradeInfo  升级信息 ps:Fun_SysCheckUpgradeForServer返回的结果
 * @details 异步回调消息：id:8605(开始升级结果通知) param1: >=0 成功，否者失败
 * @details 异步回调消息：id:8606(升级进度回调) param1: >=0 代表升级进度，否者失败 param2：当前已下载的固件数据大小 param3:下载固件总大小 Str:模块名称
 * @return 返回对象操作句柄，用于停止升级固件下载(中途临时取消)
 */
FUN_HANDLE Fun_SysStartDownloadUpgradeFileForServer(UI_HANDLE hUser, const char *szFilePath, const char *szUpgradeInfo, int nSeq);

/**
 * @brief 停止从服务器下载升级固件
 * @param hHandle 升级对象操作句柄
 * @details 异步回调消息：id:8607 param1: >=0 成功，否者失败
 */
int Fun_SysStopDownloadUpgradeFileForServer(FUN_HANDLE hHandle, UI_HANDLE hUser, int nSeq);

// 通过SN获取对应的外网IP地址
Bool Fun_DevGetNetIPBySN(char* ip, const char *uuid);

/*************************************************
 描述:跨网段设置设备配置，目前只支持对有线网络配置进行设置
 参数:
 bTempCfg[in]:       1临时保存,其他为永久保存
 pNetCfg[in]:       SNetCFG结构体地址
 szDeviceMac[in]:  设备Mac地址
 szDeviceSN[in]:   设备序列号
 szDevUserName[in]:设备登录用户名
 szDevPassword[in]:设备登录密码
 nTimeout[in]:       等待超时时间,单位毫秒
 异步返回，消息ID:EMSG_DEV_SET_NET_IP_BY_UDP（5143）
 *****************************************************/
int FUN_DevSetNetCfgOverUDP(UI_HANDLE hUser, Bool bTempCfg, SNetCFG *pNetCfg, const char *szDeviceMac, const char *szDeviceSN, const char *szDevUserName, const char *szDevPassword, int nTimeout = 4000, int nSeq = 0);

//---媒体有关的接口---
/////////////////////////////////////////// 媒体通道相关操作  ////////////////////////////////////////////////////
#ifdef OS_ANDROID
#define MEDIA_EX_PARAM void *pParam,
#define P_PARAM ,pParam
#else
#define MEDIA_EX_PARAM
#define P_PARAM
#endif
FUN_HANDLE FUN_MediaRealPlay(UI_HANDLE hUser, const char *szDevId, int nChnIndex, int nStreamType, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);

/**
 * @brief 实时预览接口
 * @details 接口支持一条媒体链接对应多路通道数据,不过设备如果不支持默认沿用原先的方式
 * @param szDevId 设备序列号
 * @param nChnIndex 通道号
 * @param nStreamType 码流类型
 * @param bEnableSharedMediaLink  共享媒体链接使能(仅支持同一码流类型) true:开（ps:前提是设备支持） false:关
 * @param hWnd 播放窗口对象
 * @param pParam 仅Android有效：对应JNIEnv
 * @return 播放操作句柄:开关音频、录像、抓图、停止播放等
 */
FUN_HANDLE FUN_MediaRealPlayEx(UI_HANDLE hUser, const char *szDevId, int nChnIndex, int nStreamType, bool bEnableSharedMediaLink, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);

FUN_HANDLE FUN_MediaNetRecordPlay(UI_HANDLE hUser, const char *szDevId, H264_DVR_FILE_DATA *sPlayBackFile, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);
FUN_HANDLE FUN_MediaNetRecordPlayByTime(UI_HANDLE hUser, const char *szDevId, H264_DVR_FINDINFO *sPlayBackFile, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);
FUN_HANDLE FUN_MediaRecordPlay(UI_HANDLE hUser, const char *szRecord, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);
FUN_HANDLE FUN_MediaLocRecordPlay(UI_HANDLE hUser, const char *szFileName, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);

FUN_HANDLE FUN_MediaCloudRecordPlay(UI_HANDLE hUser, const char *szDevId, int nChannel, const char *szStreamType, int nStartTime, int nEndTime, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);
/*******************设备相关接口**************************
 * 方法名: 云存储视频播放
 * 描  述: 云存储视频播放，缓存信息存在直接播放，否者会先查询云视频。
 * 返回值:[无]
 * 参  数:
 *      输入(in)
 *          [szDeviceId:设备序列号]
 *          [nChannel:通道号]
 *          [szStreamType:主辅码流 "Main"]
 *          [nStartTime:开始时间]// 短视频，某一时间点，开始时间往前推移5s，结束时间往后推移10s
 *          [nEndTime:结束时间]
 *          [sMessageType:消息类型：短视频：MSG_SHORT_VIDEO_QUERY_REQ，报警视频：MSG_ALARM_VIDEO_QUERY_REQ ]
 *          [bTimePoint:是否按时间点查询，TRUE/FALSE]
 *      输出(out)
 *          [无]
 * 结果消息：
 *          消息id:EMSG_START_PLAY = 5501,
 *                EMSG_ON_PLAY_BUFFER_BEGIN = 5516,   // 正在缓存数据
 *                EMSG_GET_DATA_END,          //4019
 ****************************************************/
FUN_HANDLE FUN_MediaCloudRecordPlayV2(UI_HANDLE hUser, const char *szDeviceId, int nChannel, const char *szStreamType, int nStartTime, int nEndTime, const char *sMessageType, Bool bTimePoint, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);

FUN_HANDLE FUN_MediaCloudRecordDownload(UI_HANDLE hUser, const char *szDeviceId, int nChannel, const char *szStreamType, int nStartTime, int nEndTime, const char *szFileName, int nSeq);

/*******************设备相关接口**************************
 * 方法名: 云存储视频下载
 * 描  述: 云存储视频下载，区分报警和短视频
 * 返回值:[无]
 * 参  数:
 *      输入(in)
 *          [szDeviceId:设备序列号]
 *          [nChannel:通道号]
 *          [szStreamType:主辅码流 "Main"]
 *          [nStartTime:开始时间]// 短视频，某一时间点，开始时间往前推移5s，结束时间往后推移10s
 *          [nEndTime:结束时间]
 *          [szFileName:下载文件缓存绝对路径]
 *          [sMessageType:消息类型：短视频：MSG_SHORT_VIDEO_QUERY_REQ，报警视频：MSG_ALARM_VIDEO_QUERY_REQ ]
 *          [bTimePoint:是否按时间点查询:TRUE/FALSE]
 *      输出(out)
 *          [无]
 * 结果消息：
 *          消息id:EMSG_ON_FILE_DOWNLOAD = 5116, 下载结果回调 param1:>=0成功，<0失败
 *                 EMSG_ON_FILE_DLD_COMPLETE = 5117:下载结束消息回调
 *                 EMSG_ON_FILE_DLD_POS = 5118 下载进度回调 param1：总大小（时间），param2：当前下载大小（时间）， param3:上一次进度（%d）
 *
 ****************************************************/
FUN_HANDLE FUN_MediaCloudRecordDownloadV2(UI_HANDLE hUser, const char *szDeviceId, int nChannel, const char *szStreamType, int nStartTime, int nEndTime, const char *szFileName, const char *sMessageType, Bool bTimePoint, int nSeq);

/**
 * @brief 云存储视频播放
 * @details 缓存信息存在直接播放，否者会先查询云视频。
 * @details 异步回调消息：1.播放成功：id:5501 param1: >=0 成功，否者失败 2. 正在缓冲数据：5516 3.播放结束：4019
 * @param hWnd 播放窗口对象
 * @param szReqJson 请求信息 参考如下：
 * @example
 * {
 *    "msg": "video_play", ///< 短视频: "short_video_play", 校验userid接口，必须携带userid(video_play_user、short_video_play_user)
 *    "sn": "14005d42a45417d7",
 *    "st": "2018-06-05 00:00:00",
 *    "et": "2018-06-05 23:59:59",
 *    "ch": 0,    ///<【可选】不填写此字段表示查询所有通道
 *    "label":["person","pet"], ///<【可选】标签数组，不传则不筛选，支持筛选多个
 *    "streamtype" : "Main" ///< 【可选】默认值"Main"  现在也只支持"Main"
 * }
 */
FUN_HANDLE Fun_MediaCloudStorageRecordPlay(UI_HANDLE hUser, const char *szReqJson, LP_WND_OBJ hWnd, void *pParam, int nSeq = 0);

/**
* @brief 云存储视频下载
* @details 异步回调消息：1.下载开始结果：id:5116 param1: >=0 成功，否者失败 \n
* 2. 下载进度回调：5118（param1：总大小（时间），param2：当前下载大小（时间）， param3:上一次进度（%d）） 3.下载结束消息回调：5117
* @param hWnd 播放窗口对象
* @param szReqJson 请求信息 参考如下：
* @example
* {
*    "msg": "video_download", ///< 短视频: "short_video_download", 校验userid接口，必须携带userid(video_download_user、short_video_download_user)
*    "sn": "14005d42a45417d7",
*    "st": "2018-06-05 00:00:00",
*    "et": "2018-06-05 23:59:59",
*    "ch": 0 ,   ///<【可选】不填写此字段表示查询所有通道
*    "label":["person","pet"], ///<【可选】标签数组，不传则不筛选，支持筛选多个
*    "streamtype" : "Main", ///< 【可选】默认值"Main"  现在也只支持"Main"
*    "filename" : "xxxx" ///< 下载文件缓存绝对路径
* }
*/
FUN_HANDLE Fun_MediaCloudStorageRecordDownload(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 多目云存储视频播放
 * @details 缓存信息存在直接播放，否者会先查询云视频。
 * @details 异步回调消息：1.播放成功：id:5501 param1: >=0 成功，否者失败 2. 正在缓冲数据：5516 3.播放结束：4019
 * @param hWnds 播放窗口对象数组
 * @param nViewCount 播放窗口对象数组个数
 * @param szReqJson 请求信息 参考如下：
 * @example
 * {
 *    "msg": "video_play", ///< 校验userid接口，必须携带userid(video_play_user)
 *    "sn": "14005d42a45417d7",
 *    "st": "2018-06-05 00:00:00",
 *    "et": "2018-06-05 23:59:59",
 *    "label":["person","pet"], ///<【可选】标签数组，不传则不筛选，支持筛选多个
 *    "streamtype" : "Main", ///< 【可选】默认值"Main"  现在也只支持"Main"
 *    "channellist"  ///< 播放的通道号数组  ps:传入的窗口句柄数量不能大于通道数组大小
 *    [
 *    	{
 *    		"channel":0, ///< 通道号
 *    		"seq":111, ///< 通道对应的SEQ值，和单通道播放类似
 *    		"user" : 1  ///< 通道对应的接收对象句柄值，和单通道播放类似
 *    	},
 *     {
 *    		"channel":1,
 *    		"seq":222,
 *    		"user" : 2
 *     }
 *    ]
 * }
 */
FUN_HANDLE Fun_MultiMediaCloudStorageRecordPlay(const char *szReqJson, LP_WND_OBJ hWnds, int nViewCount, void *pParam);

/**
 * @brief 多目云存储视频下载
 * @details 异步回调消息：1.下载开始结果：id:5116 param1: >=0 成功，否者失败 \n
 * 2. 下载进度回调：5118（param1：总大小（时间），param2：当前下载大小（时间）， param3:上一次进度（%d）） 3.下载结束消息回调：5117
 * @param szReqJson 请求信息 参考如下：
 * @example
 * {
 *    "msg": "video_download", ///< 校验userid接口，必须携带userid(video_download_user)
 *    "sn": "14005d42a45417d7",
 *    "st": "2018-06-05 00:00:00",
 *    "et": "2018-06-05 23:59:59",
 *    "label":["person","pet"], ///<【可选】标签数组，不传则不筛选，支持筛选多个
 *    "streamtype" : "Main", ///< 【可选】默认值"Main"  现在也只支持"Main"
 *    "channellist"  ///< 播放的通道号数组
 *    [
 *    	{
 *    		"channel":0, ///< 通道号
 *    		"seq":111, ///< 通道对应的SEQ值，和单通道播放类似
 *    		"user" : 1,  ///< 通道对应的接收对象句柄值，和单通道播放类似
 *    		"filename":"xxx0.mp4" ///< 下载文件缓存绝对路径
 *    	},
 *     {
 *    		"channel":1,
 *    		"seq":222,
 *    		"user" : 2,
 *    		"filename":"xxx1.mp4"
 *     }
 *    ]
 * }
 */
int Fun_MultiMediaCloudStorageRecordDownload(const char *szReqJson);

/**
 * @brief 获取媒体通道播放句柄
 * @details 多目多通道共享一路播放时，通过此接口获取某一通道操作句柄，用于抓图、录像等操作
 * @param hMultiPlayer 云存储视频播放函数返回值
 * @param nChannelIndex
 * @return  返回对应通道的播放操作句柄
 */
int Fun_GetMediaPlayerHandle(FUN_HANDLE hMultiPlayer, int nChannelIndex);

// 废弃接口FUN_MediaRtspPlay--20170805
//FUN_HANDLE FUN_MediaRtspPlay(UI_HANDLE hUser, const char * uuid, int mediaId, const char *szUrl, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq);
FUN_HANDLE FUN_MediaByVideoId(UI_HANDLE hUser, const char *szVideoId, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);
FUN_HANDLE Fun_MediaPlayXMp4(UI_HANDLE hUser, int hMp4File, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);

int FUN_MediaPlay(FUN_HANDLE hPlayer, int nSeq = 0);
int FUN_MediaPause(FUN_HANDLE hPlayer, int bPause, int nSeq = 0);
int FUN_MediaRefresh(FUN_HANDLE hPlayer, int nSeq = 0);
int FUN_MediaStop(FUN_HANDLE hPlayer, void *env = NULL);

int FUN_MediaSetPlaySpeed(FUN_HANDLE hPlayer, int nSpeed, int nSeq = 0);

/*******************设备相关接口**************************
 * 方法名: 设置播放倍速策略
 * 描  述: 设置播放倍速策略(SDK内部根据实际的播放倍速，解码速度，帧率等信息，进行相关策略处理)
 * 返回值:[无]
 * 参  数:
 *      输入(in)
 *          [hPlayer:播放操作句柄]
 *          [bEnable:使能开关  TRUE:开启 FALSE:关闭]
 *      输出(out)
 *          [无]
 ****************************************************/
int Fun_MediaSetPlaySpeedStrategy(FUN_HANDLE hPlayer, bool bEnable);

int FUN_MediaStartRecord(FUN_HANDLE hPlayer, const char *szFileName, int nSeq = 0); // 本地录像
int FUN_MediaStopRecord(FUN_HANDLE hPlayer, int nSeq = 0);
int FUN_MediaSnapImage(FUN_HANDLE hPlayer, const char *szFileName, int nSeq = 0); // 本地抓图
int FUN_MediaSeekToPos(FUN_HANDLE hPlayer, int nPos, int nSeq = 0);        // 0~100

/**
 * @brief 媒体文件进度跳转
 * @details 异步回调消息：5511 param1:>=0 成功，否者失败
 * @param hPlayer 操作句柄
 * @param nAddTime 从开始时间算起的秒值(duration)
 * @param nAbsTime 绝对时间 单位:秒
 */
int FUN_MediaSeekToTime(FUN_HANDLE hPlayer, int nAddTime, int nAbsTime, int nSeq);

// nAbsTime:绝对时间跳转到时间，单位毫秒
int FUN_MediaSeekToMSTime(FUN_HANDLE hPlayer, uint64 nMSecond, int nSeq);

int FUN_MediaSetSound(FUN_HANDLE hPlayer, int nSound, int nSeq = 0);    // -1表示静音 0～100表示音量
// EMSG_ON_MEDIA_SET_PLAY_SIZE 0:高清 1:标清 2:高清/标清 3:流畅(实时视频有效)
// 实时播放/云存储播放有效-(废弃？)
int FUN_MediaSetPlaySize(FUN_HANDLE hPlayer, int nType, int nSeq = 0);
// 获取当前播放的时间单位毫秒
uint64 FUN_MediaGetCurTime(FUN_HANDLE hPlayer);

// 调整显示的亮度(brightness)\对比度(contrast)\饱合度(saturation)\灰度(gray)(只影响显示，对原始视频数据无影响)
// 范围0~100；默认值为：50；-1表示不做调整，使用上次的配置
int FUN_MediaSetDisplayBCSG(FUN_HANDLE hPlayer, int nBrightness, int nContrast, int nSaturation, int nGray);

// 智能回放
// MSGID:EMSG_SET_INTELL_PLAY
// nTypeMask:EMSSubType
// nSpeed==0:取消智能快放
int Fun_MediaSetIntellPlay(FUN_HANDLE hPlayer, unsigned int nTypeMask, int nSpeed, int nSeq = 0);

// 更改播放显示窗口
int FUN_MediaSetPlayView(FUN_HANDLE hPlayer, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq);

/*******************媒体有关的接口**************************
 * 方法名: 更新当前播放窗口大小
 * 描  述: 上层窗口已经改变(例如横竖屏切换)，sdk有概率未能及时更新，使用此接口更新当前播放窗口大小
 * 返回值:
 * 参  数:
 *      输入(in)
 *          [无]
 *      输出(out)
 *          [无]
 * 结果消息：
 *         消息id:EMSG_MEDIA_UPDATE_UIVIEW_SIZE = 5538
 *         param1: >= 0 成功, < 0 失败，见错误码
 ****************************************************/
#ifdef OS_IOS
int FUN_MediaUpDateUIViewSize(FUN_HANDLE hPlayer, int nSeq);
#endif

/*******************媒体有关的接口**************************
* 方法名: 设置实时预览视频模式
* 描  述: 设置实时性优先(不用DSS用RPS/P2P)和稳定性优先(用DSS，保留现有逻辑，DSS优先)，
*         当前设备登录中会登出设备，没有登陆过，设置此参数会保存一个标志到本地缓存当前，之后的预览会按照此规则进行
 *         * 暂时不支持预览中调用此接口进行切换，必须先停止实时预览
* 返回值:
* 参  数:
*      输入(in)
*          [szDevId:设备序列号 / ip + port]
*          [nPlayModel : 0 实时性优先(不用DSS，用RPS/P2P) 1 稳定性优先(用DSS，保留现有逻辑)]
*           0: IP > RPS > P2P    1 : IP > RPS > DSS > P2P
*           RPS特殊情况 : 需要判断能力级是否支持RPS视频预览(SupportRPSVideo) & 是否支持第二路访问,低功耗设备和部分特殊定制，正常情况下第二路RPS访问视频会返回“122”
*      输出(out)
*          [无]
* 结果消息: [无]
****************************************************/
int FUN_MediaSetRealPlayModel(const char *szDevId, int nPlayModel);

// 函数返回值==PlayModel : 0 实时性优先(不用DSS，用RPS/P2P) 1 稳定性优先(用DSS，保留现有逻辑)
int FUN_MediaGetRealPlayModel(const char *szDevId);

const static char* kSaveMediaPrivateMixed = "private_mixed";  	///< 公司内部私有混合码流(包含音频、视频、信息帧等，仅支持实时预览和回放)
const static char* kSaveMediaStandardVideo = "standard_video";  ///< 标准视频码流(H264\H265等)
const static char* kSaveMediaStandardAudio = "standard_audio";  ///< 标准音频码流(G711A\AAC等)
/**
 * @brief 开始存储当前正在播放的媒体数据
 * @param hPlayer 当前播放操作句柄
 * @param szStorageInfoJson 存储信息, example: {"storage_list":[{"media_type":"private_mixed","file_name":"xxx/xxx_private.mixed"},{"media_type":"standard_video","file_name":"xxx/xxx_standard.video"},{"media_type":"standard_audio","file_name":"xxx/xxx_standard.audio"}]}
 * @return 异步回调消息 id:EMSG_START_STORE_PLAYING_MEDIA_DATA_INFO = 5560, ///< 开始存储当前正在播放的媒体数据  param1:>=0成功否者失败
 */
int Fun_StartStorePlayingMediaData(FUN_HANDLE hPlayer, const char *szStorageInfoJson);

/**
 * @brief 停止存储当前正在播放的媒体数据
 * @param hPlayer 当前播放操作句柄
 * @return 异步回调消息 id:EMSG_STOP_STORE_PLAYING_MEDIA_DATA_INFO = 5561, ///< 开始存储当前正在播放的媒体数据  param1:>=0成功否者失败
 */
int Fun_StopStorePlayingMediaData(FUN_HANDLE hPlayer);

//设置播放流畅度
int FUN_MediaSetFluency(FUN_HANDLE hPlayer, int nLevel, int nSeq);  // nLevel : EDECODE_TYPE
int FUN_MediaGetThumbnail(FUN_HANDLE hPlayer, const char *szOutFileName, int nSeq);
int FUN_MediaGetDecParam(const char *szFilePath, unsigned char *pOutBuffer, int nBufMaxSize);
int FUN_MediaGetFishParam(const char * szFilePath, FishEyeFrameParam * pInfo);

/*******************媒体有关的接口**************************
* 方法名: 获取mp4编解码类型
* 描  述: 通过保存在本地的mp4文件，获取mp4打包编解码类型
* 返回值:
*      [编解码类型] <0 错误值，详见错误码
*      			 2:H264 3:H265
* 参  数:
*      输入(in)
*          [szFilePath:文件绝对路径]
*      输出(out)
*          [无]
* 结果消息：无
****************************************************/
int FUN_MediaGetCodecType(const char *szFilePath);

/*******************媒体有关的接口**************************
* 方法名: 获取媒体视频真实时间范围
* 描  述: 通过保存在本地的媒体文件，获取实际的视频开始、结束时间（非总播放时间，而是通过xm码流私有格式获取的时间）
* 返回值:
*      [编解码类型] <0 错误值，详见错误码
* 参  数:
*      输入(in)
*          [sFilePath:媒体文件绝对路径]
*      输出(out)
*          [sDesMediaInfo:媒体结果信息，格式: "%s（开始时间）&&%s（结束时间）" ]
* 结果消息：无
****************************************************/
int Fun_MediaGetRealTime(const char *sSrcFilePath, char* sDesMediaInfo);

/*******************媒体有关的接口**************************
* 方法名: 将mp3文件解码为pcm文件
* 描  述: 将mp3文件解码为pcm文件 *pcm是音频文件最原始的格式，是没有经过任何压缩的，mp3文件是编码（压缩）后的音频文件
* 返回值: <0代表失败，详见错误码
* 参  数:
*      输入(in)
*          [sSrcFilePath:输入mp3文件绝对路径]
*          [sDesFilePath:解码输出的pcm文件绝对路径]
*          [nBitsPerSample:采样格式 bit]
*          [nSamplesPerSecond:采样率]
*          [nChannels:声道布局 单双通道 1/2]
*      输出(out)
*          [无]
* 结果消息：无
****************************************************/
int FUN_Mp3Decoder2PCM(const char *sSrcFilePath, const char *sDesFilePath, int nBitsPerSample, int nSamplesPerSecond, int nChannels);

/**
 * @brief 调节PCM音频音量大小
 * @details 只支持16bit数据
 * @param szBuf  PCM音频数据
 * @param nSize  数据大小
 * @param nRepeat 重复次数 通常设为1
 * @param nVol 增益倍数，可以小于1
 */
int Fun_RaisePCMVolume(char* szBuf, int nSize, int nRepeat, double nVol);

// 保存设备实时码流到本地文件夹
FUN_HANDLE FUN_DevSaveRealTimeStream(UI_HANDLE hUser, const char *szDevId, int nChannel, int nStreamType, const char *szFileName, int nSeq = 0);
int FUN_DevCloseRealTimeStream(FUN_HANDLE hSaveObj);

/*******************媒体有关的接口**************************
* 方法名: 设备实时码流数据返回
* 描  述: 设备实时码流数据返回（新建设备对象，可以和实时预览同步启用）
* 返回值:
* 参  数:
*      输入(in)
*          [szDevId:设备序列号]
*          [nChannel:通道号]
*          [nStreamType:主辅码流类型]
*      输出(out)
*          [无]
* 结果消息：
* 消息ID：EMSG_START_PLAY = 5501：start 结果返回 /
*       EMSG_DEV_RETURN_REAL_STREAM_START = 5537 ：媒体数据开始实时返回，dss密码错误返回（param1只有dss错误才会返回其他都是0
*       EMSG_ON_MEDIA_DATA = 5533：数据返回  {回调参数说明：param1：数据长度； param2：码流类型； param3：码流子类型 ；pData：媒体数据，包含header frame}
*码流类型：
*#define FRAME_TYPE_UNKNOWN		0
*#define FRAME_TYPE_VIDEO		1
*#define FRAME_TYPE_AUDIO		2
*#define FRAME_TYPE_DATA			3
*码流子类型：
*#define FRAME_TYPE_VIDEO_I_FRAME	0
*#define FRAME_TYPE_VIDEO_P_FRAME	1
*#define FRAME_TYPE_VIDEO_B_FRAME	2
*#define FRAME_TYPE_VIDEO_S_FRAME	3
*#define FRAME_TYPE_DATA_TEXT    5
*#define FRAME_TYPE_DATA_INTL    6
****************************************************/
FUN_HANDLE FUN_DevReturnRealStream(UI_HANDLE hUser, const char *szDevId, int nChannel, int nStreamType, int nSeq = 0);
int FUN_DevCloseReturnRealStream(FUN_HANDLE hRealObj);

FUN_HANDLE Fun_MediaPlayByURL(UI_HANDLE hUser, const char* strUrl, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);
FUN_HANDLE Fun_MediaPlayByURLEx(UI_HANDLE hUser, const char *szUrl, int nType, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);

/**
 * @brief 通过M3u8 url播放视频
 * @param szUrl 视频url地址
 * @details 异步回调消息：5501 播放成功  param1:>=0 成功，否者失败 param3:视频总时间\n
 * 						 5516 正在缓存数据，5517 缓冲结束，5509 播放结束。\n
 * 						 5508 回调播放信息(播放时间)，客户端收到第一个时间记录下来，后面的时间点通过与第一个时间相减，得到进度(或者收到一次此回调往后跳1秒)。。
 * @details 进度跳转只支持传秒值,从开始时间算起。 详见FUN_MediaSeekToTime;
 * @return 播放句柄，可以通过此句柄实现音频、进度跳转、快放、抓图、录像、关闭预览等功能
 */
FUN_HANDLE Fun_MediaPlayM3u8ByUrl(UI_HANDLE hUser, const char *szUrl, LP_WND_OBJ hWnd, MEDIA_EX_PARAM int nSeq = 0);

/**
 * @brief 通过M3u8 url下载视频
 * @param szUrl 视频url地址
 * @param szStorageFileName 本地存储文件绝对路径，通过后缀名决定下载的是MP4还是原始码流(h264、h265等包含XM私有头)
 * @details 异步回调消息：5116 下载结果回调 param1:>=0成功，<0失败 \n
 * 						 5117 下载结束消息回调 \n
 * 						 5118 下载进度回调 param1：总大小，param2：当前下载大小， param3:进度（%d）。
 * @return 下载句柄，可以通过此句柄停止下载
 */
FUN_HANDLE Fun_MediaDownloadM3u8ByUrl(UI_HANDLE hUser, const char *szUrl, const char *szStorageFileName, int nSeq = 0);

// 创建VRSoft句柄
void *Fun_VRSoft_Create();

#endif

/*******************媒体有关的接口**************************
* 方法名: 推送图片数据
* 描  述: 人脸图片数据推送功能
* 返回值:
*      [图片对象句柄，可用来实现数据接收停止等操作]
* 参  数:
*      输入(in)
*          [nChannel:设备通道号]
*		   [nImgType:需要的图片类型    *1：大图  2：小图  3：大小图]
*		   [nIntelType:图片类型 1:汽车牌照  2：人脸检测  3:车牌识别 4:人脸识别  其他值：全部类型]
*      输出(out)
*          [无]
* 结果消息：ID:EMSG_DEV_START_PUSH_PICTURE 开始成功返回结果, EMSG_ON_MEDIA_DATA 数据返回
****************************************************/
FUN_HANDLE FUN_DevStartPushFacePicture(UI_HANDLE hUser, const char *szDevId, int nChannel, int nImgType, int nIntelType, int nSeq = 0);

/*******************文件传输有关的接口**************************
* 方法名: 开启文件传输通用接口
* 描  述: 开启文件传输通用接口，将一些信息通过json传给设备
* 返回值:
*      [对象句柄，可用来关闭数据传输]
* 参  数:
*      输入(in)
*          [szDevId:设备序列号]
*		   [szJsons:json数据，上层组成，目前只有传输音频文件，以后可以传各种文件]
*		   [nTimeout:超时时间，如果传0，默认根据网络类型赋值]
*      输出(out)
*          [无]
* 结果消息： 开启文件传输
*       消息id:EMSG_DEV_START_FILE_TRANSFER = 5152
* 		param1: >= 0 成功, < 0 失败，见错误码
* 		param3: 设备操作ID：目前默认应该是 3500
* 		pData: json数据
****************************************************/
FUN_HANDLE FUN_DevStartFileTransfer(UI_HANDLE hUser, const char *szDevId, const char *szJsons, int nTimeout, int nSeq = 0);
/*******************文件传输有关的接口**************************
* 方法名: 文件传输通用接口
* 描  述: 发送文件数据给设备 数据最大值不要超过32K 1024 * 32 字节（音频可以双倍，G711A压缩一倍）
* 返回值:
*      [无]
* 参  数:
*      输入(in)
*          [pData:数据，可以是图片/音频/视频 根据开启传的文件类型]
*		   [nDataLen：数据长度]
*		   [nEndFlag:结束标志]
*		   [nTimeout:超时时间]
*      输出(out)
*          [无]
* 结果消息：
*       消息EMSG_DEV_FILE_DATA_TRANSFER = 5153
* 		param1: >= 0 成功, < 0 失败，见错误码
* 		param3: 设备操作ID：目前默认应该是 3502
* 		msg->pData: 失败返回json信息，例如多通道发送数据，发送结束返回操作失败的通道号（通道号从1开始计算）
****************************************************/
int FUN_DevFileDataTransfer(UI_HANDLE hUser, const char *szDevId, const char *pData, int nDataLen, int nEndFlag, int nTimeout, int nSeq = 0);
//增加接口兼容新老协议  *后面的协议支持同时多文件传输，所以增加参数nFileIndex，此参数是每次开始传输，设备返回当前文件index
int FUN_DevFileDataTransfersV2(UI_HANDLE hUser, const char *szDevId, const char *pData, int nDataLen, int nFileIndex, int nEndFlag, int nTimeout, int nSeq = 0);
void FUN_DevStopFileTransfer(FUN_HANDLE hPlayer);

/*******************文件传输有关的接口**************************
* 方法名: 文件接收通用接口
* 描  述: 文件接收通用接口
* 返回值:
*      [对象句柄，可用来关闭数据接收]
* 参  数:
*      输入(in)
*          [sDevId:设备id]
*		   [sJson：文件接收通用json格式]
*		   [nTimeout:超时时间]
*      输出(out)
*          [无]
* 结果消息：
*       消息	EMSG_DEV_START_FILE_DATA_RECV = 5160, // 开启文件接收
* 		param1: >= 0 成功, < 0 失败，见错误码
* 		msg->str():返回json信息
* 		开启成功后消息：
* 		EMSG_DEV_FILE_DATA_RECV = 5161, // 文件接收回传数据  参数：param1:nFileIndex 文件索引  param2：nCmdId 设备消息id, param3:结束标识,  pData：接收的数据
*		EMSG_ON_FILE_DLD_COMPLETE = 5117, // 文件数据接收结束标识
****************************************************/
int Fun_DevStartFileDataRecv(UI_HANDLE hUser, const char *sDevId, const char *sJson, int nTimeout = 15000, int nSeq = 0);

// ---设备有关公共接口---
// 获取推荐码流值
// 编码方式 分辨率 enum SDK_CAPTURE_COMP_t 7 : h264 8 : H265
// iResolution 分辨率 enum SDK_CAPTURE_SIZE_t
// iQuality    图像质量 1~6
// iGOP        描述两个I帧之间的间隔时间，1-12
// nFrameRate  帧率
// nVideoStd   视频制式 0 : P 1 : N
int DEV_GetDefaultBitRate(int nEncType, int iResolution, int iQuality, int iGOP, int nFrameRate, int nVideoStd = 0, int nDevType = EE_DEV_NORMAL_MONITOR);

// ---其它公共接口---
int GN_DeleteFiles(const char *szDir, long nDaysAgo, const char *szType);

// 获取*.私有码流缩略图
int FUN_GetMediaThumbnail(const char *szInFileName, const char *szOutFileName);

// 通过错误id获取错误提示信息
char* Fun_GetErrorInfoByEId(int nEId, char strError[512]);

// // 创建JPEG转MP4对象 返回操作够本Jpeg2Mp4Add-------EMSG_JPEG_TO_MP4_ON_PROGRESS：进度 arg1/arg2 当前/总大小 Fun_DestoryObj结束
// nBits可以默认写0，由底层自动判断
int FUN_Jpeg2Mp4_Create(UI_HANDLE hUser, const char *szDesFileName, int nFrameRate, int nBits, int nWidth, int nHeight);
int FUN_Jpeg2Mp4_Add(FUN_HANDLE hDecoder, const char *szFileName);
// 全部文件已经放进去了--EMSG_JPEG_TO_MP4_CLOSE,真正结束看EMSG_JPEG_TO_MP4_ON_PROGRESS
int FUN_Jpeg2Mp4_Close(FUN_HANDLE hDecoder);
// 中途取消EMSG_JPEG_TO_MP4_CANCEL
int FUN_Jpeg2Mp4_Cancel(FUN_HANDLE hDecoder);

int FUN_AddRefXMSG(XMSG *pMsg);            // 消息引用计数+1
int FUN_GetXMSG(XMSG *pMsg, MsgContent *pContent);            // 获取消息内容
void FUN_RelRefXMSG(XMSG *pMsg);        // 消息引用计数-1


/*******************艺能通 - IP广播**************************
* 方法名: 分区广播搜索
* 描  述: 分区广播进行设备搜索（可以多个同时进行搜索），接口不可以同时调用多次
* 返回值:
*      [无]
* 参  数:
*      输入(in)
*          [sGroupIds:分区id：多个分区使用；分隔 ， 搜索从1开始至16结束；-1：搜索未添加到分区的设备 255：搜索所有支持广播的设备，暂时先一个一个发搜索]
*		   [nTimeout:超时时间]
*      输出(out)
*          [无]
* 结果消息：
*       消息ID:	EMSG_GROUP_SEARCH_DEVICE_INFO = 5155, // 分区局域网广播搜索设备信息
* 		param1: >= 0 成功, < 0 失败，见错误码
* 		param3:
* 		msg->Str: 返回的分区设备信息
****************************************************/
int Fun_GroupSearchDevInfo(UI_HANDLE hUser, const char *sGroupIds, int nTimeout = 15000, int nSeq = 0);
/*******************艺能通 - IP广播**************************
* 方法名: 设备分区信息管理
* 描  述: 设备分区信息管理
* 返回值:
*      [无]
* 参  数:
*      输入(in)
*		   [nTimeout:超时时间]
*          [sJson:分区信息，包含设备ip，名称等信息，整个json上层传递吧，防止以后变更]
*      输出(out)
*          [无]
* 结果消息：
*       消息ID:	EMSG_GROUP_SET_DEV_INFO = 5156, // 分区局域网广播设置设备信息
* 		param1: >= 0 成功, < 0 失败，见错误码
****************************************************/
int Fun_GroupDevSetInfo(UI_HANDLE hUser, const char *sJson, int nTimeout = 5000, int nSeq = 0);
/*******************艺能通 - IP广播**************************
* 方法名: 分区音频广播数据发送
* 描  述: 分区音频广播数据发送   *只有发送数据走udp广播，开启/关闭都是走tcp协议对单个ipc进行的操作，json协议传输udp端口，分区id给设备，设备打开相应的端口进行数据接收等待。
* 返回值:
*      [无]
* 参  数:
*      输入(in)
*		   [pData:音频数据，上层自行转换成g711数据]
*		   [nDataLen:数据大小]
*		   [nEndFlag:发送结束标识]
*		   [nTimeout:超时时间]
*      输出(out)
*          [无]
* 结果消息：[无]
****************************************************/
int Fun_SendDataRadioOperation(const char *pData, int nDataLen, int nUdpPort, int nEndFlag, int nTimeout = 15000);

// 对外提供pcm转g711接口， 可以转g711a/g711u类型的  nType：0 --> g711u， 1 --> g711a
int Fun_PcmEncodeToG711(char *sSrcData, unsigned char *sDestData, int srclen, int nType);

#ifdef SUP_MEDIA_SUPER_RESOLUTION
// 初始化超分， 加载模型， 初始化超分线程    *多次调用无效，和UnInitSuperResolution一一对应
#ifdef OS_IOS
int Fun_InitSuperResolution();
#endif
#ifdef OS_ANDROID
int Fun_InitSuperResolution(AAssetManager* pMgr);
#endif

// 注销超分 ， 关闭超分线程 *和InitSuperResolution一一对应，多次调用无效
int Fun_UnInitSuperResolution();
// 超分库版本信息获取
int Fun_GetVersionSuperResolution(char *sVersionInfo);

/*******************超分（超级分辨率）**************************
* 方法名: 开启实时预览超分
* 描  述: 开启实时预览超分 *需要调用InitSuperResolution
* 返回值:
*      [< 0 失败，见错误码]
* 参  数:
*      输入(in)
*		   [nSrWidth:超分宽度]   目前只支持1408
*		   [nSrHeight:超分高度]  目前只支持1152
 *		   [nMode:超分类型  *0 快速超分  1 慢速超分]
*      输出(out)
*          [无]
* 结果消息：
*       消息ID:	EMSG_START_REAL_PLAY_SUPER_RESOLUTION = 5543, // 开启实时预览超分处理
* 		param1: >= 0 成功, < 0 失败，见错误码
****************************************************/
int Fun_StartRealplaySuperResolution(FUN_HANDLE hPlayer, int nSrWidth, int nSrHeight, int nSrMode, int nSeq = 0);
int Fun_StopRealplaySuperResolution(FUN_HANDLE hPlayer);
// 抓图超分处理
// 逻辑： 当前实时预览未开启超分模式 --> 抓图：原始缓存yuv数据，再进行超分处理（while，超时时间1s）
//        当前实时预览开启超分模式 --> 抓图：直接是当前预览超分yuv缓存数据
int FUN_SnapImageSuperResolution(FUN_HANDLE hPlayer, const char *sFileName, int nSrWidth, int nSrHeight, int nSrMode, int nSeq = 0); // 本地抓图
// 当前YUV420数据超分  最长超时时间（阻塞）一秒
int Fun_OnYUV420PSuperResolution(int nWidth, int nHeight, char* pRGBData, int nSrWidth, int nSrHeight, char* pSrRGBData, int nSrMode);
// 清空超分缓存
int FUN_ClearCacheSuperResolution();
#endif

/**
 * @brief Ping指定域名
 * @param pServerAddr 目标域名
 * @param ifUseIPv6 是否优先使用ipv6
 * @param ping的次数，默认六次
 * @details 异步回调消息：id:EMSG_SYS_NET_PING = 8901 , str:Ping的结果
 */
int Fun_Ping(UI_HANDLE hUser, const char *pServerAddr, Bool ifUseIPv6, int nPingTimes = 6,int nSeq = 0);

/**
 * @brief 创建MQTT客户端和指定服务器交互
 * @param hUser 消息接收对象
 * @param pPacketName 包名,用于mqtt组建ClientID
 * @param ninterval MQTT客户端心跳时间间隔（单位：毫秒）
 * @details 异步回调消息：id:EMSG_SYS_MQTT_CLIENT = 8921
 */
int Fun_MQTTInit(UI_HANDLE hUser, const char *pPacketName, int nInterval = 10000,int nSeq = 0);

/**
 * @brief 反初始化MQTT客户端
 * @param hUser 消息接收对象
 * @details 异步回调消息：id:EMSG_SYS_MQTT_CLIENT
 */
int Fun_MQTTUnInit(UI_HANDLE hUser, int nSeq = 0);

/**
 * @brief 订阅状态推送
 * @param hUser 消息接收对象
 * @param szSubscribeJson 请求订阅的设备信息及内容---支持批量
 * @param nSeq 自定义值
 * @return >=0:成功;<0:失败
 * @detail Json格式如下：
 *{
 *	"SubscribeInfo": "",
 *	"Sn": ["", ""]
 *}
 * @details 异步回调消息：id EMSG_SYS_MQTT_RETURNMSG =8929, str:TOPIC name，Object：字节流json内容，形如：
 {
   "serverName":"RPS",
   "sn":"134232dcbd3bfcae",
   "status":"online",
   "timestamp":1694086194967
}
*/
int Fun_SubscribeInfoFromServer(UI_HANDLE hUser, const char* szSubscribeJson, int nSeq);

/**
 * @brief 取消订阅状态推送(暂时一次只支持取消订阅一种内容)
 * @param hUser 消息接收对象
 * @param szUnSubscribeJson 请求取消订阅的设备信息及内容---支持批量
 * @param nSeq 自定义值
 * @return >=0:成功;<0:失败
 * @detail Json格式如下：
 *{
 *	"SubscribeInfo": "",
 *	"Sn": ["", ""]
 *}
 * @details 异步回调消息：如Fun_SubscribeInfoFromServer
*/
int Fun_UnSubscribeInfoFromServer(UI_HANDLE hUser, const char* szUnSubscribeJson, int nSeq);

/**
 * @brief 日志服务HTTP接口
 * @param szReqExJson 要求包含Url和其他请求json内容
 *  {
 *	"Url": "/api/pub/v1/data",
 *	“ReqJson”：
 *	      {
 *        id: 对象关键信息，如：用户ID或设备序列号（支持同区域下多选），CFG 根据此设备序列号判断设备所属区域，并到指定区域查询数据(必选)
 *	      endTime :"2024-05-07 11:08:03.000"
 *        id:"ed2a51e49ef6ab1e"
 *        page: 1
 *        size:6000
 *        startTime:“2024-05-06 11:08:03.000'
 *        subtype: null
 *        timezoneMin:480
 *        type: "devicelog'
 *	      }
 *  }
 * @param nTimeout 超时时间(单位:ms)
 * @return 异步回调消息：日志服务HTTP请求结果：id:EMSG_SYS_SERVICE_GET_LOGS = 8934, ///< HTTP日志服务请求
 *
 */
int Fun_SysGetLogs(UI_HANDLE hUser, const char *szReqExJson, int nTimeout = 10000,int nSeq = 0);

/**
 * @brief AI服务相关功能接口
 * @details 数据投传
 * @param szReqJson 请求内容(JSON格式)
 * @example
 * {
 *   timeout": 5000, ///< 超时时间，默认5000ms
 *   "http_params":
 *   {
 *     "url": "",  ///< http请求的url，
 *     "method": "POST", ///< http请求的类型：GET、POST
 *     "content":  ///< 请求的内容
 *     {
 *     }
 *   }
 * }
 * @return  异步回调消息ID：EMSG_SYS_AI_SERVICE = 8935, ///< AI服务数据回调  param1:>=0成功否者失败 Str:结果数据回调
 */
int Fun_SysAIService(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 实时预览返回的打开网络模式
 */
typedef enum DEV_NET_CNN_TYPE
{
    NET_TYPE_P2P = 0,
    NET_TYPE_SERVER_TRAN = 1,
    NET_TYPE_IP = 2,
    NET_TYPE_DSS = 3,
    NET_TYPE_TUTK = 4,  // Connected type is TUTK
    NET_TYPE_RPS = 5,  //(可靠的代理服务)
    NET_TYPE_RTC_P2P = 6,      // WebRTC-P2P
    NET_TYPE_RTC_PROXY = 7, // WebRTC-Transport
    NET_TYPE_P2P_V2 = 8,      // P2PV2
    NET_TYPE_PROXY_V2 = 9,  // ProxyV2
	NET_TYPE_XTS_P2P = 10,
	NET_TYPE_XTS_PROXY = 11,
	NET_TYPE_XTC_P2P = 12,
	NET_TYPE_XTC_PROXY = 13,
	NET_TYPE_RPS_GWM = 14,
    NET_TYPE_MAX_SIZE,
}DEV_NET_CNN_TYPE;

typedef enum EUIMSG
{
    EMSG_APP_ON_CRASH = 119,
    
    EMSG_SYS_GET_DEV_INFO_BY_USER = FUN_USER_MSG_BEGIN_1, // 获取设备信息
    EMSG_SYS_USER_REGISTER,        // 注册用户
    EMSG_SYS_PSW_CHANGE = FUN_USER_MSG_BEGIN_1 + 3,        // 修改用户密码
    EMSG_SYS_ADD_DEVICE,        // 增加用户设备
    EMSG_SYS_CHANGEDEVINFO,        // 修改用户设备信息
    EMSG_SYS_DELETE_DEV,        // 删除设备
    EMSG_SYS_GET_DEV_STATE = FUN_USER_MSG_BEGIN_1 + 9,        // 获取设备状态
    
    EMSG_SYS_GET_PHONE_CHECK_CODE = 5010, // 获取手机验证码(用户注册时使用)
    EMSG_SYS_REGISER_USER_XM = 5011,      // 用户注册
    EMSG_SYS_GET_DEV_INFO_BY_USER_XM = 5012, // 同步登录
    EMSG_SYS_EDIT_PWD_XM = 5013,      // 修改用户登录密码
    EMSG_SYS_FORGET_PWD_XM = 5014,      // 忘记用户登录密码
    EMSG_SYS_REST_PWD_CHECK_XM = 5015,  // 验证验证码
    EMSG_SYS_RESET_PWD_XM = 5016,       // 重置用户登录密码
    EMSG_SYS_DEV_GET_PUBLIC = 5017,     // 获取用户公开设备列表
    EMSG_SYS_DEV_GET_SHARE = 5018,      // 获取用户共享设备列表
    EMSG_SYS_DEV_PUBLIC = 5019,         // 公开设备
    EMSG_SYS_DEV_SHARE = 5020,          // 分享设备(分享视频)
    EMSG_SYS_DEV_CANCEL_PUBLIC = 5021,  // 取消公开设备
    EMSG_SYS_DEV_CANCEL_SHARE = 5022,   // 取消分享设备
    EMSG_SYS_DEV_REGISTER = 5023,         // 设备注册
    EMSG_SYS_DEV_COMMENT = 5024,         // 发表评论
    EMSG_SYS_DEV_GET_COMMENT_LIST = 5025,//获取评论列表
    EMSG_SYS_DEV_GET_VIDEO_INFO = 5026,  //获取视频信息
    EMSG_SYS_DEV_UPLOAD_VIDEO = 5027,  // 上传本地视频
    EMSG_SYS_GET_USER_PHOTOS = 5028,   // 获取用户相册列表
    EMSG_SYS_CREATE_USER_PHOTOS = 5029,// 创建用户相册
    EMSG_SYS_UPLOAD_PHOTO = 5030,      // 上传图片
    EMSG_SYS_DEIT_PHOTO = 5031,        // 图片文件编辑
    EMSG_SYS_GET_VIDEO_LIST = 5032,    // 获取短片视频列表
    EMSG_SYS_DEV_EDIT_VIDEO = 5033,    // 短片视频编辑
    EMSG_SYS_GET_PHOTO_LIST = 5034,    // 图片文件列表
    EMSG_SYS_DEV_DELETE_VIDEO = 5035,  // 删除短片视频
    EMSG_SYS_DELETE_PHOTO = 5036,      // 删除图片
    EMSG_SYS_DELETE_PHOTOS = 5037,     // 删除相册
    
    EMSG_SYS_GETPWBYEMAIL = 5038,      // 通过邮箱找回密码
    EMSG_SYS_CHECK_PWD_STRENGTH = 5039, // 检测密码合法性及强度
    EMSG_SYS_CHECK_DEVIDE_REAL = 5040, // 检测产品正品否
    EMSG_SYS_SEND_EMAIL_CODE = 5041,     // 发送邮箱验证码
    EMSG_SYS_REGISTE_BY_EMAIL = 5042,  // 邮箱注册
    EMSG_SYS_SEND_EMAIL_FOR_CODE = 5043, // 发送邮箱验证码（修改密码、重置密码）
    EMSG_SYS_CHECK_CODE_FOR_EMAIL = 5044,// 验证邮箱验证码（修改密码、重置密码）
    EMSG_SYS_PSW_CHANGE_BY_EMAIL = 5045, // 通过邮箱修改密码（重置密码）
    EMSG_SYS_CHECK_USER_REGISTE = 5046, // 检测用户名是否已注册
    EMSG_SYS_LOGOUT = 5047, // 同步退出
    EMSG_SYS_NO_VALIDATED_REGISTER = 5048, // 无需验证注册
    EMSG_SYS_GET_USER_INFO = 5049, // 获取用户信息
    EMSG_SYS_SEND_BINDING_PHONE_CODE = 5050, // 绑定安全手机(1)—发送验证码
    EMSG_SYS_BINDING_PHONE = 5051, // 绑定安全手机(2)—验证code并绑定
    
    EMSG_SYS_CLOUDUPGRADE_CHECK = 5052, //5052  设备是否需要升级查询
    EMSG_SYS_CLOUDUPGRADE_DOWNLOAD = 5053, //5053 设备云升级下载
    EMSG_SYS_SEND_BINDING_EMAIL_CODE = 5054, // 绑定安全邮箱(1)—发送验证码
    EMSG_SYS_BINDING_EMAIL = 5055, // 绑定安全邮箱(2)—验证code并绑定
    EMSG_SYS_REGISER_USER_XM_EXTEND = 5056,      // 用户注册(Extend)
    EMSG_SYS_REGISTE_BY_EMAIL_EXTEND = 5057,  // 邮箱注册(Extend)
    EMSG_SYS_NO_VALIDATED_REGISTER_EXTEND = 5058, // 无需验证注册(Extend)
    
    EMSG_SYS_STOP_CLOUDUPGRADE_DOWNLOAD = 5059, //停止下载
    EMSG_SYS_ADD_DEV_BY_FILE = 5060,            //通过文件添加设备-本地登陆使用
    EMSG_SYS_GET_DEV_INFO_BY_USER_INSIDE = 5061,  //内部获取设备列表，用于android报警推送
    EMSG_SYS_GET_DEVLOG = 5062,                    // 获取设备端日志，并上传到服务器
    EMSG_SYS_GET_DEVLOG_END = 5063,                // 获取设备端日志，并上传到服务器
    EMSG_SYS_WX_ALARM_LISTEN_OPEN = 5064,         // 开启微信报警监听
    EMSG_SYS_WX_ALARM_LISTEN_CLOSE = 5065,        // 关闭微信报警监听
    EMSG_SYS_WX_ALARM_WXPMSCHECK = 5066,          // 微信报警状态查询
    EMSG_SYS_CHECK_CS_STATUS     = 5067,          // 实时从服务器上查询云存储状态
    EMSG_SYS_DULIST     = 5068,                   // 获取设备所在的帐户信息
    EMSG_SYS_MDSETMA    = 5069,                   // 指定设备的主帐户
    EMSG_SYS_MODIFY_USERNAME = 5070,              // 修改登录用户名（只能修改微信等绑定帐户自动生成）
    EMSG_SYS_ON_DEV_STATE = 5071,                 // 设备状态变化通知
    EMSG_SYS_IS_MASTERMA = 5072,                  // 获取当前账号是否为该设备的主账号
    EMSG_SYS_GET_ABILITY_SET = 5073,              // 从服务器端获取设备能力集
    EMSG_SYS_CHECK_DEV_VALIDITY = 5074,           // 在服务器端验证设备校验码合法性
	EMSG_SYS_CANCELLATION_USER_XM = 5075,		  // 注销用户账号
	EMSG_SYS_GET_LOGIN_ACCOUNT_CODE = 5076,		  // 获取登陆账户验证码
	EMSG_SYS_GET_DEV_INFO_BY_SMS = 5077,		  // 短信验证获取设备列表
	EMSG_SYS_USER_WX_UNBIND = 5078, 			  // 微信用户解除绑定
	EMSG_SYS_THIRD_PARTY_BINDING_ACCOUNT = 5079,  // 第三方绑定账户
    EMSG_SYS_FACE_CHECK_OCX = 5080,  // 云平台app证书合法性校验
    EMSG_SYS_GET_PHONE_SUPPORT_AREA_CODE = 5081,  // 获取支持手机验证的全球区号
    EMSG_SYS_SEND_GLOBAL_PHONE_CODE = 5082, // 全球国家区域手机短信验证
    EMSG_SYS_THIRD_PARTY_ALARM_LISTEN_OPEN = 5083,         // 开启第三方报警监听
    EMSG_SYS_THIRD_PARTY_ALARM_LISTEN_CLOSE = 5084,        // 关闭第三方报警监听
    EMSG_SYS_THIRD_PARTY_ALARM_STATE_CHECK = 5085,          // 第三方报警状态查询
    EMSG_SYS_VMS_CLOUD_GET_DEV_LIST = 5086, // 轻量化监控平台设备列表获取
    EMSG_SYS_GET_CFGS_FROM_SHADOW_SERVER = 5087, // 通过影子服务器批量获取配置
    EMSG_SYS_SHADOW_SERVER_CFGS_CHANGE_NOTIFY = 5088, // 影子服务设备配置状态变化通知
	EMSG_SYS_GET_DEV_CAPABILITY_SET = 5089, // 获取设备能力集  用来替代EMSG_SYS_GET_ABILITY_SET
	EMSG_SYS_UPDATE_DEV_LOGIN_TOKEN_TO_TCS = 5090, ///< 更新设备登录令牌到TCS(令牌管理中心服务)
	EMSG_SYS_GET_DEV_LOGIN_TOKEN_FROM_TCS = 5091, ///< 从TCS(令牌管理中心服务)获取设备登录令牌
	EMSG_SYS_BATCH_GET_DEV_CAPABILITY_SET = 5092, /** 批量获取设备能力集  */
    EMSG_SYS_GET_CURRENT_USER_DEV_LIST = 5093,//获取当前用户设备列表
	EMSG_SYS_GET_DEV_ENC_TOKEN_FORM_RS = 5094, ///< 获取设备登录令牌信息
	EMSG_SYS_SET_DEV_ENC_TOKEN_FORM_RS = 5095, ///< 保留，暂时未使用
	EMSG_SYS_CHECK_UPGRADE_FOR_SERVER = 5096, ///< 通过服务器检测升级
	EMSG_SYS_SEND_EMAIL_LINK_TO_REGISTER_USER = 5097, ///< 发送链接邮件用于注册用户
	// 5098 日志信息回调
	EMSG_SYS_CHECK_USER_IS_ACTIVATED = 5099, ///< 检测用户是否已激活
	EMSG_SYS_SEND_EMAIL_LINK_TO_RESET_PASSWORD = 5201, ///< 发送链接邮件用于重置密码
	EMSG_SYS_CHECK_RESET_PASSWORD_IS_ACTIVATED = 5202, ///< 检测邮箱重置密码链接是否激活
	EMSG_SYS_APP_INFO_SAVE = 5203, ///< 保存APP相关信息
	EMSG_SYS_APP_INFO_QUERY = 5204, ///< 获取APP相关信息
	EMSG_SYS_MODIFY_ACCOUNT_NICKNAME = 5205, ///< 修改云账户昵称
	EMSG_SYS_GET_PHONE_SUPPORT_AREA_CODE_AND_URL = 5206,  ///< 获取支持手机验证的全球区号和区域URL
    EMSG_SYS_CLOUD_ACCOUNT_LOGTIN = 5207, ///< 云账户登录
    EMSG_SYS_THIRD_PARTY_ACCOUNT_LOGTIN = 5208, ///< 第三方登录
    EMSG_SYS_PHONE_SMS_LOGTIN = 5209, ///< 手机短信登录
	EMSG_SYS_QUERY_DEVS_STATUS = 5210, ///< 批量查询多个设备多个服务状态
    EMSG_SYS_BATCH_DELETE_DEVS = 5211, ///< 批量删除设备;
	EMSG_SYS_LOCAL_PHONE_LOGIN = 5212, ///< 本机号码一键登录并获取设备列表

    EMSG_XM030_VIDEO_LOGIN = 8601,
    EMSG_XM030_VIDEO_LOGOUT = 8602,

	EMSG_SYS_START_DOWNLOAD_UPGRADE_FILEE_FOR_SERVER = 8605, ///< 开始从服务器下载升级固件
	EMSG_SYS_DOWNLOAD_UPGRADE_FILE_PROGRESSE_FOR_SERVER = 8606, ///< 返回服务器下载升级固件进度
	EMSG_SYS_STOP_DOWNLOAD_UPGRADE_FILEE_FOR_SERVER = 8607, ///< 停止从服务器下载升级固件
    
    EMSG_APP_ON_SEND_LOG_FILE  = 5098,    // 日志信息回调
    EMSG_APP_LOG_OUT  = 5098,    // 日志信息回调
    
    EMSG_DEV_GET_CHN_NAME = FUN_USER_MSG_BEGIN_1 + 100,
    EMSG_DEV_FIND_FILE = 5101,
    EMSG_DEV_FIND_FILE_BY_TIME = 5102,
    EMSG_DEV_ON_DISCONNECT = 5103,
    EMSG_DEV_ON_RECONNECT = 5104,
    EMSG_DEV_PTZ_CONTROL = 5105,
    EMSG_DEV_AP_CONFIG = 5106,
    EMSG_DEV_GET_CONFIG = 5107,
    EMSG_DEV_SET_CONFIG = 5108,
    EMSG_DEV_GET_ATTR = 5109,
    EMSG_DEV_SET_ATTR = 5110,
    EMSG_DEV_START_TALK = 5111,
    EMSG_DEV_SEND_MEDIA_DATA = 5112,
    EMSG_DEV_STOP_TALK = 5113,
    EMSG_ON_DEV_DISCONNECT = 5114,
    EMSG_ON_REC_IMAGE_SYN = 5115, // 录像索引图片同步 param1 == 0：同步进度 总图片\已经同步图片
    // param1 == 1：param2 == 0  同步的数目
    EMSG_ON_FILE_DOWNLOAD = 5116,
    EMSG_ON_FILE_DLD_COMPLETE = 5117,
    EMSG_ON_FILE_DLD_POS = 5118,
    EMSG_DEV_START_UPGRADE = 5119,       // param0表示表示结果
    EMSG_DEV_ON_UPGRADE_PROGRESS = 5120, // param0==EUPGRADE_STEP
    // param1==2表示下载或升级进度或升级结果;
    // 进度0~100; 结果->0：成功  < 0 失败    200:已经是最新的程序
    EMSG_DEV_STOP_UPGRADE = 5121,
    EMSG_DEV_OPTION = 5122,
    EMSG_DEV_START_SYN_IMAGE = 5123,
    EMSG_DEV_STOP_SYN_IMAGE = 5124,
    EMSG_DEV_CHECK_UPGRADE = 5125,     // 检查设备升级状态,parma1<0:失败;==0:当前已经是最新程序;1:服务器上有最新的升级程序;2:支持云升级;
    EMSG_DEV_SEARCH_DEVICES = 5126,
    EMSG_DEV_SET_WIFI_CFG = 5127,
    EMSG_DEV_GET_CONFIG_JSON = 5128,
    EMSG_DEV_SET_CONFIG_JSON = 5129,
    EMSG_DEV_ON_TRANSPORT_COM_DATA = 5130,
    EMSG_DEV_CMD_EN = 5131,
    EMSG_DEV_GET_LAN_ALARM = 5132,
    EMSG_DEV_SEARCH_PIC = 5133,
    EMSG_DEV_SEARCH_PIC_STOP = 5134,
    EMSG_DEV_START_UPLOAD_DATA = 5135,
    EMSG_DEV_STOP_UPLOAD_DATA = 5136,
    EMSG_DEV_ON_UPLOAD_DATA = 5137,
    EMSG_ON_CLOSE_BY_LIB = 5138,
    EMSG_DEV_LOGIN = 5139,
    EMSG_DEV_BACKUP = 5140,
    EMSG_DEV_SLEEP = 5141,
    EMSG_DEV_WAKE_UP = 5142,
    EMSG_DEV_SET_NET_IP_BY_UDP = 5143,
#ifdef SUP_PREDATOR
	EMSG_DEV_PREDATOR_FILES_OPERATION = 5144, //捕食器文件操作
	EMSG_DEV_PREDATOR_SEND_FILE = 5145, //捕食器文件传输
	EMSG_DEV_PREDATOR_FILE_SAVE = 5146, //捕食器文件保存
#endif
	EMSG_DEV_START_PUSH_PICTURE = 5147, // 开始推图
	EMSG_DEV_STOP_PUSH_PICTURE = 5148, // 停止推图
	EMSG_DEV_MAIN_LINK_KEEP_ALIVE = 5149, // 从后台切回app，主链接检测，保活
	EMSG_DEV_CONFIG_JSON_NOT_LOGIN = 5150, // 设备配置获取，设置(Json格式，不需要登陆设备)
	EMSG_DEV_GET_CONNECT_TYPE = 5151, // 获取设备网络状态   XTS/C每次都要重新去服务器获取网络类型
	EMSG_DEV_START_FILE_TRANSFER = 5152, // 开启文件传输
	EMSG_DEV_FILE_DATA_TRANSFER = 5153, // 传输文件数据
	EMSG_DEV_STOP_FILE_TRANSFER = 5154, // 关闭文件传输
    
	EMSG_GROUP_SEARCH_DEVICE_INFO = 5155, // 分区局域网广播搜索设备信息
	EMSG_GROUP_SET_DEV_INFO = 5156, // 分区局域网广播设置设备信息
    EMSG_GROUP_SEND_DATA_RADIO_OPERATION = 5157, // 发送实时音频广播数据

	EMSG_DEV_START_FILE_DATA_RECV = 5160, // 开启文件接收
	EMSG_DEV_FILE_DATA_RECV = 5161, // 文件接收回传
	EMSG_DEV_STOP_FILE_DATA_RECV = 5162, // 关闭文件接收

    EMSG_DEV_START_UPGRADE_IPC = 5163,       // IPC开始升级
    EMSG_DEV_ON_UPGRADE_IPC_PROGRESS = 5164, // IPC升级信息回调
    EMSG_DEV_STOP_UPGRADE_IPC = 5165, // IPC升级停止

    EMSG_DEV_ERROR_CODE_MONITOR = 5166, // 设备错误码监听回调
    
    EMSG_DEV_REPORT_IMPORTANT_INFO_REQ = 5167, ///< 设备重要消息上报

    EMSG_SET_PLAY_SPEED = FUN_USER_MSG_BEGIN_1 + 500,
    EMSG_START_PLAY = 5501,
    EMSG_STOP_PLAY = 5502,
    EMSG_PAUSE_PLAY = 5503,
    
    EMSG_MEDIA_PLAY_DESTORY = 5504,        // 媒体播放退出,通知播放对象
    EMSG_START_SAVE_MEDIA_FILE = 5505,        // 保存录像,保存格式用后缀区分,.dav私有;.avi:AVI格式;.mp4:MP4格式
    EMSG_STOP_SAVE_MEDIA_FILE = 5506,        // 停止录像
    EMSG_SAVE_IMAGE_FILE = 5507,            // 抓图,保存格式用后缀区分,.bmp或.jpg
    EMSG_ON_PLAY_INFO = 5508,          // 回调播放信息
    EMSG_ON_PLAY_END = 5509,           // 录像播放结束
    EMSG_SEEK_TO_POS = 5510,
    EMSG_SEEK_TO_TIME = 5511,
    EMSG_SET_SOUND = 5512,                 // 打开，关闭声音
    EMSG_ON_MEDIA_NET_DISCONNECT = 5513,   // 媒体通道网络异常断开
    EMSG_ON_MEDIA_REPLAY = 5514,        // 媒体重新播放
    EMSG_START_PLAY_BYTIME = 5515,
    EMSG_ON_PLAY_BUFFER_BEGIN = 5516,   // 正在缓存数据
    EMSG_ON_PLAY_BUFFER_END = 5517,     // 缓存结束,开始播放
    EMSG_ON_PLAY_ERROR = 5518,          // 回调播放异常,长时间没有数据
    EMSG_ON_SET_PLAY_SPEED = 5519,      // 播放速度
    EMSG_REFRESH_PLAY = 5520,
    EMSG_MEDIA_BUFFER_CHECK = 5521,     // 缓存检查
    EMSG_ON_MEDIA_SET_PLAY_SIZE = 5522, // 设置高清/标清
    EMSG_ON_MEDIA_FRAME_LOSS = 5523,    // 超过4S没有收到数据
    EMSG_ON_YUV_DATA = 5524,             // YUV数据回调
    EMSG_MEDIA_SETPLAYVIEW = 5525,        // 改变显示View
    EMSG_ON_FRAME_USR_DATA = 5526,        // 用户自定义信息帧回调
    EMSG_ON_Media_Thumbnail = 5527,     // 抓取视频缩略图
    EMSG_ON_MediaData_Save = 5528,        // 媒体数据开始保存
    EMSG_MediaData_Save_Process = 5529, // 媒体数据已保存大小
    EMSG_Stop_DownLoad = 5530,            //停止下载
    EMSG_START_IMG_LIST_DOWNLOAD = 5531,//图像列表下载
    EMSG_SET_INTELL_PLAY = 5532,   // 智能播放
    EMSG_ON_MEDIA_DATA = 5533,        //解码前数据回调
    EMSG_DOWN_RECODE_BPIC_START =  5534,    //录像缩略图下载开始
    EMSG_DOWN_RECODE_BPIC_FILE  =  5535,    //录像缩略图下载--文件下载结果返回
    EMSG_DOWN_RECODE_BPIC_COMPLETE =  5536, //录像缩略图下载-下载完成（结束）
	EMSG_DEV_RETURN_REAL_STREAM_START = 5537, // 媒体数据开始实时返回
    EMSG_MEDIA_UPDATE_UIVIEW_SIZE = 5538,   // 更新显示窗口宽高
    EMSG_MEDIA_CLOUD_PLAY_REAL_TOTAL_TIMES = 5539, // 云视频播放回传实际视频播放总时长
    EMSG_GET_XTSC_CONNECT_QOS = 5540, // XTSC实时链接传输效率
    EMSG_ON_AUDIO_FRAME_DATA = 5541, // 音频相关信息返回
    EMSG_GET_ALL_DECODER_FRAME_BITS_PS = 5542, // 统计所有decoder对象累加的码流平均值,即当前播放多通道的网速 单位：byte(字节)
#ifdef SUP_MEDIA_SUPER_RESOLUTION
	EMSG_START_REAL_PLAY_SUPER_RESOLUTION = 5543, // 开启实时预览超分处理
	EMSG_STOP_REAL_PLAY_SUPER_RESOLUTION = 5544, // 关闭实时预览超分处理
#endif
	EMSG_ON_PLAY_DATA_ERROR = 5545, // 播放异常:长时间（3s）没有I帧数据返回(包含数据0x00异常情况)

	EMSG_SR_ON_PLAY_FRAMERATE_STATISTICS = 5546, // 帧率统计（超分, 第一次返回的是当前设备帧率，然后每4s更新统计一次）

	EMSG_ON_TALK_PCM_DATA = 5547, // 播放前对讲PCM数据回调(设备对讲过来的数据)

	EMSG_ON_MULTI_VIEW_FRAME_DATA_CB = 5548,        // 用户自定义多目信息帧回调

	EMSG_ON_DEV_LOGIN_TOKEN_ERROR_NOTIFY = 5549, // 设备登陆TOKEN(137)错误通知

	EMSG_ON_GWM_MEDIA_DISCONNECT = 5550,   // GWM媒体通道异常断开

	EMSG_ON_FRAME_DATA_SYNC_CB = 5551,  // 特殊信息帧同步回调 ps:后续可能会有拓展、客户端需要通过参数Param2判断信息帧类型

	EMSG_DEV_EX_MODULES_CHECK_UPGRADE = 5552, ///< 检测升级(拓展模块)
	EMSG_DEV_EX_MODULES_START_UPGRADE = 5553, ///< 开始升级(拓展模块)
	EMSG_DEV_EX_MODULES_STOP_UPGRADE = 5554, ///< 停止升级(拓展模块)
	EMSG_DEV_EX_MODULES_UPGRADE_PROGRESS = 5555, ///< 升级进度返回(拓展模块)

	EMSG_DEV_START_AV_TALK = 5556, ///< 开始音视频对讲(Client-->Dev)
	EMSG_DEV_AV_TALK_SEND_DATA = 5557, ///< 发送音视频对讲数据(Client-->Dev)
	EMSG_DEV_STOP_AV_TALK = 5558, ///< 关闭音视频对讲(Client-->Dev)
	EMSG_DEV_CONTROL_AV_TALK = 5559, ///< 控制音视频对讲(Client-->Dev)

	EMSG_START_STORE_PLAYING_MEDIA_DATA_INFO = 5560, ///< 开始存储当前正在播放的媒体数据
    EMSG_STOP_STORE_PLAYING_MEDIA_DATA_INFO = 5561, ///< 停止存储当前正在播放的媒体数据

    EMSG_MC_LinkDev = 6000,
    EMSG_MC_UnlinkDev = 6001,
    EMSG_MC_SendControlData = 6002,
    EMSG_MC_SearchAlarmInfo = 6003,
    EMSG_MC_SearchAlarmPic = 6004,
    EMSG_MC_ON_LinkDisCb= 6005,  //
    EMSG_MC_ON_ControlCb = 6006,
    EMSG_MC_ON_AlarmCb = 6007,
    EMSG_MC_ON_PictureCb = 6008,
    EMSG_MC_ConnectDev = 6009,
    EMSG_MC_DisconnectDev = 6010,
    EMSG_MC_INIT_INFO = 6011,
    EMSG_MC_DeleteAlarm = 6012,
    EMSG_MC_GetAlarmRecordUrl = 6013,    // 废弃
    EMSG_MC_SearchAlarmByMoth = 6014,
    EMSG_MC_OnRecvAlarmJsonData = 6015,  //第三方报警服务器收到报警数据处理回调
	EMSG_MC_StopDownloadAlarmImages = 6016,
	EMSG_MC_SearchAlarmLastTimeByType = 6017, //按类型查询最后一条报警时间
	EMSG_MC_AlarmJsonCfgOperation = 6018,  // 通用报警相关配置操作
	EMSG_MC_LinkDevs_Batch = 6019,  // 批量报警订阅
	EMSG_MC_UnLinkDevs_Batch = 6020,  // 批量取消报警订阅
	EMSG_MC_GET_DEV_ALARM_SUB_STATUS_BY_TYPE = 6021, // 从服务器端获取设备报警订阅状态
	EMSG_MC_GET_DEV_ALARM_SUB_STATUS_BY_TOKEN = 6022, // 从服务器端获取设备报警订阅状态
	EMSG_MC_WhetherTheBatchQueryGeneratesAnAlarm = 6023, /**< 批量查询是否产生报警 */
	EMSG_MC_QUERY_DEVS_STATUS_HISTORY_RECORD = 6024, /**< 查询设备(批量)状态历史记录 */
	EMSG_MC_LINK_BY_USERID = 6025, /**< 通过UserID进行报警订阅 */
	EMSG_MC_UNLINK_BY_USERID  = 6026, /**< 通过UserID进行报警取消订阅 */
	EMSG_MC_SEARCH_CLOUD_ALARM_INFO = 6027, /**< 云报警消息列表查询(结果携带缩略图url) */
	EMSG_MC_DOWNLOAD_CLOUD_ALARM_IMAGE = 6028, /**< 云报警消息图片下载 */
	EMSG_MC_BATCH_SEARCH_VIDEO_CLIP_INFO = 6029, ///< 根据时间点获取视频片段信息（批量）
	EMSG_MC_SET_ALARM_MSG_READ_FLAG = 6030, ///< 设置报警消息已读标志
	EMSG_MC_BATCH_DEV_ALARM_MSG_QUERY = 6031, ///< 批量设备报警消息查询
	EMSG_MC_DEV_ALARM_MSG_QUERY = 6032, ///< 设备报警消息查询(支持分页&报警类型选择查询)

    EMSG_XD_LinkMedia=7001,
    EMSG_XD_UnlinkMedia=7002,
    EMSG_XD_PublicHistoryList=7003,
    EMSG_XD_PublicCurrentList=7004,
    EMSG_XD_PublicDevInfo=7005,
    EMSG_XD_FetchPicture=7006,
    
    EMSG_CD_MediaTimeSect = FUN_USER_MSG_BEGIN_1 + 1200,// 废弃，不再使用
    EMSG_CD_Media_Dates = 6201,                            // 废弃，不再使用
    EMSG_MC_SearchMediaByMoth = 6202,
    EMSG_MC_SearchMediaByTime = 6203,
    EMSG_MC_DownloadMediaThumbnail = 6204,
    EMSG_MC_SearchMediaTimeAxis = 6205, // 查询云视频时间轴（一天内）
	EMSG_MC_CloudMediaSearchCssHls = 6206,

    /** 云存储最新协议异步消息ID */
	EMSG_CS_QUERY_VIDEO_CLIPS_BY_TIME = FUN_USER_MSG_BEGIN_1 + 1300, ///< 按时间查询云存储视频片段
	EMSG_CS_DOWNLOAD_VIDEO_CLIP_THUMBNAIL = 6301, ///< 下载云视频片段缩略图
	EMSG_CS_QUERY_VIDEO_TIME_AXIS = 6302, ///< 云存储视频时间轴查询

	/** 报警服务最新协议异步消息ID */
	EMSG_AS_INIT_INFO = FUN_USER_MSG_BEGIN_1 + 1400, ///< 报警服务初始化
	EMSG_AS_DEVS_ALARM_SUBSCRIBE = 6401, ///< 报警订阅(支持批量)
	EMSG_AS_DEVS_ALARM_UNSUBSCRIBE = 6402, ///< 取消报警订阅(支持批量)
	EMSG_AS_QUERY_ALARM_MSG_LIST = 6403, ///< 查询报警消息列表
	EMSG_AS_QUERY_ALARM_MSG_LIST_BY_TIME = 6404, ///< 按时间查询报警消息列表
	EMSG_AS_WHETHER_AN_ALARM_MSG_IS_GENERATED = 6405, ///< 是否有报警消息产生
	EMSG_AS_QUERY_CLOUD_VIDEO_CLIP_INFO_BY_POINT = 6406, ///< 查询视频片段信息
	EMSG_AS_QUERY_CALENDAR_BY_TIME = 6407, ///< 日历功能
	EMSG_AS_DELETE_ALARM = 6408, ///< 删除报警消息
	EMSG_AS_QUERY_SUBSCRIBE_STATUS = 6409, ///< 查询订阅状态
	EMSG_AS_QUERY_STATUS_HISTORY_RECORD = 6410, ///< 查询状态历史记录
	EMSG_AS_QUERY_CLOUD_VIDEO_HLS_URL = 6411, ///< 查询云存储视频播放地址
	EMSG_AS_USERID_ALARM_SUBSCRIBE = 6412, ///< 报警订阅(UserID)
	EMSG_AS_USERID_ALARM_UNSUBSCRIBE = 6413, ///< 取消报警订阅(UserID)
	EMSG_AS_DOWNLOAD_ALARM_MSG_IMAGE = 6414, ///< 报警消息图片下载
    EMSG_AS_STOP_DOWNLOAD_ALARM_MSG_IMAGE = 6415, ///< 取消等待队列中所有未下载的图片
	EMSG_AS_SET_ALARM_MSG_READ_FLAG = 6416, ///< 设置报警消息已读标志
    EMSG_AS_GET_STORAGE_INFO_COUNT = 6417, ///< 根据时间段获取存储信息条数
    EMSG_AS_QUERY_VIDEO_CLIP_BY_NAME  = 6418, ///< 按文件名称查询对应的云存储视频片段信息

    EMSG_DL_ON_DOWN_FILE = FUN_USER_MSG_BEGIN_1 + 1500,
    EMSG_DL_ON_INFORMATION,
    
    EMSG_CSS_API_CMD = FUN_USER_MSG_BEGIN_1 + 1600,//CSS API
    EMSG_KSS_API_UP_LOAD_VIDEO, //KSS API POST(VIDEO)
    EMSG_KSS_API_CMD_GET, //KSS API GET
    EMSG_KSS_API_UP_LOAD_PHOTO, //KSS API POST(PHOTO)
    
    EMSG_MC_ON_Alarm_NEW = FUN_USER_MSG_BEGIN_1 + 1700,
    
    EMSG_QT_API_INIT = FUN_USER_MSG_BEGIN_1 + 2000, // QintTing API
    EMSG_QT_GET_CATEGORYIES,
    EMSG_QT_GET_CHANNELS,
    EMSG_QT_GET_LIVE_CHANNELS,
    EMSG_QT_GET_PROGRAMS,
    EMSG_QT_GET_LIVE_PROGRAMS,
    EMSG_QT_GET_PROGRAMS_DETAIL,
    EMSG_QT_SEARCH_CONTENT,
    
    EMSG_JPEG_TO_MP4_ON_PROGRESS = FUN_USER_MSG_BEGIN_1 + 3000,
    EMSG_JPEG_TO_MP4_ADD_FILE,
    EMSG_JPEG_TO_MP4_CLOSE,
    EMSG_JPEG_TO_MP4_CANCEL,
    
    //视频广场、雄迈云
    EMSG_SYS_EDIT_USER_PHOTOS = FUN_USER_MSG_BEGIN_1 + 3500,
    EMSG_SYS_CHECK_USER_PHONE,
    EMSG_SYS_CHECK_USER_MAIL,
    EMSG_SYS_CHANGE_DEV_LOGIN_PWD,
    EMSG_SYS_BINDING_ACCOUNT,
    
    // 其它自定义消息
    // 广告更新等消息返回
    EMSG_CM_ON_VALUE_CHANGE = FUN_USER_MSG_BEGIN_1 + 3600,
    EMSG_CM_ON_GET_SYS_MSG = 8603,
    EMSG_CM_ON_GET_SYS_MSG_LIST = 8604,

	EMSG_AP_ON_RECEIVE_SAMPLES = FUN_USER_MSG_BEGIN_1 + 3700,

    /** 新影子服务消息ID */
    EMSG_SHADOW_SERVICE_GET_DEV_CONFIGS = FUN_USER_MSG_BEGIN_1 + 3800, ///< 获取设备配置
	EMSG_SHADOW_SERVICE_SET_DEV_OFFLINE_CFGS = 8801, ///< 设置设备离线配置
	EMSG_SHADOW_SERVICE_DEV_CONFIGS_CHANGE_NOTIFY = 8802, ///< 设备配置变化通知
	EMSG_SHADOW_SERVICE_START_DEV_LISTENING = 8803, ///< 开始设备影子服务监听
	EMSG_SHADOW_SERVICE_STOP_DEV_LISTENING = 8804, ///< 停止设备影子服务监听
	EMSG_SHADOW_SERVICE_DISCONNECT_NOTIFY = 8805, ///< 影子服务断开连接通知(内部已重试过)

	EMSG_SYS_NET_SPEED_TEST = FUN_USER_MSG_BEGIN_1 + 3900, ///< 客户端到JF服务器网络速度测试
	EMSG_SYS_NET_PING = 8901, ///< 客户端Ping指定域名
	EMSG_SYS_MQTT_CLIENT = 8921,  ///< 创建MQTT客户端
	EMSG_SYS_MQTT_DISCONNECT = 8922,    ///< 断线状态
	EMSG_SYS_MQTT_CONNECTING = 8923,	///< 连接状态
	EMSG_SYS_MQTT_SUBSCRIBE_INFO = 8924,     ///< 订阅设备状态
	EMSG_SYS_MQTT_UNSUBSCRIBE_INFO = 8925,   ///< 取消订阅设备状态
	EMSG_SYS_MQTT_MANAGE_SUBSCRIBE = 8926,   ///< 订阅管理
    EMSG_SYS_MQTT_RECONECTEDFAIL = 8928,   ///< MQTT重连超过最大次数
	EMSG_SYS_MQTT_RETURNMSG =8929,         ///< 向上层返回服务器消息
	EMSG_SYS_MQTT_UNINIT = 8930,           ///< 反初始化MQTT客户端
    EMSG_SYS_MQTT_DELETEDEVICE = 8931,    ///< 删除设备，取消对该设备的订阅

	EMSG_SYS_ACCOUNT_BINDWX = 8932,    ///< 当前账号绑定微信
	EMSG_SYS_ACCOUNT_UNBINDWX = 8933,    ///< 当前账号解绑微信

	EMSG_SYS_SERVICE_GET_LOGS = 8934, ///< HTTP日志服务请求
    EMSG_SYS_AI_SERVICE = 8935, ///< AI服务数据回调
}EUIMSG;

typedef enum EDEV_ATTR
{
    EDA_STATE_CHN = 1,
    EDA_OPT_ALARM = 2,
    EDA_OPT_RECORD = 3,
    EDA_DEV_INFO = 4,
}EDEV_ATTR;

typedef enum EDEV_GN_COMMAND
{
    DEV_CMD_OPSCalendar = 1446,
}EDEV_GN_COMMAND;

typedef enum EDEV_OPTERATE
{
    EDOPT_STORAGEMANAGE = 1, // 磁盘管理  *未实现
    EDOPT_DEV_CONTROL = 2, // Deivce Control *未实现
    EDOPT_DEV_GET_IMAGE = 3, // 设备抓图
    EDOPT_DEV_OPEN_TANSPORT_COM = 5, // 打开串口
    EDOPT_DEV_CLOSE_TANSPORT_COM = 6, // 关闭串口
    EDOPT_DEV_TANSPORT_COM_READ = 7, // 读数据 *未实现
    EDOPT_DEV_TANSPORT_COM_WRITE = 8, // 写数据
    EDOPT_DEV_BACKUP = 9,        //备份录像到u盘
    EDOPT_NET_KEY_CLICK = 10, //
}EDEV_OPTERATE;

////////////////////////兼容处理---后期会删除/////////////////////////////////////////
#define  EDA_DEV_OPEN_TANSPORT_COM       EDOPT_DEV_OPEN_TANSPORT_COM
#define  EDA_DEV_CLOSE_TANSPORT_COM     EDOPT_DEV_CLOSE_TANSPORT_COM
#define  EDA_DEV_TANSPORT_COM_READ        EDOPT_DEV_TANSPORT_COM_READ
#define  EDA_DEV_TANSPORT_COM_WRITE        EDOPT_DEV_TANSPORT_COM_WRITE
#define  EDA_NET_KEY_CLICK                EDOPT_NET_KEY_CLICK
#define  EDA_DEV_BACKUP                    EDOPT_DEV_BACKUP
////////////////////////////////////////////////////////////////////////////////

typedef enum EFUN_ERROR
{
    EE_DVR_SDK_NOTVALID            = -10000,            // 非法请求
    EE_DVR_ILLEGAL_PARAM        = -10002,            // 用户参数不合法
    EE_DVR_SDK_TIMEOUT            = -10005,            // 等待超时
    EE_DVR_SDK_UNKNOWNERROR        = -10009,            // 未知错误
    EE_DVR_DEV_VER_NOMATCH        = -11000,            // 收到数据不正确，可能版本不匹配
    EE_DVR_SDK_NOTSUPPORT        = -11001,            // 版本不支持
    
    EE_DVR_OPEN_CHANNEL_ERROR    = -11200,            // 打开通道失败
    EE_DVR_SUB_CONNECT_ERROR    = -11202,            // 建立媒体子连接失败
    EE_DVR_SUB_CONNECT_SEND_ERROR = -11203,            // 媒体子连接通讯失败
    EE_DVR_NATCONNET_REACHED_MAX  = -11204,         // Nat视频链接达到最大，不允许新的Nat视频链接
    
    /// 用户管理部分错误码
    EE_DVR_NOPOWER                    = -11300,            // 无权限
    EE_DVR_PASSWORD_NOT_VALID        = -11301,            // 账号密码不对
    EE_DVR_LOGIN_USER_NOEXIST        = -11302,            // 用户不存在
    EE_DVR_USER_LOCKED                = -11303,            // 该用户被锁定
    EE_DVR_USER_IN_BLACKLIST        = -11304,            // 该用户不允许访问(在黑名单中)
    EE_DVR_USER_HAS_USED            = -11305,            // 该用户以登陆
    EE_DVR_USER_NOT_LOGIN            = -11306,            // 该用户没有登陆
    EE_DVR_CONNECT_DEVICE_ERROR    = -11307,            // 获取配置失败，无法建立连接(设备不在线)
    EE_DVR_ACCOUNT_INPUT_NOT_VALID = -11308,            // 用户管理输入不合法
    EE_DVR_ACCOUNT_OVERLAP            = -11309,            // 索引重复
    EE_DVR_ACCOUNT_OBJECT_NONE        = -11310,            // 不存在对象, 用于查询时
    EE_DVR_ACCOUNT_OBJECT_NOT_VALID = -11311,            // 不存在对象
    EE_DVR_ACCOUNT_OBJECT_IN_USE    = -11312,            // 对象正在使用
    EE_DVR_ACCOUNT_SUBSET_OVERLAP    = -11313,            // 子集超范围 (如组的权限超过权限表，用户权限超出组的权限范围等等)
    EE_DVR_ACCOUNT_PWD_NOT_VALID    = -11314,            // 密码不正确
    EE_DVR_ACCOUNT_PWD_NOT_MATCH    = -11315,            // 密码不匹配
    EE_DVR_ACCOUNT_RESERVED            = -11316,            // 保留帐号
    EE_DVR_PASSWORD_ENC_NOT_SUP     = -11317,           // 不支持此种加密方式登录
    EE_DVR_PASSWORD_NOT_VALID2        = -11318,            // 账号密码不对2
    
    /// 配置管理相关错误码
    EE_DVR_OPT_RESTART                = -11400,            // 保存配置后需要重启应用程序
    EE_DVR_OPT_REBOOT                = -11401,            // 需要重启系统
    EE_DVR_OPT_FILE_ERROR            = -11402,            // 写文件出错
    EE_DVR_OPT_CAPS_ERROR            = -11403,            // 配置特性不支持
    EE_DVR_OPT_VALIDATE_ERROR        = -11404,            // 配置校验失败
    EE_DVR_OPT_CONFIG_NOT_EXIST        = -11405,            // 请求或者设置的配置不存在
    EE_DVR_OPT_CONFIG_PARSE_ERROR   = -11406,           // 配置解析出错
    
    
    ///
    EE_DVR_CFG_NOT_ENABLE       = -11502,             // 配置未启用
    EE_DVR_VIDEO_DISABLE        = -11503,             // 视频功能被禁用
    
    //DNS协议解析返回错误码
    EE_DVR_CONNECT_FULL                = -11612,        // 服务器连接数已满
    
    //版权相关
    EE_DVR_PIRATESOFTWARE           =-11700,         // 设备盗版
    
    EE_ILLEGAL_PARAM = -200000,        // 无效参数
    EE_USER_NOEXIST = -200001,        // 用户不存在
    EE_SQL_ERROR = -200002,            // sql失败
    EE_PASSWORD_NOT_VALID = -200003,    // 密码不正确
    EE_USER_NO_DEV = -200004,            // 相同序列号的设备设备已经存在
    EE_USER_EXSIT = -200007,            // 用户名已经被注册
    
    //公共命令字
    EE_MC_UNKNOWNERROR = -201101,        /// 未知错误
    EE_MC_NOTVALID = -201102,            /// 非法请求
    EE_MC_MSGFORMATERR = -201103,        /// 消息格式错误
    EE_MC_LOGINED = -201104,            /// 该用户已经登录
    EE_MC_UNLOGINED = -201105,            /// 该用户未登录
    EE_MC_USERORPWDERROR = -201106,        /// 用户名密码错误
    EE_MC_NOPOWER = -201107,            /// 无权限
    EE_MC_NOTSUPPORT = -201108,            /// 版本不支持
    EE_MC_TIMEOUT = -201109,            /// 超时
    EE_MC_NOTFOUND = -201110,            /// 查找失败，没有找到对应文件
    EE_MC_FOUND = -201111,                /// 查找成功，返回全部文件
    EE_MC_FOUNDPART = -201112,            /// 查找成功，返回部分文件
    EE_MC_PIRATESOFTWARE = -201113,        /// 盗版软件
    EE_MC_FILE_NOT_FOUND = -201114,        /// 没有查询到文件
    EE_MC_PEER_ONLINE = -201115,           /// 对端在线
    EE_MC_PEER_NOT_ONLINE = -201116,    /// 对端不在线
    EE_MC_PEERCONNET_REACHED_MAX = -201117,    /// 对端连接数已达上限
    EE_MC_LINK_SERVER_ERROR = -201118,    ///连接服务器失败
    EE_MC_APP_TYPE_ERROR = -201119,        ///APP类型错误
    EE_MC_SEND_DATA_ERROR = -201120,    ///发送数据出错
    EE_MC_AUTHCODE_ERROR = -201121,        ///获取AUTHCODE有误
    EE_MC_XPMS_UNINIT = -201122,        ///未初始化
    
    //EE_AS_PHONE_CODE = 10001：发送成功
	//  获取手机验证码相关错误码(用户注册时使用) www.xm030.cn
    EE_AS_PHONE_CODE0 =-210002, //接口验证失败
    EE_AS_PHONE_CODE1 =-210003, //参数错误
    EE_AS_PHONE_CODE2 =-210004, //手机号码已被注册
    EE_AS_PHONE_CODE3 =-210005, //超出短信每天发送次数限制(每个号码发送注册验证信息1天只能发送三次)
    EE_AS_PHONE_CODE4 =-210010, //发送失败
    EE_AS_PHONE_CODE5 =-210017, // 120秒之内只能发送一次，
    
    //此处需当心
    EE_DSS_NOT_SUP_MAIN = -210008,   // DSS不支持高清模式
    EE_TPS_NOT_SUP_MAIN = -210009,   // 转发模式不支持高清模式

	//用户注册相关错误码 www.xm030.cn
    EE_AS_REGISTER_CODE0 =-210102, //接口验证失败
    EE_AS_REGISTER_CODE1 =-210103, //参数错误
    EE_AS_REGISTER_CODE2 =-210104, //手机号码已被注册
    EE_AS_REGISTER_CODE3 =-210106, //用户名已被注册
    EE_AS_REGISTER_CODE4 =-210107, //注册码验证错误
    EE_AS_REGISTER_CODE5 =-210110, //注册失败（msg里有失败具体信息）

	// 同步登录相关错误码  www.xm030.cn
    EE_AS_LOGIN_CODE1 =-210202, //接口验证失败
    EE_AS_LOGIN_CODE2 =-210203, //参数错误
    EE_AS_LOGIN_CODE3 =-210210, //登录失败

	// 修改用户登录密码相关错误码   www.xm030.cn
    EE_AS_EIDIT_PWD_CODE1 =-210302, // 接口验证失败
    EE_AS_EIDIT_PWD_CODE2 =-210303, // 参数错误
    EE_AS_EIDIT_PWD_CODE3 =-210311, // 新密码不符合要求
    EE_AS_EIDIT_PWD_CODE4 =-210313, // 原密码错误
    EE_AS_EIDIT_PWD_CODE5 =-210315, // 请输入与原密码不同的新密码

	// 忘记用户登录密码 相关错误码  www.xm030.cn
    EE_AS_FORGET_PWD_CODE1 =-210402, // 接口验证失败
    EE_AS_FORGET_PWD_CODE2 =-210403, // 参数错误
    EE_AS_FORGET_PWD_CODE3 =-210405, // 超出短信每天发送次数限制(每个号码发送注册验证信息1天只能发送三次)
    EE_AS_FORGET_PWD_CODE4 =-210410, // 发送失败（msg里有失败具体信息）
    EE_AS_FORGET_PWD_CODE5 =-210414, // 手机号码不存在

	//重置用户登录密码相关错误码（www.xm030.cn） / 视频广场dss （这两个都会返回(nRet % 100) * -1 -210500）
    EE_AS_RESET_PWD_CODE1 =-210502, //接口验证失败
    EE_AS_RESET_PWD_CODE2 =-210503, //参数错误
    EE_AS_RESET_PWD_CODE3 =-210511, //新密码不符合要求
    EE_AS_RESET_PWD_CODE4 =-210512, //两次输入的新密码不一致
    EE_AS_RESET_PWD_CODE5 =-210514, //手机号码不存在

	// 验证验证码相关错误码  www.xm030.cn
    EE_AS_CHECK_PWD_CODE1 =-210602, //接口验证失败
    EE_AS_CHECK_PWD_CODE2 =-210603, //参数错误
    EE_AS_CHECK_PWD_CODE3 =-210607, //验证码错误
    EE_AS_CHECK_PWD_CODE4 =-210614, //手机号码不存在

	//(服务器返回错误 (nRet % 100) * -1 - 210700;下面的服务器响应错误同理)
	//视频广场相关
	// 获取用户公开设备列表相关错误码 square.xm030.net
    EE_AS_GET_PUBLIC_DEV_LIST_CODE = -210700, // 服务器响应失败

	// 获取用户共享设备列表相关错误码 square.xm030.net
    EE_AS_GET_SHARE_DEV_LIST_CODE = -210800, // 服务器响应失败

	// 公开设备相关错误码 square.xm030.net
    EE_AS_SET_DEV_PUBLIC_CODE = -210900, // 服务器响应失败

	// 分享设备(分享视频)相关错误码  square.xm030.net
    EE_AS_SHARE_DEV_VIDEO_CODE = -211000, // 服务器响应失败

	// 取消公开设备相关错误码  square.xm030.net
    EE_AS_CANCEL_DEV_PUBLIC_CODE = -211100, // 服务器响应失败

	// 取消分享设备相关错误码  square.xm030.net
    EE_AS_CANCEL_SHARE_VIDEO_CODE = -211200, // 服务器响应失败

	// 设备注册相关错误码  square.xm030.net
    EE_AS_DEV_REGISTER_CODE = -211300, // 服务器响应失败

	// 发表评论相关错误码  square.xm030.net
    EE_AS_SEND_COMMNET_CODE  = -211400, // 服务器响应失败

	// 获取评论列表相关错误码  square.xm030.net
    EE_AS_GET_COMMENT_LIST_CODE = -211500, // 服务器响应失败

	// 获取视频信息相关错误码  square.xm030.net
    EE_AS_GET_VIDEO_INFO_CODE = -211600, // 服务器响应失败

	// 上传本地视频相关错误码  square.xm030.net
    EE_AS_UPLOAD_LOCAL_VIDEO_CODE = -211700, // 服务器响应失败
    EE_AS_UPLOAD_LOCAL_VIDEO_CODE1 = -211703, // 缺少上传文件

	// 获取短片视频列表相关错误码  square.xm030.net
    EE_AS_GET_SHORT_VIDEO_LIST_CODE = -211800, // 服务响应失败

	// 短片视频编辑相关错误码  square.xm030.net
    EE_AS_EDIT_SHORT_VIDEO_INFO_CODE = -211900, // 服务响应失败

	// 删除短片视频相关错误码 square.xm030.net
    EE_AS_DELETE_SHORT_VIDEO_CODE = -212000, // 服务响应失败

	// 选择设备authcode相关错误码  square.xm030.net
    EE_AS_SELECT_AUTHCODE_CDOE =  -212100, // 服务响应失败
    EE_AS_SELECT_AUTHCODE_CDOE1 =  -212104, // 服务器查询失败

	// 获取用户相册列表相关错误码  square.xm030.net
    EE_AS_GET_USER_PHOTOS_LIST_CODE = -212200, // 服务响应失败

	// 创建用户相册相关错误码  square.xm030.net
    EE_AS_CREATE_USER_PHOTOS_CODE = -212300, // 服务响应失败

	// 上传图片相关错误码  square.xm030.net
    EE_AS_UPLOAD_PHOTO_CODE = -212400, // 服务响应失败
    EE_AS_UPLOAD_PHOTO_CODE1 = -212402, // 没有接受到上传的文件

	// 图片文件编辑相关错误码  square.xm030.net
    EE_AS_EDIT_PHOTO_INFO_CODE = -212500, // 服务响应失败

	// 图片文件列表相关错误码  square.xm030.net
    EE_AS_GET_PHOTO_LIST_CODE = -212600, // 服务响应失败

	// 删除图片相关错误码  square.xm030.net
    EE_AS_DELETE_PHOTO_CODE = -212700, // 服务响应失败

	// 删除相册相关错误码  square.xm030.net
    EE_AS_DELETE_PHOTOS_CODE = -212800, //服务响应失败

	// 检测密码合法性及强度相关错误码 www.xm030.cn
    EE_AS_CHECK_PWD_STRENGTH_CODE = -212900, //服务器响应失败
    EE_AS_CHECK_PWD_STRENGTH_CODE1 = -212902, //接口验证失败
    EE_AS_CHECK_PWD_STRENGTH_CODE2 = -212903, //参数错误
    EE_AS_CHECK_PWD_STRENGTH_CODE3 = -212910, //密码不合格

    //云服务通过邮箱找回密码返回错误
    EE_HTTP_PWBYEMAIL_UNFINDNAME = -213000,  //无此用户名
    EE_HTTP_PWBYEMAIL_FAILURE = -213001,    //发送失败

	// 发送邮箱验证码相关错误码 www.xm030.cn
    EE_AS_SEND_EMAIL_CODE = -213100,    // 服务响应失败
    EE_AS_SEND_EMAIL_CODE1 = -213102,   // 接口验证失败
    EE_AS_SEND_EMAIL_CODE2 = -213103,   //参数错误
    EE_AS_SEND_EMAIL_CODE3 = -213108,   //邮箱已被注册
    EE_AS_SEND_EMAIL_CODE4 = -213110,   //发送失败

	// 邮箱注册相关错误码 www.xm030.cn
    EE_AS_REGISTE_BY_EMAIL_CODE = -213200,    // 服务响应失败
    EE_AS_REGISTE_BY_EMAIL_CODE1 = -213202,    // 接口验证失败
    EE_AS_REGISTE_BY_EMAIL_CODE2 = -213203,    // 参数错误
    EE_AS_REGISTE_BY_EMAIL_CODE3 = -213206,    // 用户名已被注册
    EE_AS_REGISTE_BY_EMAIL_CODE4 = -213207,    // 注册码验证错误
    EE_AS_REGISTE_BY_EMAIL_CODE5 = -213208,    // 邮箱已被注册
    EE_AS_REGISTE_BY_EMAIL_CODE6 = -213210,    // 注册失败

	// 发送邮箱验证码相关错误码 www.xm030.cn （修改密码、重置密码
    EE_AS_SEND_EMAIL_FOR_CODE = -213300,    // 服务响应失败
    EE_AS_SEND_EMAIL_FOR_CODE1 = -213302,    // 接口验证失败
    EE_AS_SEND_EMAIL_FOR_CODE3 = -213303,    // 参数错误
    EE_AS_SEND_EMAIL_FOR_CODE4 = -213310,    // 发送失败
    EE_AS_SEND_EMAIL_FOR_CODE5 = -213314,    // 邮箱不存在
    EE_AS_SEND_EMAIL_FOR_CODE6 = -213316,    // 箱和用户名不匹配

	// 邮箱验证验证码相关错误码 www.xm030.cn
    EE_AS_CHECK_CODE_FOR_EMAIL = -213400,    // 服务响应失败
    EE_AS_CHECK_CODE_FOR_EMAIL1 = -213402,    // 接口验证失败
    EE_AS_CHECK_CODE_FOR_EMAIL2 = -213403,    // 参数错误
    EE_AS_CHECK_CODE_FOR_EMAIL3 = -213407,    // 验证码错误
    EE_AS_CHECK_CODE_FOR_EMAIL4 = -213414,    // 邮箱不存在

	// 通过邮箱重置用户登录密码相关错误码 www.xm030.cn
    EE_AS_RESET_PWD_BY_EMAIL = -213500,   // 服务响应失败
    EE_AS_RESET_PWD_BY_EMAIL1 = -213502,   // 接口验证失败
    EE_AS_RESET_PWD_BY_EMAIL2 = -213503,   // 参数错误
    EE_AS_RESET_PWD_BY_EMAIL3 = -213513,   // 重置失败
    EE_AS_RESET_PWD_BY_EMAIL4 = -213514,   //手机号码或邮箱不存在

	// xmcloud服务器相关错误码  mi.xmeye.net
    EE_CLOUD_DEV_MAC_BACKLIST = -213600,   //101://在黑名单中(mac)
    EE_CLOUD_DEV_MAC_EMPTY = -213602,     //104: //mac值为空
    EE_CLOUD_DEV_MAC_INVALID = -213603,     //105: //格式不对(mac地址长度不为16位或者有关键字)
    EE_CLOUD_DEV_MAC_UNREDLIST = -213604,     //107:  //不存在白名单
    EE_CLOUD_DEV_NAME_EMPTY = -213605,     //109: //设备名不能为空
    EE_CLOUD_DEV_USERNAME_INVALID = -213606, //111: //设备用户名格式不正确，含关键字
    EE_CLOUD_DEV_PASSWORD_INVALID = -213607,  //112: //设备密码格式不正确，含关键字
    EE_CLOUD_DEV_NAME_INVALID = -213608,     //113: //设备名称格式不正确，含关键字
    
    EE_CLOUD_PARAM_INVALID = -213610,      //10003: //参数异常（dev.mac传入的参数不对）
    EE_CLOUD_CHANGEDEVINFO = -213612,     //编辑设备信息失败
    
    EE_CLOUD_SERVICE_ACTIVATE = -213620,      //10002://开通失败
    EE_CLOUD_SERVICE_UNAVAILABLE = -213621,    //40001: //没有开通云存储（1、用户不存在；2、用户没有开通 ）
    
    EE_CLOUD_AUTHENTICATION_FAILURE = -213630 ,    //150000: //验证授权失败（用户名或密码错误）

	// 检测用户名是否已注册相关错误码   www.xm030.cn
    EE_AS_CHECK_USER_REGISTE_CODE = -213700,    // 服务响应失败
    EE_AS_CHECK_USER_REGISTE_CODE1 = -213702,    // 接口验证失败
    EE_AS_CHECK_USER_REGISTE_CODE2 = -213703,    // 参数错误
    EE_AS_CHECK_USER_REGISTE_CODE3 = -213706,    // 用户名已被注册

	// 升级检测相关错误码  upgrade.secu100.net
    EE_CLOUD_UPGRADE_UPDATE = -213800, //成功，需要更新
    EE_CLOUD_UPGRADE_LASTEST = -213801, //成功，已是最新，无需更新
    EE_CLOUD_UPGRADE_INVALIDREQ = -213802,//失败，无效请求
    EE_CLOUD_UPGRADE_UNFINDRES = -213803,   //失败，资源未找到
    EE_CLOUD_UPGRADE_SERVER = -213804,     //失败，服务器内部错误
    EE_CLOUD_UPGRADE_SERVER_UNAVAIL = -213805,  //失败，服务器暂时不可用，此时Retry-After指定下次请求的时间

	// 修改用户相册相关错误码 square.xm030.net
    EE_AS_EDIT_USER_PHOTOS_CODE = -213900,// 服务响应失败

	// 同步退出相关错误码   www.xm030.cn
    EE_AS_SYS_LOGOUT_CODE = -214100, // 服务器向应失败
    EE_AS_SYS_LOGOUT_CODE1 = -214102, // 接口验证失败
    EE_AS_SYS_LOGOUT_CODE2 = -214103, // 参数错误

	// 无需验证注册相关错误码   www.xm030.cn
    EE_AS_SYS_NO_VALIDATED_REGISTER_CODE = -214200, // 服务器响应失败
    EE_AS_SYS_NO_VALIDATED_REGISTER_CODE1 = -214202, // 接口验证失败
    EE_AS_SYS_NO_VALIDATED_REGISTER_CODE2 = -214203, // 参数错误
    EE_AS_SYS_NO_VALIDATED_REGISTER_CODE3 = -214206, // 用户名已被注册
    EE_AS_SYS_NO_VALIDATED_REGISTER_CODE4 = -214210, // 注册失败

	// 获取用户信息相关错误码   www.xm030.cn
    EE_AS_SYS_GET_USER_INFO_CODE = -214300, // 服务器响应失败
    EE_AS_SYS_GET_USER_INFO_CODE1 = -214302, // 接口验证失败
    EE_AS_SYS_GET_USER_INFO_CODE2 = -214303, // 参数错误
    EE_AS_SYS_GET_USER_INFO_CODE3 = -214306, // 用户名不存在
    EE_AS_SYS_GET_USER_INFO_CODE4 = -214310, // 获取失败
    EE_AS_SYS_GET_USER_INFO_CODE5 = -214313, // 用户密码错误

	// 绑定安全手机(1)—发送验证码相关错误码   www.xm030.cn
    EE_AS_SYS_SEND_BINDING_PHONE_CODE = -214400, // 服务器响应失败
    EE_AS_SYS_SEND_BINDING_PHONE_CODE1 = -214402, // 接口验证失败
    EE_AS_SYS_SEND_BINDING_PHONE_CODE2 = -214403, // 参数错误
    EE_AS_SYS_SEND_BINDING_PHONE_CODE3 = -214404, // 手机号码已被绑定
    EE_AS_SYS_SEND_BINDING_PHONE_CODE4 = -214405, // 超出短信每天发送次数限制
    EE_AS_SYS_SEND_BINDING_PHONE_CODE5 = -214406, // 用户名不存在
    EE_AS_SYS_SEND_BINDING_PHONE_CODE6 = -214410, // 发送失败
    EE_AS_SYS_SEND_BINDING_PHONE_CODE7 = -214413, // 用户密码错误
    EE_AS_SYS_SEND_BINDING_PHONE_CODE8 = -214417, // 120秒之内只能发送一次

	// 绑定安全手机(2)—验证code并绑定  www.xm030.cn
    EE_AS_SYS_BINDING_PHONE_CODE = -214500, // 服务器响应失败
    EE_AS_SYS_BINDING_PHONE_CODE1 = -214502, // 接口验证失败
    EE_AS_SYS_BINDING_PHONE_CODE2 = -214503, // 参数错误
    EE_AS_SYS_BINDING_PHONE_CODE3 = -214504, // 手机号码已被绑定
    EE_AS_SYS_BINDING_PHONE_CODE4 = -214506, // 用户名不存在
    EE_AS_SYS_BINDING_PHONE_CODE5 = -214507, // 验证码错误
    EE_AS_SYS_BINDING_PHONE_CODE6 = -214510, // 绑定失败a
    EE_AS_SYS_BINDING_PHONE_CODE7 = -214513, // 用户密码错误

	// 绑定安全邮箱(1)—发送验证码相关错误码   www.xm030.cn
    EE_AS_SYS_SEND_BINDING_EMAIL_CODE = -214600, // 服务器响应失败
    EE_AS_SYS_SEND_BINDING_EMAIL_CODE1 = -214602, // 接口验证失败
    EE_AS_SYS_SEND_BINDING_EMAIL_CODE2 = -214606, // 用户名不存在
    EE_AS_SYS_SEND_BINDING_EMAIL_CODE3 = -214608, // 该邮箱已被绑定
    EE_AS_SYS_SEND_BINDING_EMAIL_CODE4 = -214610, // 发送失败
    EE_AS_SYS_SEND_BINDING_EMAIL_CODE5 = -214613, // 用户密码错误

	// 绑定安全邮箱(2)—验证code并绑定相关错误码   www.xm030.cn
    EE_AS_SYS_BINDING_EMAIL_CODE = -214700, // 服务器响应失败
    EE_AS_SYS_BINDING_EMAIL_CODE1 = -214702, // 接口验证失败
    EE_AS_SYS_BINDING_EMAIL_CODE2 = -214703, // 参数错误
    EE_AS_SYS_BINDING_EMAIL_CODE3 = -214706, // 用户名不存在
    EE_AS_SYS_BINDING_EMAIL_CODE4 = -214707, // 验证码错误
    EE_AS_SYS_BINDING_EMAIL_CODE5 = -214708, // 该邮箱已被绑定
    EE_AS_SYS_BINDING_EMAIL_CODE6 = -214710, // 绑定失败
    EE_AS_SYS_BINDING_EMAIL_CODE7 = -214713, // 用户密码错误

	// 用户注册(Extend)相关错误码   www.xm030.cn
    EE_AS_REGISTER_EXTEND_CODE0 =-214802, //接口验证失败
    EE_AS_REGISTER_EXTEND_CODE1 =-214803, //参数错误
    EE_AS_REGISTER_EXTEND_CODE2 =-214804, //手机号码已被注册
    EE_AS_REGISTER_EXTEND_CODE3 =-214806, //用户名已被注册
    EE_AS_REGISTER_EXTEND_CODE4 =-214807, //注册码验证错误
    EE_AS_REGISTER_EXTEND_CODE5 =-214810, //注册失败（msg里有失败具体信息）

	// 邮箱注册(Extend)相关错误码   www.xm030.cn
    EE_AS_REGISTE_BY_EMAIL_EXTEND_CODE = -214900,    // 服务响应失败
    EE_AS_REGISTE_BY_EMAIL_EXTEND_CODE1 = -214902,    // 接口验证失败
    EE_AS_REGISTE_BY_EMAIL_EXTEND_CODE2 = -214903,    // 参数错误
    EE_AS_REGISTE_BY_EMAIL_EXTEND_CODE3 = -214906,    // 用户名已被注册
    EE_AS_REGISTE_BY_EMAIL_EXTEND_CODE4 = -214907,    // 注册码验证错误
    EE_AS_REGISTE_BY_EMAIL_EXTEND_CODE5 = -214908,    // 邮箱已被注册
    EE_AS_REGISTE_BY_EMAIL_EXTEND_CODE6 = -214910,    // 注册失败

	// 无需验证注册(Extend)相关错误码   www.xm030.cn
    EE_AS_SYS_NO_VALIDATED_REGISTER_EXTEND_CODE = -215000, // 服务器响应失败
    EE_AS_SYS_NO_VALIDATED_REGISTER_EXTEND_CODE1 = -215002, // 接口验证失败
    EE_AS_SYS_NO_VALIDATED_REGISTER_EXTEND_CODE2 = -215003, // 参数错误
    EE_AS_SYS_NO_VALIDATED_REGISTER_EXTEND_CODE3 = -215006, // 用户名已被注册
    EE_AS_SYS_NO_VALIDATED_REGISTER_EXTEND_CODE4 = -215010, // 注册失败

	//DSS服务相关错误 / PlatSDK获取authcode也是这个错误
    EE_DSS_XMCloud_InvalidParam = -215100,    //通过XMCloud获取设备DSS信息
    EE_DSS_XMCloud_ConnectHls = -215101,    //DSS连接Hls服务器失败
    EE_DSS_XMCloud_InvalidStream= -215102,    //DSS服务器异常
    EE_DSS_XMCloud_Request = -215103,    //DSS服务器请求失败
    EE_DSS_XMCloud_StreamInterrupt = -215104,    //DSS码流格式解析失败

    EE_DSS_SQUARE_PARSE_URL = -215110,      //解析雄迈云返回的视频广场url失败
    
    EE_DSS_MINOR_STREAM_DISABLE = -215120,   // DSS  服务器禁止此种码流(-1)
    EE_DSS_NO_VIDEO = -215121,               // NVR  前端未连接视频源(-2)
    EE_DSS_DEVICE_NOT_SUPPORT = -215122,     // 前端不支持此种码流(-3)
    EE_DSS_NOT_PUSH_STRREAM = -215123,       // DSS 服务器未推流(0)
    EE_DSS_NOT_OPEN_MIXED_STRREAM = -215124, // DSS 不能使用组合编码通道进行打开，请重新打开
    
    EE_DSS_BAD_REQUEST = -215130,            // 无效请求（http）
    EE_MEDIA_CONNET_REACHED_MAX  = -215131,  // 媒体视频链接达到最大，访问受限
    
    //和Dss Token/AuthCode相关的错误
    EE_DSS_XMClOUD_ERROR_INVALID_TOKEN_FORMAT= -215140, //100001 无效的令牌格式
    EE_DSS_XMClOUD_ERROR_NOT_MATCH_TOKEN_SERINUMBER = -215141, //100002 不匹配令牌序列号
    EE_DSS_XMClOUD_ERROR_REMOTE_IP_NOT_MATCH_TOKEN_IP = -215142, //100003 远程ip不匹配令牌ip
    EE_DSS_XMClOUD_ERROR_TOKNE_EXPIRSE = -215143, //100004 令牌到期
    EE_DSS_XMClOUD_ERROR_GET_SECRET_KEY_FAILED = -215144, //100005 获取秘钥key失败
    EE_DSS_XMClOUD_ERROR_TOKEN_NOT_MATCH_SIGN = -215145, //100006 令牌不符
    EE_DSS_XMClOUD_ERROR_KEY_DATA_INVALIED_FORMAT = -215146, //100007 令牌数据无效格式
    EE_DSS_XMClOUD_ERROR_DECODE_KEY_DATA_FAILED = -215147, //100008 解密秘钥数据失败
    EE_DSS_XMClOUD_ERROR_AUTHCODE_NOT_MATCH = -215148, //100009 authcode不匹配
    EE_DSS_XMClOUD_ERROR_AUTHCODE_CHANGE = -215149, //100010 更改了authcode

    EE_DSS_XMCLOUD_IDR_SLEEP_STOP_REQUEST_STREAM = -215150, //NVR下的低功耗休眠，DSS停止请求码流

	EE_DSS_SIMULTANEOUS_ACCESS_LIMIT_REACHED = -215151, // DSS同时访问达到上限

	// 云存储图片上传失败错误码 http://10.2.11.100/pages/viewpage.action?pageId=23172315
	EE_CSPIC_GET_CSS_ACCESS_FORM_CFG_FAILED  = -215152,  // -30001 从CFG获取CSS地址失败  *解决方案:在和设备同一个路由器网络下ping一下pub-cfg.secu100.net是否畅通
	EE_CSPIC_CREATE_PUSH_ASSISTANT_OBJECT_FAILED  = -215153,  // -30002 内部错误创建推送助手对象失败 *解决方案:此问题可能原因在于设备内存已达到极限无法再申请多余内存了
	EE_CSPIC_CAPTURE_SWITCH_NOT_TURNED_OR_RETURN_NULL  = -215154,  // -30003 针对R11,R12表示未打开抓图开关，对R02分支表示本地抓图接口返回NULL *解决方案:打开报警抓图开关/需要驱动或者应用部介入调查
	EE_CSPIC_UNOPENED_FREE_INAGES  = -215155,  // -30004 未开放免费图片 *解决方案:该型号设备未开放免费图片权限
	EE_CSPIC_UPLOAD_IS_NOT_ENABLED  = -215156,  // -30005 已开放免费图片权限并打开了报警抓图开关，但未使能云存储图片上传(默认情况下都是使能的) *解决方案:打开图使能开关(该开关和设备配置无关，只是app通过服务器用来控制设备是否上传云储图片，并不影响设备本地报警抓图)
	EE_CSPICE_LOCAL_CAPTURE_FAILED  = -215157,  // -30006 本地抓图失败，抓图接口返回NULL(该错误码一般出现在R11,R12分支，R02暂时不会有此错误码) *解决方案:需要驱动或者应用部介入调查
	EE_CSPIC_UPLOAD_PICTURE_TIMEOUT  = -215158,  // -30007 上传图片超时(设备端会尝试重试，若重试失败则会上报该错误码) *解决方案:检查设备网络环境，设备网络太差，导致上传超时(目前超时时间为5s)
	EE_CSPIC_PICTURE_NOT_EXIST = -215159, // 云存储图片不存在(云存储图片存在唯一判断条件："PicInfo"/"ObjSize" > 0)
    EE_CSPIC_STORAGE_BUCKET_NOT_EXIST = -215160, // 云存储图片存储桶信息不存在(唯一判断条件："PicInfo"/"StorageBucket" 字符串长度 > 0)
	EE_CSPIC_NOT_NEED_TO_GRAP_PICTURE = -215161, // -30008 表示本次报警消息本身就不用携带图片(这个是针对IOT设备有些仅仅需要报警而无需抓图的场景)

	// 221000 报警删除返回错误码  / 报警订阅&取消订阅返回400 错误码都是 221400
	EE_ALARM_BAD_REQUEST = -221400, // 错误的请求
    EE_ALARM_CHECK_AUTHCODE_FAILED = -221201, //报警授权码错误
    EE_ALARM_NOT_SUPPORTED = -221202,          //不支持（比如在中国界内不支持Google报警）

	// (签名获取/报警消息查询/报警订阅)相关错误码 -222000
    EE_ALARM_SELECT_NO_RECORD = -222400, // 未查询到报警历史记录
    
    EE_VIDEOPLAY_URL_NULL = -223000,    //url为空
    EE_VIDEOPLAY_URL_Open = -223001,    //打开失败
    EE_VIDEOPLAY_URL_FindStream = -223002, //获取流信息失败
    EE_VIDEOPLAY_URL_FindVideoStream = -223003, //获取视频流信息失败
    EE_VIDEOPLAY_URL_ReadStream = -223010, //无法获取视频流

	// 报警服务最新简化协议错误码 -225000   后三位代表服务器下发的错误码 || HTTP Code
	EE_AS_UNINITIALIZED = -225001, ///< 报警服务未初始化
	EE_AS_CANNOT_GET_DEVSN = -225002, ///< 获取不到序列号，请至少登录一次设备
	EE_AS_URL_IMAGE_DOWNLOAD_EXPIRED = -225003, ///< URL图片下载过期
	EE_AS_HTTP_MOVED_PERMANENTLY = -225301, 			///< 301 请求被转移(被请求的资源已被永久移动到新位置。客户端应使用新的URI重发请求)
	EE_AS_HTTP_NOR_MODIFIED = -225304, 				///< 304 资源未被修改(客户端发送了一个带条件的请求，服务器告诉客户端资源未被修改，可以使用缓存的版本)
	EE_AS_HTTP_INVALIDREQ = -225400, 			    ///< 400 无效请求(表示服务器无法理解或无法处理客户端发送的请求，可能是请求格式不正确或缺少必需的参数)
	EE_AS_HTTP_UNAUTHORIZED = -225401, 				///< 401 未授权(表示客户端需要进行身份验证才能获得请求的资源)
	EE_AS_HTTP_FORBIDDEN = -225403, 				///< 403 禁止访问(表示客户端已被服务器拒绝访问所请求的资源，没有权限访问)
	EE_AS_HTTP_NOT_FOUND = -225404, 				///< 404 未找到(表示服务器无法找到请求的资源，即请求的URL无效或不存在)
	EE_AS_HTTP_INTERNAL_SERVER_ERROR = -225500, 	///< 500 服务器内部错误(服务器内部错误。表示服务器在处理请求时发生了意外错误，无法完成请求)
	EE_AS_PARAM_CHECK_FAILED = -225501, ///< 重要参数校验失败（字段缺失，类型不匹配，为空字符串）
	EE_AS_SERVER_FAILUER_1 = -225502, ///< 服务器故障，请联系我们 （获取redis的ip，port失败）
	EE_AS_SERVER_FAILUER_2 = -225503, ///< 服务器故障，请联系我们 （redis建立连接失败）
	EE_AS_SERVER_FAILUER_3 = -225504, ///< 服务器故障，请联系我们 （redis操作失败）
	EE_AS_SERVER_FAILUER_4 = -225505, ///< 服务器故障，请联系我们 （获取mysql地址失败）
	EE_AS_SERVER_FAILUER_5 = -225506, ///< 服务器故障，请联系我们 （SQL语句输入参数校验失败，（可能存在SQL注入））
	EE_AS_SERVER_FAILUER_6 = -225507, ///< 服务器故障，请联系我们 （SQL操作失败）
	EE_AS_THUMBNAIL_URL_GET_EXPIRATION_TIME_FAILED = -225508, ///< 缩略图url与url过期时间获取失败
	EE_AS_TIME_FORMAT_CHECK_FAILED = -225509, ///< 时间格式校验失败，时间戳转化失败
	EE_AS_CLOUD_STORAGE_PACKAGE_INFO_EXCEPTION = -225510, ///< 云存储套餐信息异常
	EE_AS_UNKNOWN_INVALID_QUERY_TYPE = -225511, ///< 未知不合法查询类型，非MSG或VIDEO
	EE_AS_START_TIME_AND_END_TIME_NOT_ON_THE_SAME_DAY = -225512, ///< 查询的开始时间与结束时间不在同一天
	EE_AS_SN_FORMAT_IS_INVALID = -225513, ///< sn格式不合法
	EE_AS_UNKNOWN_INVALID_CLEAR_TYPE = -225514, ///< 未知不合法清除类型，非（ALL，ALARM，VIDEO）
	EE_AS_UNKNOWN_SUBSCRIPTION_QUERY_PROTOCOL_FORMAT = -225515, ///< 未知的订阅查询协议格式
	EE_AS_NON_WHITELISTED_IP_REQUESTS = -225516, ///< 非白名单内IP请求（仅针对云信息删除接口）
	EE_AS_USER_NO_ACCESSTO_QUERY = -225517, ///< 未获取到此用户可查询的时间区域（仅针对需进行userid校验的接口）

    // 影子服务最新简化协议相关错误码 -226000
    EE_SS_BAD_REQUEST = -226400,  ///< 错误请求
    EE_SS_SERVER_INTERNAL_ERROR = -226500, ///< 服务器内部错误
    EE_SS_GET_DATA_FAILED = -226001, ///< 10001:获取数据失败
    EE_SS_SET_DATA_FAILED = -226002, ///< 10002:更新数据失败
	EE_SS_CANNOT_SET_READ_ONLY_CONFIG = -226003, ///< 10003:不能设置只读配置

    EE_DEVLOG_OPENTELNET = -223100,//打开telnet失败
    
    EE_SYS_GET_AUTH_CODE = -300000,  // 获取Auth Error

	// MNETSDK返回的错误转换（设备返回）  / QT  api.qingting.fm
    EE_MNETSDK_HEARTBEAT_TIMEOUT = -400000, //The errors between -400000 and -500000 stem from libMNetSDK.so
    EE_MNETSDK_FILE_NOTEXIST = -400001, //文件不存在
    EE_MNETSDK_IS_UPGRADING = -400002, //设备正在升级中
    EE_MNETSDK_SERVER_STATUS_ERROR = -400003,    //服务器初始化失败
    EE_MNETSDK_GETCONNECT_TYPE_ERROR = -400004,    //获取连接类型失败
    EE_MNETSDK_QUERY_SERVER_FAIL = -400005,    //查询服务器失败
    EE_MNETSDK_HAS_CONNECTED = -400006,    //设备已经连接
    EE_MNETSDK_IS_LOGINING = -400007,    //正在登录
    EE_MNETSDK_DEV_IS_OFFLINE = -400008, //设备可能不在线
    EE_MNETSDK_NOTSUPPORT = -400009,    //设备不支持
    EE_MENTSDK_NOFILEFOUND = -400010,  // 没有查询到文件，请切换日期（之前的错误提示是“没有当天图片，请切换日期”，这个可以按照实际情况进行不同的提示）
    EE_MNETSDK_DISCONNECT_ERROR = -400011,  //断开连接失败
    EE_MNETSDK_TALK_ALAREADY_START = -400012,   //对讲已开启
    EE_MNETSDK_DEV_PTL = -400013,           //DevPTL NULL
    EE_MNETSDK_BACKUP_FAILURE = -400014,    //备份到u盘失败
    EE_MNETSDK_NODEVICE = -400015,           //无存储设备(u盘)或设备没在录像
    EE_MNETSDK_USEREXIST = -400016,          //设备已存在
    EE_MNETSDK_CAPTURE_PIC_FAILURE = -400017,        //抓图失败
    
    EE_MNETSDK_FILE_SIZE_LIMIT = -400018,// 超出文件大小限制（nvr校验64kb， ipc校验40k。。）
    EE_MNETSDK_CHECK_FILE_SIZE = -400019,// 文件大小校验失败

    EE_MNETSDK_TALK_NOT_START = -400100,   //设备端错误码503:对讲未开启（设备错误码往后写）
    EE_MNETSDK_STORAGE_IS_FULL = -400101,  //设备存储已满
    EE_MNETSDK_GET_LOGIN_ENC_INFO_RESULT = -400102, // 获取登录加密信息未得到明确的结果（支持/不支持），直接返回登录错误，不会再自行切换使用明文登录  *必须通过全局属性设置：EFUN_ATTR_LOGIN_AES_ENC_RESULT
    
    // nvr给ipc升级结果相关错误
    EE_UPGRADE_IPC_NO_ENOUGH_MEMORY = -400201, // 1 内存不足
    EE_UPGRADE_IPC_INVALID_FORMAT = -400202, // 2 升级文件格式不对
    EE_UPGRADE_IPC_PART_FAIL = -400203, // 3 某个分区升级失败
    EE_UPGRADE_IPC_INVALID_HARD_WARE = -400204, // 4 硬件型号不匹配
    EE_UPGRADE_IPC_INVALID_WENDOR = -400205, // 5 客户信息不匹配
    EE_UPGRADE_IPC_INVALID_COMPATIBLE = -400206, // 6 升级程序的兼容版本号比设备现在的小，不允许设备升级回老程序
    EE_UPGRADE_IPC_INVALID_VERSION = -400207, // 7 无效的版本
    EE_UPGRADE_IPC_INVALID_WIFI_DIRVER = -400208, // 8 升级程序里wifi驱动和设备当前在使用的wifi网卡不匹配
    EE_UPGRADE_IPC_NETWORK = -400209, // 9 网络出错
    EE_UPGRADE_IPC_NOT_SUPPORT_CUR_FLASH = -400210, // 10 升级程序不支持设备使用的flash
    EE_UPGRADE_IPC_FIRMWARE_CRACKED = -400211, // 11  升级文件被修改，不能通过外网升级
    EE_UPGRADE_IPC_NOT_SUPPORT_ABILITY = -400212, // 12 升级此固件需要特殊能力支持

    // 一些FunSDK内部自定义错误
    EE_SDK_COMMON_NOT_SUP_RPS_VIDEO = -500001, // 不支持rps预览视频 （rps在线 & rps视频预览能力级不支持 & dss不在线）
	EE_SDK_SAME_CHANNEL_OPEN_VIDEO_FAILED = -500002, // 设备同一个通道打开视频失败(SDK不支持某一通道同时打开两路相同类型的码流，只允许同时打开主辅码流)
	EE_SDK_DEV_NOT_LOGIN_ERROR = -500003, ///< 设备未登录，直接返回错误(具体错误未知)
	EE_START_SUCCESSFUL_BUT_NO_STREAM_FOR_LONG_TIME = -500004,  ///< 播放成功但是长时间无码流(24s)
	EE_START_SUCCESSFUL_BUT_STREAM_WAS_ABNORMAL = -500005,  ///< 播放成功但是码流异常(3s)
	EE_GWM_MEDIA_DISCONNECT = -500006,  ///< GWM媒体通道异常断开(网络相关错误多次尝试后)

	// HTTP协议通用错误
	EE_HTTP_MOVED_PERMANENTLY = -500301, 		///< 301 请求被转移(被请求的资源已被永久移动到新位置。客户端应使用新的URI重发请求)
	EE_HTTP_NOR_MODIFIED = -500304, 			///< 304 资源未被修改(客户端发送了一个带条件的请求，服务器告诉客户端资源未被修改，可以使用缓存的版本)
    EE_HTTP_INVALIDREQ = -500400, 			    ///< 400 无效请求(表示服务器无法理解或无法处理客户端发送的请求，可能是请求格式不正确或缺少必需的参数)
    EE_HTTP_UNAUTHORIZED = -500401, 			///< 401 未授权(表示客户端需要进行身份验证才能获得请求的资源)
    EE_HTTP_FORBIDDEN = -500403, 				///< 403 禁止访问(表示客户端已被服务器拒绝访问所请求的资源，没有权限访问)
    EE_HTTP_NOT_FOUND = -500404, 				///< 404 未找到(表示服务器无法找到请求的资源，即请求的URL无效或不存在)
    EE_HTTP_INTERNAL_SERVER_ERROR = -500500, 	///< 500 服务器内部错误(服务器内部错误。表示服务器在处理请求时发生了意外错误，无法完成请求)
    EE_HTTP_SERVER_UNAVAIL = 500503, 		    ///< 503 服务不可用(表示服务器暂时无法处理请求，通常是由于服务器过载或维护而导致)
	EE_HTTP_GATEWAY_TIMEOUT = 500504, 			///< 504 响应超时(作为网关或代理的服务器在等待上游服务器的响应时超时)

    //用户相关
	// 用户服务返回错误码 rs.xmeye.net / 从服务器端获取设备的能力集返回错误码 caps.jftechws.com
	EE_ACCOUNT_HTTP_MOVED_PERMANENTLY = -600301, 		///< 301 请求被转移(被请求的资源已被永久移动到新位置。客户端应使用新的URI重发请求)
	EE_ACCOUNT_HTTP_NOR_MODIFIED = -600304, 				///< 304 资源未被修改(客户端发送了一个带条件的请求，服务器告诉客户端资源未被修改，可以使用缓存的版本)
	EE_ACCOUNT_HTTP_INVALIDREQ = -600400, 			    ///< 400 无效请求(表示服务器无法理解或无法处理客户端发送的请求，可能是请求格式不正确或缺少必需的参数)
	EE_ACCOUNT_HTTP_UNAUTHORIZED = -600401, 			///< 401 未授权(表示客户端需要进行身份验证才能获得请求的资源)
	EE_ACCOUNT_HTTP_FORBIDDEN = -600403, 				///< 403 禁止访问(表示客户端已被服务器拒绝访问所请求的资源，没有权限访问)
	EE_ACCOUNT_HTTP_NOT_FOUND = -600404, 				///< 404 未找到(表示服务器无法找到请求的资源，即请求的URL无效或不存在)
	EE_ACCOUNT_HTTP_INTERNAL_SERVER_ERROR = -600500, 	///< 500 服务器内部错误(服务器内部错误。表示服务器在处理请求时发生了意外错误，无法完成请求)
	EE_ACCOUNT_HTTP_SERVER_UNAVAIL = -600503, 		    ///< 503 服务不可用(表示服务器暂时无法处理请求，通常是由于服务器过载或维护而导致)
	EE_ACCOUNT_HTTP_GATEWAY_TIMEOUT = -600504, 			///< 504 响应超时(作为网关或代理的服务器在等待上游服务器的响应时超时)
    EE_ACCOUNT_CERTIFICATE_CHECK_FAILED = -603000, 			   // FunSDK证书合法性验证校验失败 *不合法UUID或者AppKey不允许使用
    EE_ACCOUNT_JSON_DATA_FORMAT_VERIFICATION_FAILED = -603001, // json数据格式校验失败
    EE_ACCOUNT_CUSTOM_LOGIN_USERNAME_OR_PASSWORD_IS_EMPTY = -603002, // 登录用户名或密码为空
	EE_ACCOUNT_LOGIN_ACCESS_TOKEN_IS_EMPTY = -603003, // 登录Token为空
	EE_ACCOUNT_THIRD_PARTY_LOGIN_TYPE_IS_EMPTY = -603004, // 第三方登录类型参数为空 (微信“wx”， Google“gg”，Facebook“fb”，line是“line”)
	EE_ACCOUNT_RESULT_CONTENT_IS_EMPTY = -603005, ///< 返回的结果内容为空
	EE_ACCOUNT_STRING_LENGTH_CANNOT_EXCEED_8192_BYTES = -603006, ///< 字符串不能超过8192字节

    EE_ACCOUNT_HTTP_USERNAME_PWD_ERROR = -604000,     //4000 : 用户名或密码错误
    EE_ACCOUNT_VERIFICATION_CODE_ERROR = -604010,     //4010 : 验证码错误
    EE_ACCOUNT_PASSWORD_NOT_SAME = -604011,           //4011 : 密码不一致
    EE_ACCOUNT_USERNAME_HAS_BEEN_REGISTERED = -604012,//4012 : 用户名已被注册
    EE_ACCOUNT_USERNAME_IS_EMPTY = -604013,           //4013 : 用户名为空
    EE_ACCOUNT_PASSWORD_IS_EMPTY = -604014,                    //4014 : 密码为空
    EE_ACCOUNT_COMFIRMPWD_IS_EMPTY = -604015,                  //4015 : 确认密码为空
    EE_ACCOUNT_PHONE_IS_EMPTY = -604016,                       //4016 : 手机号为空
    EE_ACCOUNT_USERNAME_FORMAT_NOT_CORRECT = -604017,          //4017 : 用户名格式不正确
    EE_ACCOUNT_PASSWORD_FORMAT_NOT_CORRECT = -604018,          //4018 : 密码格式不正确
    EE_ACCOUNT_COMFIRMPWD_FORMAT_NOT_CORRECT = -604019,        //4019 : 确认密码格式不正确
    EE_ACCOUNT_PHONE_FORMAT_NOT_CORRECT = -604020,             //4020 : 手机号格式不正确
    EE_ACCOUNT_PHONE_IS_EXIST = -604021,                       //4021 : 手机号已存在
    EE_ACCOUNT_PHONE_NOT_EXSIT = -604022,                      //4022 : 手机号不存在
    EE_ACCOUNT_EMAIL_IS_EXIST = -604023,                       //4023 : 邮箱已存在
    EE_ACCOUNT_EMAIL_NOT_EXIST = -604024,                      //4024 : 邮箱不存在
    EE_ACCOUNT_OLD_PASSWORD_ERROR = -604026,                   //4026 : 原始密码错误
    EE_ACCOUNT_MODIFY_PASSWORD_ERROR = -604027,                //4027 : 修改密码失败
	EE_ACCOUNT_RESET_PASSWORD_LINK_EXPIRED = -604028, 		   //4028 : 用户找回密码链接过期
    EE_ACCOUNT_USERID_IS_EMPTY = -604029,                      //4029 : 用户ID为空
    EE_ACCOUNT_VERIFICATION_CODE_IS_EMPTY = -604030,           //4030 : 验证码为空
    EE_ACCOUNT_EMAIL_IS_EMPTY = -604031,                       //4031 : 邮箱为空
    EE_ACCOUNT_EMAIL_FORMATE_NOT_CORRECT = -604032,            //4032 : 邮箱格式不正确
	EE_ACCOUNT_USER_CP_PASS_NOTALLOWED = -604033,			   //4033 : 无权限不允许用户 ？？？咋翻译
    EE_ACCOUNT_USER_NOT_WX_BIND = -604034,                      //4034: 用户未绑定(用户名密码错误，标示用户未绑定雄迈账户，应跳转到绑定用户界面)（微信没有绑定）
	EE_ACCOUNT_USER_FAIL_WX_BIND = -604035,                     //4035: 用户绑定失败
    EE_ACCOUNT_USER_FAIL_PHONE_BIND  = -604036,                 //4036: 手机绑定失败
    EE_ACCOUNT_USER_FAIL_MAIL_BIND = -604037,                   //4037: 邮箱绑定失败
    EE_ACCOUNT_USER_SEND_CODE_FAIL_OR_MAXCOUNT = -604038,       //4038:	发送验证码超过最大次数
	EE_ACCOUNT_REG_FAIL = -604039,                   		//4039: 注册失败
	EE_ACCOUNT_USER_HAS_WX_BIND = -604040,      			//4040:	微信已绑定用户
	EE_ACCOUNT_USER_EDIT_USERNAME_NOAUTH = -604041,         //4041: 没有权限修改用户名（仅针对生成的匿名用户修改）
	EE_ACCOUNT_USER_NOT_FB_BIND = -604042,                  //4042: 用户没有绑定facebook
	EE_ACCOUNT_USER_FAIL_FB_BIND = -604043,       			//4043:	用户绑定facebook失败
	EE_ACCOUNT_USER_NOT_GG_BIND = -604044,                  //4044: 用户没有google绑定
	EE_ACCOUNT_USER_FAIL_GG_BIND = -604045,       			//4045:	用户绑定google失败
	EE_ACCOUNT_USER_NOT_LINE_BIND = -604046,                  //4046: Line账户未绑定
	EE_ACCOUNT_USER_FAIL_LINE_BIND = -604047,       			//4047:	Line账户绑定失败
	EE_ACCOUNT_USER_VERIFICATION_LIMIT_EXCEEDED = -604048,  // 4048 用户验证码错误次数太多，验证码失效
    EE_ACCOUNT_USER_TOO_MANY_INCORRECT_LOGINS = -604049,    // 4049 用户错误登陆次数太多，锁定账户十分钟
    EE_ACCOUNT_USER_REQUEST_TOO_FREQUENT = -604050,  		// 4050 请求太频繁，请稍后尝试
	EE_ACCOUNT_USER_INACTIVE = -604056, 					// 4056 用户未激活
	EE_ACCOUNT_USER_PASSWORD_NOT_RECOVERED = -604065, 		 // 4065 用户未找回密码，app端应继续监听


    //设备相关
    EE_ACCOUNT_DEVICE_ILLEGAL_NOT_ADD = -604100,        	//4100 : 设备非法不允许添加
    EE_ACCOUNT_DEVICE_ALREADY_EXSIT = -604101,          	//4101 : 设备已经存在（等同EE_USER_NO_DEV）
    EE_ACCOUNT_DEVICE_DELETE_FAIL = -604102,            	//4102 : 删除设备失败
    EE_ACCOUNT_DEVICE_CHANGE_IFNO_FAIL = -604103,       	//4103 : 设备信息修改失败
    EE_ACCOUNT_DEVICE_UUID_ILLEGAL = -604104,           	//4104 : 设备uuid参数异常
    EE_ACCOUNT_DEVICE_USERNAME_ILLEGAL = -604105,        	//4105 : 设备用户名参数异常
    EE_ACCOUNT_DEVICE_PASSWORD_ILLEGAL = -604106,        	//4106 : 设备密码参数异常
    EE_ACCOUNT_DEVICE_PORT_ILLEGAL = -604107,            	//4107 : 设备端口参数异常
    EE_ACCOUNT_DEVICE_EXTEND_ILLEGAL = -604108,             //4108 : 设备扩展字段参数异常（DEV_EXT_FAIL）
	EE_ACCOUNT_DEV_PASS_CONPASS_DIFF = -604109,            	//4109 :
	EE_ACCOUNT_DEV_NEW_PASSWORD_FAIL = -604110,            	//4110 : 新密码校验失败
	EE_ACCOUNT_DEV_CONFIRM_PASSWORD_FAIL = -604111,         //4111 : 确认密码校验失败
	EE_ACCOUNT_DEV_NICKNAME_FAIL = -604112,            		//4112 : 设备别名校验失败
	EE_ACCOUNT_DEV_IP_FAIL = -604113,            			//4113 :
	EE_ACCOUNT_DEV_CLOUD_STORAGE_SUPPORT = -604114,         //4114 : 云存储支持
	EE_ACCOUNT_DEV_CLOUD_STORAGE_UNSUPPORT = -604115,       //4115 : 云存储不支持
	EE_ACCOUNT_SETMA_FAIL = -604116,            			//4116 : 将设备主账户移交给其他用户失败，检查用户是否拥有设备并且该用户拥有设备主账户权限
	EE_ACCOUNT_NOT_MASTER_ACCOUNT = -604117,                //4117 : 当前账户不是当前设备的主账户
    EE_ACCOUNT_DEVICE_NOT_EXSIT = -604118,                  //4118 : 设备不存在了 已经被移除了
    EE_ACCOUNT_DEVICE_ADD_NOT_UNIQUE = -604119, 			//4119 添加设备不唯一，其他账户已添加  //主要针对5G看看，账户绑定
    EE_ACCOUNT_DEVICE_ADD_MAX_LIMIT = -604120, 				//4120 添加设备最大限制（100） // 添加设备100个限制返回，主要针对之前超过100个能添加成功，但是设备列表无法显示。
    EE_ACCOUNT_DEV_SUPTOKEN_CAN_ONLY_ADDED_BY_ONE_ACCOUNT = -604126, 		// 4126 设备支持令牌、只能由一个账户添加
	EE_ACCOUNT_TOKEN_IS_MISSING = -604127, 		// 4127 缺少设备令牌
	EE_ACCOUNT_DEV_PID_FAIL = -604129, // 4129 设备PID参数异常(长度大于60)

	//授权系统
    EE_ACCOUNT_ADD_OPEN_APP_FAIL = -604200,                //4200 : 添加授权失败
    EE_ACCOUNT_UPDATE_OPEN_APP_FAIL = -604201,            //4201 : 修改授权失败
    EE_ACCOUNT_DELETE_OPEN_APP_FAIL = -604202,            //4202 : 删除授权失败
    EE_ACCOUNT_SYN_TYPE_APP_FAIL = -604203,               //4203 : 单个授权同步失败(原因可能是type参数不对,或者云产品线未返回)
    //发送邮件授权码
    EE_ACCOUNT_SEND_CODE_FAIL  = -604300,                //4300 : 发送失败
	EE_ACCOUNT_MAIL_SIGN_FAIL  = -604301,                //4301 : 邮箱签名失败
	EE_ACCOUNT_CANCELLATION_CODE  = -604302,          	 //4302 :  注销账号需要验证码
	EE_ACCOUNT_REGISTER_SEND_MAIM_FAIL = -604303, 		 //4303 : 注册邮件发送超过次数，每个邮箱一天只能发送五次
	EE_ACCOUNT_RESET_PASSWORD_SEND_MAIM_FAIL = -604304,  //4304 : 找回密码邮件发送超过次数，每个邮箱一天只能发送五次

    //发送手机授权码
    EE_ACCOUNT_SEND_CODE_PHONE_INTERFACE_FAIL  = -604400,   //4400 : 短信接口验证失败，请联系我们
    EE_ACCOUNT_SEND_CODE_PHONE_PARAM_FAIL = -604401,        //4401 : 短信接口参数错误，请联系我们
    EE_ACCOUNT_SEND_CODE_PHONE_NUMBER_FAIL = -604402,       //4402 : 短信发送超过次数，每个手机号一天只能发送三次
    EE_ACCOUNT_SEND_CODE_PHONE_SEND_FAIL = -604403,         //4403 : 发送失败，请稍后再试
    EE_ACCOUNT_SEND_CODE_PHONE_TIME_FAIL= -604404,          //4404 : 发送太频繁了，请间隔120秒
    EE_ACCOUNT_SEND_CODE_PHONE_NONE_FAIL= -604405,          //4405 : 发送失败
    //开放平台接口
    EE_ACCOUNT_OPEN_USER_LIST_NULL = -604500,               //4500 : 未查到用户列表或用户列表为空
    EE_ACCOUNT_OPEN_DEVICE_LIST_NULL = -604502,             //4502 : 未查到设备列表或设备列表为空
    EE_ACCOUNT_RESET_OPEN_APP_SECRET_FAIL = -604503,        //4503 : 重置 app secret 失败
	EE_ACCOUNT_WX_PMS_OPEN_FAIL = -604600,                 //4600 : 微信报警打开失败
	EE_ACCOUNT_WX_PMS_CLOSE_FAIL = -604601,                //4601 : 微信报警关闭失败
	//服务器异常错误
    EE_ACCOUNT_HTTP_SERVER_ERROR = -605000 ,                   //5000 : 服务器故障
    EE_ACCOUNT_CERTIFICATE_NOT_EXIST = -605001,                //5001 : 证书不存在
    EE_ACCOUNT_HTTP_HEADER_ERROR = -605002,                    //5002 : 请求头信息错误
    EE_ACCOUNT_CERTIFICATE_FAILURE = -605003,                  //5003 : 证书失效
    EE_ACCOUNT_ENCRYPT_CHECK_FAILURE = -605004,                //5004 : 生成密钥校验错误
    EE_ACCOUNT_PARMA_ABNORMAL = -605005,                       //5005 : 参数异常
    EE_ACCOUNT_CONNECTION_FAILURE = -605006,                   //5006 : 连接失败
    EE_ACCOUNT_NODE_ERROR = -605007,                           //5007 : 未知错误
    EE_ACCOUNT_IP_NOT_ALLOWED = -605008,                       //5008 : ip地址不允许接入
    EE_ACCOUNT_DECRYPT_ERROR = -605009,                        //5009 : 解密错误，说明用户名密码非法 微信code错误、AES加解密错误
    EE_ACCOUNT_TOKEN_EXPIRED = -605010,                    	   //5010 : token已过期
	EE_ACCOUNT_TOKEN_ERROR = -605011,                    	   //5011 : token错误
	EE_ACCOUNT_TOKEN_NO_AUTHORITY = -605012,                   //5012 : token无权限
	EE_ACCOUNT_TNOT_SUPPORT = -605013,                    	   //5013 : 不支持
	EE_ACCOUNT_OPERATION_TOO_FREQUENT = -605014,               //5014 : 操作太频繁
	EE_ACCOUNT_APP_INFO_EXPIRATION = -605017,				   //5017 : APP缓存信息过期
    EE_ACCOUNT_LOGINTYPE_INVALID = -606000,                     //6000 : 无效登录方式？

    EE_ACCOUNT_NEW_PWD_FORMAT_NOT_CORRECT = -661427,           //1427 : 新密码格式不正确
    EE_ACCOUNT_USER_IS_NOT_EXSIT = -661412,                    //1412 : 用户名不存在

	EE_ACCOUNT_MYPHONE_LOGIN_TOO_MANY_TIMES = -619001, //手机号本机登录太过频繁(一分钟限制三次)

	EE_ACCOUNT_WX_HAS_BEEN_BOUND = -619004, //微信账号已被绑定
	EE_ACCOUNT_BATCH_DELETE_DEVS_EXCEEDS_LIMIT  = -619009, //批量删除设备数量超出最大限制

	//设备通用错误 -70000 设备错误码wiki:http://10.2.11.100/pages/viewpage.action?pageId=39492743
    EE_DVR_ERROR_BEGIN = -70000,                              // 透转DVR的错误值
    //设备通用错误
    EE_DVR_USER_NOT_EXIST = -70113,                            //113 : 该用户不存在
    EE_DVR_GROUP_EXIST = -70114,                            //114 : 该用户组已经存在
    EE_DVR_GROUP_NOT_EXIST = -70115,                        //115 : 该用户组不存在
    EE_DVR_NO_PTZ_PROTOCOL= -70118,                            //118 : 未设置云台协议
    EE_DVR_MEDIA_CHN_NOTCONNECT    = -70121,                    //121 : 数字通道未连接
    EE_DVR_TCPCONNET_REACHED_MAX = -70123,                    //123 : Tcp视频链接达到最大，不允许新的Tcp视频链接
    EE_DVR_LOGIN_ARGO_ERROR    = -70124,                        //124 : 用户名和密码的加密算法错误
    EE_DVR_LOGIN_NO_ADMIN = -70125,                            //125 : 创建了其它用户，不能再用admin登陆
    EE_DVR_LOGIN_TOO_FREQUENTLY    = -70126,                    //126 : 登陆太频繁，稍后重试
    EE_DVR_FORBID_4G_REMOTE_VIDEO = -70128,                       //128 : 禁止4G远程看视频
	EE_IPC_FORBID_REMOTE_LOGIN = -70129,                       //129 : 禁止远程登陆
    EE_DVR_NAS_EXIST = -70130,                                //130 : NAS地址已存在
    EE_DVR_NAS_ALIVE = -70131,                                //131 : 路径正在被使用，无法操作
    EE_DVR_NAS_REACHED_MAX = -70132,                        //132 : NAS已达到支持的最大值,不允许继续添加
    EE_DEV_LOGIN_TOKEN_ERROR = -70137, 						// 137 : 设备登录Token错误
    EE_DVR_CONSUMER_OPR_WRONG_KEY = -70140,                    //140 : 消费类产品遥控器绑定按的键错了
    EE_DVR_NEED_REBOOT = -70150,                            //150 : 成功，设备需要重启
    EE_DEV_NOT_REMOVE = -70151, 								// 文件没有删除成功
	EE_DVR_NO_SD_CARD = -70153,                                 //153 ：没有SD卡或硬盘
    EE_DVR_CONSUMER_OPR_SEARCHING = -70162,                    //162 : 设备正在添加过程中
    EE_DVR_CPPLUS_USR_PSW_ERR = -70163,                        //163 : APS客户特殊的密码错误返回值
	EE_DEV_NO_SPACE = -70164,                        		//164 : 设备空间不够
    EE_DEV_CONNET_REACHED_MAX = -70165,				  		// 165：(IOT设备)对端连接数已达上限
	EE_DEV_NO_ENABLE = -70170,				  				  // 170:功能未启用
	EE_DEV_NETIP_CONNECT_SERVER_ERROR = -70173,				  // 173:连接服务器失败
	EE_DEV_NO_MEMORY = -70174,				  				  // 174:检测不到内存
	EE_DEV_FUNC_STARTED = -70180,				  			  // 180:功能已经启动
	EE_DEV_NET_INIT_FAILED = -70181,				  		  // 181:网络初始化失败
	EE_DEV_SYSTEM_FAILED = -70182,				  		  	  // 182:系统错误
	EE_DEV_OPERATION_FAILED = -70183,				  		  // 183:操作失败
	EE_DEV_POWER_MODE_SWITCHING_FAILED = -70184,			  // 184:低功耗模式切换到常电模式失败
	EE_DEV_ACCOUNT_TRIAL_PERIOD_END = -70218,			  // 218:试用期已结束，解锁密码不正确
	EE_DEV_ACCOUNT_MANY_SAFTY_ANSWER_TRY_TIMES = -70219,  // 219:重置密码功能，安全问题尝试次数太多
	EE_DEV_ACCOUNT_SAFTY_ANSWER_ERROR = -70220,			  // 220:安全问题答案错误
	EE_DEV_ACCOUNT_MANY_RESTORE_VERIFY_CODE_TRY_TIMES = -70221,	// 221:重置密码功能，恢复默认验证码尝试次数太多
	EE_DEV_ACCOUNT_RESTORE_VERIFY_CODE_ERROR = -70222,	// 222:恢复默认验证码错误


    EE_DVR_XMSDK_UNKOWN                 = -79001,      // 未知错误
    EE_DVR_XMSDK_INIT_FAILED            = -79002,    // 查询服务器失败
    EE_DVR_XMSDK_INVALID_ARGUMENT        = -79003,     // 参数错误
    EE_DVR_XMSDK_OFFLINE                    = -79004,     // 离线
    EE_DVR_XMSDK_NOT_CONNECT_TO_SERVER        = -79005,     // 无法连接到服务器
    EE_DVR_XMSDK_NOT_REGISTER_TO_SERVER        = -79006,    // 向连接服务器注册失败
    EE_DVR_XMSDK_CONNECT_IS_FULL            = -79007,    // 连接数已满
    EE_DVR_XMSDK_NOT_CONNECTED                = -79008,    // 未连接
    EE_DVR_XMSDK_CONNECT_IS_TIMEOUT         = -79020,    // 连接超时
    EE_DVR_XMSDK_CONNECT_REFUSE                = -79021,    // 连接服务器拒绝连接请求
    EE_DVR_XMSDK_QUERY_STATUS_TIMEOUT        = -79022,    // 查询状态超时
    EE_DVR_XMSDK_QUERY_WANIP_TIMEOUT        = -79023,    // 查询外网信息超时
    EE_DVR_XMSDK_HANDSHAKE_TIMEOUT            = -79024,    // 握手超时
    EE_DVR_XMSDK_QUERY_SERVER_TIMEOUT        = -79025,    // 查询服务器失败
    EE_DVR_XMSDK_HEARTBEAT_IS_TIMEOUT        = -79026,    // 心跳超时
    EE_DVR_XMSDK_MSGSVR_ERRNO_DISCONNECT    = -79027,    // 连接断开
    
    //网络操作错误号
    EE_COMMAND_INVALID = -70502,                // 502 : 命令不和法
//    EE_TALK_ALAREADY_START = -70503,            // 503 : 对讲已经开启
//    EE_TALK_NOT_START = -70504,                 // 504 : 对讲未开启
    EE_UPGRADE_ALAREADY_START = -70511,         // 511 : 已经开始升级
    EE_UPGRADE_NOT_START = -70512,              // 512 : 未开始升级
    EE_UPGRADE_DATA_ERROR = -70513,             // 513 : 升级数据错误
    EE_UPGRADE_FAILED = -70514,                 // 514 : 升级失败
    //EE_UPGRADE_SUCCRSS = -70515,                // 515 : 升级成功
    EE_UPGRADE_FAILED_BUSY = -70516,            // 516 : 设备忙或云升级服务器忙
    EE_UPGRADE_NO_POWER = -70517,               // 517 : 该升级由其他连接开启，无法停止
    EE_UPGRADE_ALREADY_NEW = -70518,               // 518 : 前端设备已是最新版本
    EE_UPGRADE_FILE_ERROR = -70519,               // 519 : 升级文件不匹配
    EE_DEV_IPC_NOT_ONLINE = -70520,              // 520 : 前端设备不在线
    EE_SET_DEFAULT_FAILED = -70521,              // 521 : 还原默认失败
    EE_SET_DEFAULT_REBOOT = -70522,              // 522 : 需要重启设备
    EE_SET_DEFAULT_VALIDATEERROR = -70523,       //  523 : 默认配置非法
    EE_NET_OPERATION_BLE_PAIR_HAS_BEGUN = -70524,       //  524 : 蓝牙配对已经开始
    EE_NET_OPERATION_BLE_PAIR_ADD_UPPER_LIMIT = -70525, //  525 : 蓝牙配对添加到达上限
    EE_NET_OPERATION_LOW_ELECT_STOP_PTZ = -70526,       //  526 : 低电量不支持操控云台
    EE_NET_OPERATION_SENDTO_HOST_FAILED = -70527,       //  527 : 消息发给主控失败了(650+3861L门锁用)

    // 800000： BCloud365轻量化账户服务相关错误码
    EE_BCLOUD365_SERVER_UNAUTHORIZED = -800401, // 401 未授权
    EE_BCLOUD365_SERVER_FORBIDDEN = -800403, // 403 禁止
    EE_BCLOUD365_SERVER_NOT_FOUND = -800404, // 404 不存在
	EE_BCLOUD365_SERVER_ERROR = -800500, // 500 服务器内部错误
	EE_BCLOUD365_EMPLOYEE_DOES_NOT_EXIST = -803001, // 3001 员工不存在
    EE_BCLOUD365_FAILED_TO_UPDATE_EMPLOYEE_INFORMATION = -803002, // 3002 更新员工信息失败
	EE_BCLOUD365_DEPARTMENT_INFORMATION_DOES_NOT_EXIST = -803003, // 3003 部门信息不存在（基本用不到这个，可忽略）
	EE_BCLOUD365_SERVER_USERNAME_PWD_ERROR = -803004, // 3004 用户名或密码错误
	EE_BCLOUD365_ACCOUNT_HAS_BEEN_DISABLED = -803005, // 3005 您的账号已被禁用，不得登录系统
	EE_BCLOUD365_LOGIN_ALREADY_EXISTS = -803006, // 3006 登录名已存在
	EE_BCLOUD365_PASSWORD_IS_ENTERED_INCORRECTLY = -803007, // 3007 密码输入有误，请重新输入
	EE_BCLOUD365_PHONE_NUMBER_ALREADY_EXISTS = -803008, // 3008 手机号已存在
	EE_BCLOUD365_ID_CARD_ERROR = -803009, // 3009 身份证错误
	EE_BCLOUD365_BIRTHDAY_ERROR = -803010, // 3010 生日错误
	EE_BCLOUD365_VERIFICATION_CODE_ERROR = -803011, // 3011 验证码错误
	EE_BCLOUD365_FAILED_TO_UPDATE_ADMINISTRATOR_INFORMATION = -803012, // 3012 更新管理员信息失败
	EE_BCLOUD365_EXPIRED = -803013, // 3013 已过期
	EE_BCLOUD365_USERNAME_IS_INVALID = -803014, // 3014 用户名不合法
	EE_BCLOUD365_ACCOUNT_UNDER_REVIEW = -803015, // 3015 帐号审核中
	EE_BCLOUD365_PASSWORD_LENGTH_EXCEEDS_THE_LIMIT = -803016, // 3016 密码长度必须在6-32之间
	EE_BCLOUD365_FAILED_TO_UPDATE_MASTER_ACCOUNT = -803017, // 3017 更新bcloud365主账户失败
	EE_BCLOUD365_EMAIL_ALREADY_EXISTS = 803018, // 3018 邮箱已存在
	EE_BCLOUD365_SERVER_ROLE_NOT_EXIST = -806002,  // 6002 角色不存在，需要配置角色

	//810000：GWM(RPS-媒体网关)相关错误码
	EE_SDK_GWM_SERVER_IP_EMPTY = -810000, /**< 媒体网关服务器ip为空 */
	EE_SDK_GWM_RPS_ACCESS_CONNECT_FAILED = -810001, /**< 与RPS Access服务连接失败，重试*/
	EE_SDK_GWM_MSG_SEQ_CONFUSED = -810002, /**< 消息Seq错乱 */
	EE_SDK_GWM_DEV_PTL_FORMAT_EXCEPTION = -810003, /**< 协议格式异常 */
	EE_SDK_GWM_NO_RETURN_VALUE = -810004, /**< 协议无返回值 */
	EE_SDK_GWM_DEV_IS_NOT_STREAMING = -810202, /**< 202 设备未推流 */
	EE_SDK_GWM_TOKEN_AUTHENTICATION_FAILED = -810401, /**< 401 token认证未通过 */
	EE_SDK_GWM_AUTH_CODE_INVALID = -810403, /**< 403 authcode无效 */
	EE_SDK_GWM_INTERNAL_SERVER_ERROR = -810500, /**< 500 服务器内部错误 ps:通常是没有匹配到流服务器地址 */
	EE_SDK_GWM_RESPONSE_TIME_OUT = -810504, /**< 504 响应超时 */

	//820000: MQTT 相关错误码
	EE_MQTT_CLIENT_UNINIT = -820000, //MQTT客户端未初始化
	EE_MQTT_CLIENT_INIT_USERNAMENULL = -820001, //MQTT客户端初始化时UserID为空

	// -900000: JVSSS(IOT服务)相关错误码

	//-1000000 报警图片扩展错误码

	// -1100000 状态服务器相关错误码
	EE_STATUS_MSG_FORMAT_ERROR = -1120001, 		///< 20001 请求消息格式错误
	EE_STATUS_MSG_ERROR = -1120002, 			///< 20002 请求消息msg错误
	EE_STATUS_SN_ERROR = -1120003, 				///< 20003 请求消息sns错误
	EE_STATUS_CLASSIFY_ERROR = -1120004, 		///< 20004 分类失败
	EE_STATUS_FIND_REDIS_IP_ERROR = -1120005, 	///< 20005 查找redisIP失败
	EE_STATUS_INVAILD_REDIS_IP = -1120006, 		///< 20006 无效的redisIP
	EE_STATUS_QUERY_DEVICE_OVERLOAD = -1120007, ///< 20007 查询设备过多，单次请求最多支持查询50个不同的设备
	EE_STATUS_ALL_SN_INCORRECT = -1120008, 		///< 20008 设备sn码全部不正确
	EE_STATUS_CLIENT_IS_BLACKLIST = -1120009, 	///< 20009 客户端被拉黑

    // -1200000 CSS签名服务器相关错误码
    EE_AS_CSS_REQUEST_FAILED = -1200400, ///< 400 失败，（暂未归类的错误，具体参考ErrorString字段）
    EE_AS_CSS_ILLEGAL_DEVICE_SN = -1200401,///< 401 非法设备序列号
    EE_AS_CSS_PARAM_EXCEPTION = -1200402,///< 402 参数不全、必填参数为空或者参数类型不匹配
    EE_AS_CSS_NO_CLOUD_STORAGE_PACKAGE_PURCHASED = -1200403,///< 403 未开通云存储套餐或套餐已过期
    EE_AS_CSS_REQUEST_IMAGE_OR_VIDEO_NOT_EXIST = -1200404, ///< 404 请求的图片或视频不存在
    EE_AS_CSS_REGION_RESTRICTIONS = -1200405, ///< 405 区域限制，该存储桶禁止跨区域请求
    EE_AS_CSS_INTERNAL_ERROR = -1200500, ///< 500 内部错误，一般是redis或mysql访问失败
    EE_AS_CSS_NOT_SUPPORT_CLOUD_STORAGE = -1201001, ///< 1001 表示不支持云存储
    EE_AS_CSS_NO_CLOUD_STORAGE_PACKAGE_PURCHASED_OLD_ERROR_CODE = -1201002, ///< 1002 未购买云存储套餐或套餐已过期(此时不是上传云存储图片)(旧错误码)
    EE_AS_CSS_CLOUD_STORAGE_PACKAGE_ENABLE_SWITCH_TURNED_OFF = -1201003, ///< 1003 已经购买云存储套餐，但关闭了使能开关(此时不上传云存储图片)

	// -1300000 日志服务器相关错误码/
	EE_LOG_REQUEST_FAILED = -1300400, ///< 400 失败，请求的body参数不合法
	EE_LOG_INTERNAL_ERROR = -1300500, ///< 500 服务器内部错误
	EE_LOG_GET_DATA_FAIL = -1310001, ///< 10001 获取数据失败
	EE_LOG_AUTHCODE_ERROR = -1310003, ///< 10003 authcode校验失败

    // -1400000  AI服务相关错误码
    EE_AISERVER_REQUEST_FAILED = -1400400, ///< 400 失败
    EE_AISERVER_INTERNAL_ERROR = -1400500, ///< 500 服务器内部错误
}EFUN_ERROR;

// 对像属性
typedef enum EOBJ_ATTR
{
    EOA_DEVICE_ID = 10000,
    EOA_CHANNEL_ID = 10001,
    EOA_IP = 10002,
    EOA_PORT = 10003,
    EOA_IP_PORT = 10004,
    EOA_STREAM_TYPE = 10005,
    EOA_NET_MODE = 10006,
    EOA_COM_TYPE = 10007,
    EOA_VIDEO_WIDTH_HEIGHT = 10008,    // 获取视频的宽和高信息
    EOA_VIDEO_FRATE = 10009,          // 获取视频帧率信息
    EOA_VIDEO_BUFFER_SIZE = 10010,    // 获取缓冲的帧数
    EOA_PLAY_INFOR = 10011,
    EOA_PCM_SET_SOUND = 10012,          // -100~100
    EOA_CUR_PLAY_TIME = 10013,       // 获取当前播放的时间,返回uint64单位毫秒
    EOA_MEDIA_YUV_USER = 10014,                // 设置YUV回调
    EOA_SET_MEDIA_VIEW_VISUAL = 10015,        // 是否画视频数据
    EOA_SET_MEDIA_DATA_USER_AND_NO_DEC = 10016, //解码前数据回调，不播放
    EOA_SET_MEDIA_DATA_USER = 10017,    //解码前数据回调，同时播放
    EOA_DISABLE_DSS_FUN = 10018,            // 禁用DSS功能
    EOA_DEV_REAL_PLAY_TYPE = 10019,            // 实时媒体连接方式指定
    EOA_SET_PLAYER_USER = 10020,            // 设置回调消息接收者
    EOA_GET_ON_FRAME_USER_DATA = 10021,     // 重新回调一次信息帧（ON_FRAME_USER_DATA）,如果没有就没有回调
    EOA_GET_XTSC_CONNECT_QOS = 10022,   // 查询链接的传输效率 >0% <=0失败
    EOA_GET_ON_AUDIO_FRAME_DATA = 10023, // 获取当前音频帧信息，帧信息有变化实时更新
//    EOA_SET_AUDIO_FRAME_SAMPLES_TYPE = 10024, ///< @deprecated废弃，新增接口Fun_DevStartTalk支持采样频率设置
    EOA_SET_DEV_TALK_DATA_USER = 10025, // 设置对讲音频(设备端对讲过来的音频)数据回调
	EOA_IS_SHARED_MEDIA_LINK = 10026, ///< 共用同一媒体链接使能
}EOBJ_ATTR;

typedef enum EUPGRADE_STEP
{
    EUPGRADE_STEP_COMPELETE = 10,   // 完成升级
    EUPGRADE_STEP_DOWN = 1,         // 表示下载进度;(从服务器或网络下载文件到手机(云升级是下载到设备))
    EUPGRADE_STEP_UP = 2,           // 表示上传进度;(本地上传文件到设备)
    EUPGRADE_STEP_UPGRADE = 3,      // 升级过程
}EUPGRADE_STEP;

typedef struct Strings
{
    char str[6][512];
}Strings;


typedef enum EFUN_FUNCTIONS
{
    EFUN_ALL = 0,
    EFUN_DEV_REAL_PLAY,
    EFUN_DEV_PLAY_BACK,
    EFUN_DEV_CONFIG,
    EFUN_ALARM,
    EFUN_RECOD_CLOUD,
    EFUN_SHARE,
    EFUN_VIDEO_SQUARE,
    EFUN_UPGRADE,
    EFUN_END,
}EFUN_FUNCTIONS;

typedef enum EDEV_UPGRADE_TYPE
{
    EDUT_NONE,                  // 没有更新
    EDUT_DEV_CLOUD,             // 升级方式1:设备连接升级服务器升级
    EDUT_LOCAL_NEED_DOWN,       // 升级方式2:本地升级,但升级文件还没有下载下来
    EDUT_LOCAL_DOWN_COMPLETE,   // 升级方式3:本地升级,升级文件已经下载下来了
}EDEV_UPGRADE_TYPE;

typedef enum _EDEV_BACKUP_CONTROL  //备份录像到u盘操作
{
    EDEV_BACKUP_START = 1,  //备份开始
    EDEV_BACKUP_PROCESS,    // 进度查询
    EDEV_BACKUP_STOP,       // 停止备份
}EDEV_BACKUP_CONTROL;

// 设备协议常用命令ID
typedef enum EDEV_PTL_CMD
{
    EDEV_PTL_CONFIG_GET_JSON = 1042,
    EDEV_PTL_CONFIG_SET_JSON = 1040,
}EDEV_PTL_CMD;

typedef enum EDEV_STREM_TYPE
{
    EDEV_STREM_TYPE_FD,    //1、    流畅（等级0）：         分辨率＜40W像素
    EDEV_STREM_TYPE_SD,    //2、    标清（等级1）：   40W≤分辨率＜100W像素
    EDEV_STREM_TYPE_HD,    //3、    高清（等级2）   100W≤分辨率＜200W像素
    EDEV_STREM_TYPE_FHD,//4、    全高清（等级3） 200W≤分辨率＜400W
    EDEV_STREM_TYPE_SUD,//5、    超高清（等级4） 400W≤分辨率＜？？？
}EDEV_STREM_TYPE;

#define EDECODE_STREAM_LEVEL 7
typedef enum EDECODE_TYPE
{
    EDECODE_REAL_TIME_STREAM0,      // 最实时--适用于IP\AP模式等网络状态很好的情况
    EDECODE_REAL_TIME_STREAM1,      //
    EDECODE_REAL_TIME_STREAM2,      //
    EDECODE_REAL_TIME_STREAM3,      // 中等
    EDECODE_REAL_TIME_STREAM4,      //
    EDECODE_REAL_TIME_STREAM5,      //
    EDECODE_REAL_TIME_STREAM6,      // 最流畅--适用于网络不好,网络波动大的情况
    EDECODE_FILE_STREAM = 100,        // 文件流
} EDECODE_TYPE;
#define    EDECODE_REAL_TIME_DEFALUT EDECODE_REAL_TIME_STREAM4


typedef enum EFunDevStateType
{
    EFunDevStateType_P2P = 0,        //P2P要用新的状态服务查下
    EFunDevStateType_TPS_V0 = 1,     //老的那种转发，用于老程序（2016年以前的）的插座，新的插座程序使用的是TPS
    EFunDevStateType_TPS = 2,        //透传服务
    EFunDevStateType_DSS = 3,        //媒体直播服务
    EFunDevStateType_CSS = 4,        //云存储服务
    EFunDevStateType_P2P_V0 = 5,     //P2P用老的方式,通过穿透库查询获取到的设备P2P状态
    EFunDevStateType_IP = 6,         //IP方式
    EFunDevStateType_RPS = 7,        //RPS可靠的转发
    EFunDevStateType_IDR = 8,        //门铃状态
    EFunDevStateType_SIZE,           //NUM....
}EFunDevStateType;

#define FUN_CONTROL_NET_STATE ((1 << EFunDevStateType_P2P) | (1 << EFunDevStateType_TPS) | (1 << EFunDevStateType_P2P_V0) | (1 << EFunDevStateType_IP) | (1 << EFunDevStateType_RPS))
#define FUN_CONTROL_NET_STATE_NO_IP ((1 << EFunDevStateType_P2P) | (1 << EFunDevStateType_TPS) | (1 << EFunDevStateType_P2P_V0) | (1 << EFunDevStateType_RPS))

typedef enum EFunDevState
{
    EDevState_UNKOWN = 0,           // 未知
    EDevState_ON_LINE = 1,          // 在线（如果是门铃，同时说明在唤醒状态）
    EDevState_ON_SLEEP = 2,         // 休眠可唤醒状态
    EDevState_ON_SLEEP_UNWEAK = 3,  // 休眠不可唤醒状态
    EDevState_ON_SLEEPING = 4,      // 准备休眠中
    EDevState_OFF_LINE = -1,        // 不在线
    EDevState_NO_SUPPORT = -2,      // 不支持
    EDevState_NotAllowed = -3,      // 没权限
}EFunDevState;

/***************************************************
 * JPEG 鱼眼信息头处理接口
 */

#include "JPGHead.h"

/**
 * 鱼眼矫正信息写入,同jpghead_write_vrhw_exif和jpghead_write_vrsw_exif
 * return : 0成功, 非0失败
 */
int FUN_JPGHead_Write_Exif(char * srcPath, char * dstPath, FishEyeFrameParam * pFrame);

/**
 * 从文件中读取鱼眼矫正参数
 * return : 0成功, 非0失败(或者是非鱼眼图片)
 */
int FUN_JPGHead_Read_Exif(char * srcPath, FishEyeFrameParam * pFrame);

#ifdef SUP_IRCODE
void InfraRed_IRemoteClient_SetPath(char* strDataPath);
void InfraRed_IRemoteClient_LoadBrands(Brand_c* brands, int& num);
void InfraRed_IRemoteClient_LoadBrands(int type, Brand_c* brands, int& num);
void InfraRed_IRemoteClient_GetBrandNum(int type, int& num);
void InfraRed_IRemoteClient_GetRemoteNum(int& num);
void InfraRed_IRemoteClient_LoadRemotes(Remote_c* remotes, int &num);
void InfraRed_IRemoteClient_ExactMatchRemotes(MatchPage_c* page, Key_c* key, MatchResult_c* results, int& num);
void InfraRed_IRemoteClient_ExactMatchAirRemotes(MatchPage_c* page, Key_c* key, AirRemoteState_c* state, MatchResult_c* results, int& num);

void InfraRed_IRemoteManager_GetAllRooms(Room_c* rooms, int& num);
void InfraRed_IRemoteManager_GetRemoteFromRoom(Room_c room, Remote_c* remotes, int& num);
void InfraRed_IRemoteManager_GetRemoteByID(char* name, char* remote_id, Remote_c* remote);
void InfraRed_IRemoteManager_AddRemoteToRoom(Remote_c* remote, Room_c* room);
void InfraRed_IRemoteManager_DeleteRemoteFromRoom(Remote_c* remote, Room_c* room);
void InfraRed_IRemoteManager_AddRemote(Remote_c* remote);
void InfraRed_IRemoteManager_AddRoom(Room_c* room);
void InfraRed_IRemoteManager_DeleteRoom(Room_c* room);
void InfraRed_IRemoteManager_ChangeRoomName(Room_c* room, char* name);

void InfraRed_IInfraredFetcher_FetchInfrareds(Remote_c* remote, Key_c* key, Infrared_c* infrareds, int& num);
int InfraRed_IInfraredFetcher_GetAirRemoteStatus(Remote_c* remote, AirRemoteState_c* state);
int InfraRed_IInfraredFetcher_SetAirRemoteStatus(char* remote_name, AirRemoteState_c* state);
void InfraRed_IInfraredFetcher_FetchAirTimerInfrared(Remote_c* remote, Key_c* key, AirRemoteState_c* state, int time,  Infrared_c* infrareds, int& num);
void InfraRed_IInfraredFetcher_TranslateInfrared(char* code, unsigned char* data, int& num);
#endif

#endif // FUNSDK_H

