//
//  DeviceObject.h
//  XMEye
//
//  Created by XM on 2018/4/13.
//  Copyright © 2018年 Megatron. All rights reserved.
//
/***
 
设备对象类
 
 *****/
#import "ObjectCoder.h"
#import "ChannelObject.h"

#import "ObSysteminfo.h"
#import "ObSystemFunction.h"

typedef enum device_type {
    DEVICE_TYPE_UnKnow, //没有获取过设备类型
    DEVICE_TYPE_DVR, //普通DVR设备
    DEVICE_TYPE_NVS, ///< NVS设备
    DEVICE_TYPE_IPC, ///< IPC设备
    DEVICE_TYPE_HVR, ///<混合dvr
    DEVICE_TYPE_IVR, ///<智能dvr
    DEVICE_TYPE_MVR,  ///<车载dvr
    DEVICE_TYPE_NR,
} device_type;

@interface DeviceObject : ObjectCoder

@property (nonatomic, copy) NSString *deviceMac; //设备序列号 16位或者20位字母+数字
@property (nonatomic, copy) NSString *deviceName; //设备名称
@property (nonatomic, copy) NSString *loginName; //登录名
@property (nonatomic, copy) NSString *loginPsw; //登录密码
@property (nonatomic, copy) NSString *deviceIp;  //设备的IP
/**  */
@property (nonatomic, assign) BOOL devTokenEnable;
@property (nonatomic) int state;     //在线状态
@property (nonatomic) int nPort;     //端口号
@property (nonatomic) int nType;     //设备类型
@property (nonatomic) int nID;      //扩展

@property (nonatomic) int ret;      //是否是被分享设备 0为未处理 1为已接受 2为拒绝


@property (nonatomic, strong) ObSysteminfo *info; //设备信息
@property (nonatomic, strong) ObSystemFunction *sysFunction; //设备能力级

@property (nonatomic, strong) NSMutableArray *channelArray; //通道数组

@property (nonatomic,assign) int eFunDevStateNotCode;              //其他设备状态 eFunDevStateNotCode 0 未知 1 唤醒 2 睡眠 3 不能被唤醒的休眠 4正在准备休眠
@property (nonatomic,assign) enum device_type deviceType;

@property (nonatomic, assign) int iCodecType;//编解码类型
@property (nonatomic, assign) int iSceneType;//场景
@property (nonatomic, assign) int imageWidth;
@property (nonatomic, assign) int imageHeight;
@property (nonatomic, assign) int centerOffsetY;  //Y轴偏移量
@property (nonatomic, assign) int centerOffsetX;  //X轴偏移量
@property (nonatomic, assign) int imgradius; //半径

///是否为低功耗设备
-(BOOL)getDeviceTypeLowPowerConsumption;

@end
