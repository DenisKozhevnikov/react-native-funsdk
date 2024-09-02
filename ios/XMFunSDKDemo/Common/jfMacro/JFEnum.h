//
//  JFEnum.h
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/28.
//  Copyright © 2023 coderXY. All rights reserved.
//

#ifndef JFEnum_h
#define JFEnum_h

// 配网方式
typedef NS_ENUM(NSInteger, JFConfigType) {
    JFConfigType_Wifi = 0,
    JFConfigType_Ap,
    JFConfigType_bluetooth,
    JFConfigType_lan,
    JFConfigType_QR // 设备扫描手机端生成的二维码
};
// 蓝牙开关状态
typedef NS_ENUM(NSInteger, JFManagerState) {
    /** 未知  */
    JFManagerStateUnknown = 0,
    /** 复位 */
    JFManagerStateResetting,
    /** 该设备不支持蓝牙低功耗 */
    JFManagerStateUnsupported,
    /** 该程序无权使用蓝牙低功耗 */
    JFManagerStateUnauthorized,
    /** 蓝牙关闭 */
    JFManagerStatePoweredOff,
    /** 蓝牙打开 */
    JFManagerStatePoweredOn,
};
// 蓝牙权限状态
typedef NS_ENUM(NSInteger, JFManagerAuthorization) {
    /** 用户还没做出选择 */
    JFManagerAuthorizationNotDetermined = 0,
    /** 此应用程序无权使用蓝牙。 用户无法更改此应用程序的状态，这可能是由于活动限制（例如家长控制到位）所致。 */
    JFManagerAuthorizationRestricted,
    /** 用户已明确拒绝此应用程序使用蓝牙。 对应用授权不允许（在此种状态下拿到的 state 是 unauthorized 并不能知道当前蓝牙是打开还是关闭的） */
    JFManagerAuthorizationDenied,
    /** 用户已授权此应用程序始终使用蓝牙 （可以愉快的开始开发了） */
    JFManagerAuthorizationAllowedAlways
};

#endif /* JFEnum_h */
