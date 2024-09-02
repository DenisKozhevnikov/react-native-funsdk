//
//  JFConfigKey.m
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/26.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFExternKey.h"

/** systemInfo配置信息 */
NSString *const JF_SystemInfo = @"SystemInfo";
/** 请求特征值 */
NSString *const JF_CloudCryNum = @"GetCloudCryNum";
/** 特征值value */
NSString *const JF_CloudCryNum_Value = @"CloudCryNum";
/** 获取随机用户信息 */
NSString *const JF_Query_RamdomUserInfo = @"GetRandomUser";
/** 改变随机用户名信息 */
NSString *const JF_Change_RamdomUserInfo = @"ChangeRandomUser";

/** JF_RandomName */
NSString * const JF_RandomName = @"RandomName";
/** JF_RandomPwd */
NSString * const JF_RandomPwd = @"RandomPwd";
/** JF_RandomName_Modify */
NSString * const JF_RandomName_Modify = @"NewName";
/** JF_RandomPwd_Modify */
NSString * const JF_RandomPwd_Modify = @"NewPwd";

/** 设备token值 */
NSString * const JF_DevToken = @"devToken";
/** AdminToken */
NSString * const JF_AdminToken = @"AdminToken";

/** devName */
NSString * const JF_DevName = @"devName";
/** devPwd */
NSString * const JF_DevPwd = @"devPwd";
/** 取值随机用户信息 */
NSString * const JF_RandomInfo = @"Info";
NSString * const JF_RandomInfoUser = @"InfoUser";
/** token值 */
NSString *const JF_SupportToken = @"SupportToken";
/** 是否为随机用户名 */
NSString * const JF_RandomEnable = @"randomEnable";
/** 是否支持修改设备随机账号信息 AutoChangeRandomAcc */
NSString * const JF_AutoChangeRandomInfoEnable = @"AutoChangeRandomAcc";

#pragma mark - JFConfigKey
@implementation JFExternKey

@end
