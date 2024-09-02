//
//  DeviceAddViewController.h
//  FunSDKDemo
//
//  Created by XM on 2018/11/29.
//  Copyright © 2018年 XM. All rights reserved.
//
/**
 *特殊说明：
 *WIFI快速配置添加设备时，如果需要把这个设备从其他账号下删除，则执行以下方法（int  FUN_SysAdd_Device(UI_HANDLE hUser, SDBDeviceInfo *pDevInfo, const char *szExInfo = "", const char *szExInfo2 = "", int nSeq = 0);
    szExInfo格式 param1=value1&param2=value2）
    其中“ma=true&delOth=true”设置此帐户为此设备的主帐户，且其他的设备列表下删除此设备
*/
#import <UIKit/UIKit.h>

@interface DeviceAddViewController : UIViewController

@end
