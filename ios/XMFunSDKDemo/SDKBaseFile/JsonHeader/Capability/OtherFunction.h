#pragma once
#import "FunSDK/JObject.h"

#define JK_OtherFunction "OtherFunction" 
class OtherFunction : public JObject
{
public:
	JBoolObj		AlterDigitalName;
	JBoolObj		DownLoadPause;
	JBoolObj		HddLowSpaceUseMB;
	JBoolObj		HideDigital;
	JBoolObj		MusicFilePlay;
	JBoolObj		NOHDDRECORD;
	JBoolObj		NotSupportAH;
	JBoolObj		NotSupportAV;
	JBoolObj		NotSupportTalk;
	JBoolObj		SDsupportRecord;
	JBoolObj		ShowAlarmLevelRegion;
	JBoolObj		ShowFalseCheckTime;
	JBoolObj		SupportAbnormitySendMail;
    JBoolObj        SupportAlarmLinkLight;
    JBoolObj        SupportAlarmVoiceTips;          // 是否支持报警提示音
    JBoolObj        SupportAlarmVoiceTipsType;  // 是否支持警戒提示音选择
	JBoolObj		SupportBT;
	JBoolObj		SupportC7Platform;
	JBoolObj		SupportCamareStyle;
	JBoolObj		SupportCameraMotorCtrl;
	JBoolObj		SupportCfgCloudupgrade;
	JBoolObj		SupportCloudUpgrade;
	JBoolObj		SupportCommDataUpload;
	JBoolObj		SupportCorridorMode;
	JBoolObj		SupportCustomOemInfo;
	JBoolObj		SupportDigitalEncode;
	JBoolObj		SupportDigitalPre;
	JBoolObj		SupportDimenCode;
	JBoolObj		SupportEncodeAddBeep;
	JBoolObj		SupportFTPTest;
	JBoolObj		SupportFishEye;
	JBoolObj		SupportImpRecord;
	JBoolObj		SupportMailTest;
	JBoolObj		SupportMaxPlayback;
	JBoolObj		SupportModifyFrontcfg;
	JBoolObj		SupportNVR;
	JBoolObj		SupportNetLocalSearch;
	JBoolObj		SupportOSDInfo;
	JBoolObj		SupportOnvifClient;
	JBoolObj		SupportPOS;
	JBoolObj		SupportPWDSafety;
	JBoolObj		SupportPlayBackExactSeek;
	JBoolObj		SupportPtzIdleState;
	JBoolObj		SupportRTSPClient;
	JBoolObj		SupportResumePtzState;
	JBoolObj		SupportSPVMNNasServer;
	JBoolObj		SupportSetDigIP;
	JBoolObj		SupportShowConnectStatus;
	JBoolObj		SupportShowProductType;
	JBoolObj		SupportSmallChnTitleFont;
	JBoolObj		SupportSnapCfg;
	JBoolObj		SupportSnapSchedule;
	JBoolObj		SupportSplitControl;
	JBoolObj		SupportStatusLed;
	JBoolObj		SupportStorageFailReboot;
	JBoolObj		SupportSwitchResolution;
	JBoolObj		SupportTextPassword;
	JBoolObj		SupportTimeZone;
	JBoolObj		SupportUserProgram;
	JBoolObj		SupportWIFINVR;
	JBoolObj		SupportWriteLog;
	JBoolObj		Supportonviftitle;
	JBoolObj		SuppportChangeOnvifPort;
	JBoolObj		TitleAndStateUpload;
    JBoolObj		SupportIntelligentPlayBack;
	JBoolObj		USBsupportRecord;
    JBoolObj        SupportDNChangeByImage;
    JBoolObj        SupportDoorLock;            //支持远程开锁
    JBoolObj        SupportMusicLightBulb;      //音乐灯
    JBoolObj        SupportCameraWhiteLight;    //是否支持白光灯
    JBoolObj        SupportDoubleLightBulb;     //双光灯
    JBoolObj        SupportDoubleLightBoxCamera;//双光枪机
    JBoolObj        SupportPushLowBatteryMsg;   // 设备是否支持电量低消息推送
    JBoolObj        SupportPirAlarm;            // 是否支持智能人体检测
    JBoolObj        SupportReserveWakeUp;       // 是否支持门铃来电预约
    JBoolObj        SupportIntervalWakeUp;      // 是否支持间隔录像功能
    JBoolObj        SupportNoDisturbing;        // 是否支持消息免打扰
    JBoolObj        SupportNotifyLight;         // 是否支持呼吸灯
    JBoolObj        SupportKeySwitchManager;    // 是否支持按键管理
    JBoolObj        SupportDevRingControl;      // 是否支持设备铃声
    JBoolObj        SupportForceShutDownControl;// 是否支持强制关机
    JBoolObj        SupportPirTimeSection;      // 是否支持PIR控制
    JBoolObj        Support433Ring;             // 433是否支持铃声设置
    JBoolObj        SupportSetVolume;           // XM510 Volume Control Ability
    JBoolObj        SupportAppBindFlag;         // 是否支持读写恢复出厂绑定状态
    JBoolObj        SupportGetMcuVersion;       // 是否支持单片机版本号获取
    JBoolObj        SupportCloseVoiceTip;       // 是否支持设备提示音
    JBoolObj        SupportSetPTZPresetAttribute;//是否支持预置点
    JBoolObj        SupportPTZTour;              //支持巡航
    JBoolObj        SupportSetDetectTrackWatchPoint;    // 是否支持守望功能
    JBoolObj        SupportDetectTrack;          // 是否支持移动追踪（人形跟随）
    JBoolObj        SupportTimingPtzTour;        // 定时巡航
    JBoolObj        SupportOneKeyMaskVideo;      // 是否支持一键遮蔽
    JBoolObj        SupportGunBallTwoSensorPtzLocate; //是否支持多目枪球云台定位

public:
    OtherFunction(JObject *pParent = NULL, const char *szName = JK_OtherFunction):
    JObject(pParent,szName),
	AlterDigitalName(this, "AlterDigitalName"),
	DownLoadPause(this, "DownLoadPause"),
	HddLowSpaceUseMB(this, "HddLowSpaceUseMB"),
	HideDigital(this, "HideDigital"),
	MusicFilePlay(this, "MusicFilePlay"),
	NOHDDRECORD(this, "NOHDDRECORD"),
	NotSupportAH(this, "NotSupportAH"),
	NotSupportAV(this, "NotSupportAV"),
	NotSupportTalk(this, "NotSupportTalk"),
	SDsupportRecord(this, "SDsupportRecord"),
	ShowAlarmLevelRegion(this, "ShowAlarmLevelRegion"),
	ShowFalseCheckTime(this, "ShowFalseCheckTime"),
	SupportAbnormitySendMail(this, "SupportAbnormitySendMail"),
    SupportAlarmLinkLight(this, "SupportAlarmLinkLight"),
    SupportAlarmVoiceTips(this, "SupportAlarmVoiceTips"),
    SupportAlarmVoiceTipsType(this,"SupportAlarmVoiceTipsType"),
	SupportBT(this, "SupportBT"),
	SupportC7Platform(this, "SupportC7Platform"),
	SupportCamareStyle(this, "SupportCamareStyle"),
	SupportCameraMotorCtrl(this, "SupportCameraMotorCtrl"),
	SupportCfgCloudupgrade(this, "SupportCfgCloudupgrade"),
	SupportCloudUpgrade(this, "SupportCloudUpgrade"),
	SupportCommDataUpload(this, "SupportCommDataUpload"),
	SupportCorridorMode(this, "SupportCorridorMode"),
	SupportCustomOemInfo(this, "SupportCustomOemInfo"),
	SupportDigitalEncode(this, "SupportDigitalEncode"),
	SupportDigitalPre(this, "SupportDigitalPre"),
	SupportDimenCode(this, "SupportDimenCode"),
	SupportEncodeAddBeep(this, "SupportEncodeAddBeep"),
	SupportFTPTest(this, "SupportFTPTest"),
	SupportFishEye(this, "SupportFishEye"),
	SupportImpRecord(this, "SupportImpRecord"),
	SupportMailTest(this, "SupportMailTest"),
	SupportMaxPlayback(this, "SupportMaxPlayback"),
	SupportModifyFrontcfg(this, "SupportModifyFrontcfg"),
	SupportNVR(this, "SupportNVR"),
	SupportNetLocalSearch(this, "SupportNetLocalSearch"),
	SupportOSDInfo(this, "SupportOSDInfo"),
	SupportOnvifClient(this, "SupportOnvifClient"),
	SupportPOS(this, "SupportPOS"),
	SupportPWDSafety(this, "SupportPWDSafety"),
	SupportPlayBackExactSeek(this, "SupportPlayBackExactSeek"),
	SupportPtzIdleState(this, "SupportPtzIdleState"),
	SupportRTSPClient(this, "SupportRTSPClient"),
	SupportResumePtzState(this, "SupportResumePtzState"),
    SupportPTZTour(this, "SupportPTZTour"),
    SupportSetPTZPresetAttribute(this, "SupportSetPTZPresetAttribute"),
    SupportMusicLightBulb(this, "SupportMusicLightBulb"),
    SupportDoubleLightBulb(this, "SupportDoubleLightBulb"),
    SupportCameraWhiteLight(this, "SupportCameraWhiteLight"),
    SupportDoorLock(this, "SupportDoorLock"),
    SupportDoubleLightBoxCamera(this, "SupportDoubleLightBoxCamera"),
	SupportSPVMNNasServer(this, "SupportSPVMNNasServer"),
	SupportSetDigIP(this, "SupportSetDigIP"),
	SupportShowConnectStatus(this, "SupportShowConnectStatus"),
	SupportShowProductType(this, "SupportShowProductType"),
	SupportSmallChnTitleFont(this, "SupportSmallChnTitleFont"),
	SupportSnapCfg(this, "SupportSnapCfg"),
	SupportSnapSchedule(this, "SupportSnapSchedule"),
	SupportSplitControl(this, "SupportSplitControl"),
	SupportStatusLed(this, "SupportStatusLed"),
	SupportStorageFailReboot(this, "SupportStorageFailReboot"),
	SupportSwitchResolution(this, "SupportSwitchResolution"),
	SupportTextPassword(this, "SupportTextPassword"),
	SupportTimeZone(this, "SupportTimeZone"),
	SupportUserProgram(this, "SupportUserProgram"),
	SupportWIFINVR(this, "SupportWIFINVR"),
	SupportWriteLog(this, "SupportWriteLog"),
	Supportonviftitle(this, "Supportonviftitle"),
	SuppportChangeOnvifPort(this, "SuppportChangeOnvifPort"),
	TitleAndStateUpload(this, "TitleAndStateUpload"),
    SupportIntelligentPlayBack(this, "SupportIntelligentPlayBack"),
	USBsupportRecord(this, "USBsupportRecord"),
    SupportDNChangeByImage(this, "SupportDNChangeByImage"),
    SupportPushLowBatteryMsg(this,"SupportPushLowBatteryMsg"),
    SupportPirAlarm(this,"SupportPirAlarm"),
    SupportReserveWakeUp(this,"SupportReserveWakeUp"),
    SupportIntervalWakeUp(this,"SupportIntervalWakeUp"),
    SupportNoDisturbing(this,"SupportNoDisturbing"),
    SupportNotifyLight(this,"SupportNotifyLight"),
    SupportKeySwitchManager(this,"SupportKeySwitchManager"),
    SupportDevRingControl(this,"SupportDevRingControl"),
    SupportForceShutDownControl(this,"SupportForceShutDownControl"),
    SupportPirTimeSection(this,"SupportPirTimeSection"),
    Support433Ring(this,"Support433Ring"),
    SupportSetVolume(this,"SupportSetVolume"),
    SupportAppBindFlag(this,"SupportAppBindFlag"),
    SupportGetMcuVersion(this,"SupportGetMcuVersion"),
    SupportCloseVoiceTip(this,"SupportCloseVoiceTip"),
    SupportSetDetectTrackWatchPoint(this,"SupportSetDetectTrackWatchPoint"),
    SupportDetectTrack(this,"SupportDetectTrack"),
    SupportTimingPtzTour(this,"SupportTimingPtzTour"),
    SupportGunBallTwoSensorPtzLocate(this,"SupportGunBallTwoSensorPtzLocate"),
    SupportOneKeyMaskVideo(this,"SupportOneKeyMaskVideo"){
	};

    ~OtherFunction(void){};
};
