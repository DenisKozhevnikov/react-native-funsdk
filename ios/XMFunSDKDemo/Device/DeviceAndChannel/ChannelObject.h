//
//  ChannelObject.h
//  FunSDKDemo
//
//  Created by XM on 2018/5/10.
//  Copyright © 2018年 XM. All rights reserved.
//
/***
 
 设备通道信息
 
 *****/
#import "ObjectCoder.h"

@interface ChannelObject : ObjectCoder

@property (nonatomic, copy) NSString *deviceMac;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, copy) NSString *loginName;
@property (nonatomic, copy) NSString *loginPsw;
@property (nonatomic) int channelNumber;  //通道号
@property (nonatomic) BOOL isFish;  //是否是全景矫正
//灯泡相关
@property (nonatomic, assign) int iSupportCameraWhiteLight; //支持白光灯控制
@property (nonatomic, assign) int iSupportSoftPhotosensitive; // 球机灯泡配置功能
@property (nonatomic, copy) NSString *sWorkMode;//白光灯模式
@property (nonatomic, assign) int iSupportMusicLightBulb;//支持音乐灯
@property (nonatomic, assign) int iSupportDoubleLightBoxCamera;//双光枪机
@property (nonatomic, assign) int iSupportBoxCameraBulb;  // BoxCameraBulb

@property (nonatomic, assign) int iSSupportSoftPhotoSensitiveMask;      //软光敏能力
@property (nonatomic, assign) int iSupportDoubleLightBulb;             //家用双光灯能力
@property (nonatomic, assign) int iSupportIntellDoubleLight;             //通用双光灯

@property (nonatomic, assign) int iSupportDetectTrack;                  // 是否支持移动追踪
@property (nonatomic, assign) int iSupportSetDetectTrackWatchPoint;     // 是否支持设置守望点

@property (nonatomic, assign) int iDayNightColor;//黑白彩色
@property (nonatomic, assign) int iStartHour; //开启时间
@property (nonatomic, assign) int iStartMinute; //开启时间

@property (nonatomic, assign) int iEndHour; //关闭时间
@property (nonatomic, assign) int iEndMinute; //关闭时间
@property (nonatomic, assign) int iLevel;//灵敏度
@property (nonatomic, assign) int ilightDuration;//持续时间

@property (nonatomic,assign) int iPEAInHumanPed;                // 是否支持人形检测
@property (nonatomic,assign) int isupportAlarmVoiceTipsType;
// 是否支持NVR人形检测
@property (nonatomic,assign) int HumanDectionNVRNew;

//是否支持DVR人形检测
@property (nonatomic, assign) BOOL HumanDectionDVR;
/**
 
下面两个分通道参数都是对应smart编码配置能力级
 smartH264 对应的是模拟通道
 smartH264V2 对应的是数字通道
 */
@property (nonatomic,assign) int smartH264;
@property (nonatomic,assign) int smartH264V2;

//白光灯数据获取成功标志
@property (nonatomic,assign) int dayNightColorConfig;
@property (nonatomic,assign) int whiteLightConfig;

//设备电量和信号强度信息
@property (nonatomic, strong) NSMutableDictionary *devWifiSignAndElectricInfoNotCode;
//PIR 报警能力级
@property (nonatomic, assign) BOOL lowPowerCameraSupportPir;

//是否支持音量设置(通道)
@property (nonatomic, assign) BOOL supportSetVolume;

//是否支持编码配置(不支持就不显示)
@property (nonatomic, assign) BOOL notSupportEncodeConfig;

//屏蔽手动录像选项，只保留“打开录像”、“关闭录像”两个选项
@property (nonatomic, assign) BOOL notSupportManualRecord;

//屏蔽录像码流选择界面
@property (nonatomic, assign) BOOL notSupportRecordStreamConfig;

//是否支持双目设备端变倍
@property (nonatomic,assign) int iSupportScaleTwoLensNotCode;
//是否支持三目设备端变倍
@property (nonatomic,assign) int iSupportScaleThreeLensNotCode;
@end
