//
//  SensorInfo.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/3/29.
//  Copyright © 2019 Megatron. All rights reserved.
//

#ifndef SensorInfo_h
#define SensorInfo_h

typedef enum
{
    //    DEV_TYPE_BUTTON = (105 * (1 << 16)),          //按钮
    //    DEV_TYPE_DOOR_CONTACT = (110 * (1 << 16)),   //门磁
    //    DEV_TYPE_BODY_INFRA = (111 * (1 << 16)),      //人体红外
    //    DEV_TYPE_WATER_LEACH = (112 * (1<< 16)),     //水浸
    //    DEV_TYPE_ENVIRO_SENSOR = (113 * (1 << 16)),   //环境传感器
    //    DEV_TYPE_GAS_SENSOR = (114 * (1 << 16)),     //燃气
    //    DEV_TYPE_SMOKE_SENSOR = (115 * (1 << 16)),   //烟雾
    //    DEV_TYPE_DOOR_LOCK = (116 * (1 << 16)),      //门锁
    //    DEV_TYPE_NR,
    /**
     * 433设备的移动侦测
     */
    DEV_TYPE_433_DETECT = 0,
    /**
     * 智联插座
     */
    DEV_TYPE_SOCKET = 0x64,
    /**
     * 红外遥控
     
     */
    DEV_TYPE_REMOTE = 0x65,
    /**
     * 墙壁开关
     */
    DEV_TYPE_WALLSWITCH = 0x66,
    /**
     * //窗帘控制器
     */
    DEV_TYPE_CURTAINS = 0x67,
    /**
     * //灯带控制器
     */
    DEV_TYPE_LIGHT = 0x68,
    /**
     * 智联按钮
     */
    DEV_TYPE_BUTTON = 0x69,
    /**
     * 门磁传感器
     */
    DEV_TYPE_DOOR_CONTACT = 0x6e,
    /**
     * 人体红外传感器
     */
    DEV_TYPE_BODY_INFRA = 0x6f,
    /**
     * 水浸传感器
     */
    DEV_TYPE_WATER_LEACH = 0x70,
    /**
     * 环境传感器
     */
    DEV_TYPE_ENVIRO_SENSOR = 0x71,
    /**
     * 烟雾传感器
     */
    DEV_TYPE_SMOKE_SENSOR = 0x73,
    /**
     * 燃气传感器
     */
    DEV_TYPE_GAS_SENSOR = 0x72,
    // 门锁
    DEV_TYPE_DOOR_LOCK = 116,
} DEVICE_TYPE2;

#endif /* SensorInfo_h */
