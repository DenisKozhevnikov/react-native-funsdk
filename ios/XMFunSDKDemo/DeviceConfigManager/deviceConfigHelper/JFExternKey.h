//
//  JFExternKey.h
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/26.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import <Foundation/Foundation.h>

// 查询信息命令
/** systemInfo配置信息 */
extern NSString *const JF_SystemInfo;
/** 请求特征值 */
extern NSString *const JF_CloudCryNum;
/** 特征值value */
extern NSString *const JF_CloudCryNum_Value;
/** 获取随机用户信息 */
extern NSString *const JF_Query_RamdomUserInfo;
/** 改变随机用户名信息 */
extern NSString *const JF_Change_RamdomUserInfo;

/** JF_RandomName */
extern NSString * const JF_RandomName;
/** JF_RandomPwd */
extern NSString * const JF_RandomPwd;
/** JF_RandomName_Modify */
extern NSString * const JF_RandomName_Modify;
/** JF_RandomPwd_Modify */
extern NSString * const JF_RandomPwd_Modify;

/** devName */
extern NSString * const JF_DevName;
/** devPwd */
extern NSString * const JF_DevPwd;
/** 取值随机用户信息 */
extern NSString * const JF_RandomInfo;
extern NSString * const JF_RandomInfoUser;

/** 设备token值 */
extern NSString * const JF_DevToken;
/** AdminToken */
extern NSString * const JF_AdminToken;

/** 是否支持token值 */
extern NSString *const JF_SupportToken;
/** 是否为随机用户名 */
extern NSString * const JF_RandomEnable;
/** 是否支持修改设备随机账号信息 AutoChangeRandomAcc */
extern NSString * const JF_AutoChangeRandomInfoEnable;

@interface JFExternKey : NSObject

@end

