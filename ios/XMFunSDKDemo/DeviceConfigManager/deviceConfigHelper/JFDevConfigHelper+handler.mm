//
//  JFDevConfigHelper+handler.m
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/26.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFDevConfigHelper+handler.h"
#import "JFDevConfigHelper+utils.h"
#import <FunSDK/FunSDK2.h>

@implementation JFDevConfigHelper (handler)
// MARK: 获取随机用户名、密码（非登录方式）
- (void)queryRandomInfoHandleWithMsgContent:(MsgContent *)msgContent callback:(void(^)(id responseObj, NSInteger errCode))callback{
    NSDictionary *jsonDic = [self jf_jsonHandleWithMsgObj:msgContent->pObject];
    // 随机用户信息
    NSDictionary *randomDic = jsonDic[JF_Query_RamdomUserInfo];
    // 1、数据异常
    if (!jsonDic || !randomDic || [randomDic isKindOfClass:[NSNull class]]) {
        // 保存设备账号默认信息到本地
        [self jf_cacheRandomInfoWithSource:[self jf_defaultRandomInfoDic]];
        // 回调
        if (callback) {
            callback(self.randomInfoCache[self.devId], msgContent->param1);
            callback = nil;
        }
        return;
    }
    // 2、数据正常
    // 错误码
    // 100：修改成功   102：不支持该功能或已经不是默认用户名和密码  103：不支持该功能   117：请求消息没有上面要求的4项或值不是字符串  129：不支持外网IP使用该功能
    // 183：前面都成功，最后修改用户名和密码时失败，原因未知        203：随机用户名或密码错误    206：密码错误次数超过5次，被锁定，重启设备后再尝试    217:新用户名是保留用户，不允许使用
    //针对IPC，如果设备当前不是随机用户名密码，或者开机超过一个小时，就不会返回Info字段，而是返回InfoUser字段，字段数据格式和加密方式与Info是一样的
    /*
     1. 默认用户密码，并且联网在一个小时以内，存在Info字段
     2. 默认用户名密码，但联网超过1个小时，存在InfoUser字段，解压后的p2为102
     3. 修改了默认的用户名密码，存在InfoUser字段，解压后的p2为101
     应该是这三种情况
     */
    // 需要提示用户重启设备后再尝试添加
    NSString *randomInfoStr = randomDic[JF_RandomInfo];
    randomInfoStr = (!ISLEGALSTR(randomInfoStr))?randomDic[JF_RandomInfoUser]:randomInfoStr;
    // 是否支持修改随机用户信息
    NSNumber *modifyRandomInfoEnableNum = randomDic[JF_AutoChangeRandomInfoEnable];
    // 解密设备账号随机信息
    [self decodeDevRandomUserInfo:randomInfoStr];
    // 修改是否支持修改随机用户信息字段
    [self jf_updateRandomCacheWithKey:JF_AutoChangeRandomInfoEnable value:(modifyRandomInfoEnableNum)?modifyRandomInfoEnableNum:@(NO)];
    // 回调解密结果
    if (callback) {
        callback(self.randomInfoCache[self.devId], msgContent->param1);
        callback = nil;
    }
}
// MARK: 修改随机用户名、密码
- (void)modifyRandomInfoHandleWithMsgContent:(MsgContent *)msgContent callback:(void(^)(id responseObj, NSInteger errCode))callback{
    NSDictionary *jsonDic = [self jf_jsonHandleWithMsgObj:msgContent->pObject];
    NSString *devToken = jsonDic[JF_AdminToken];
    if (!jsonDic || !ISLEGALSTR(devToken) || [devToken isKindOfClass:[NSNull class]]) {
        if (callback) {
            callback(nil, msgContent->param1);
            callback = nil;
        }
        return;
    }
    if (callback) {
        callback(devToken, msgContent->param1);
        callback = nil;
    }
    // 更新token
    [self jf_cacheDevTokenWithToken:devToken];
}
// MARK: 获取systeminfo
- (void)querySystemInfoHandleWithMsgContent:(MsgContent *)msgContent callback:(void(^)(id responseObj, NSInteger errCode))callback{
    NSDictionary *jsonDic = [self jf_jsonHandleWithMsgObj:msgContent->pObject];
    NSDictionary *systemInfoDic = jsonDic[JF_SystemInfo];
    // 1、异常
    if ((!jsonDic || [jsonDic count] <= 0) ||
        (!systemInfoDic || [systemInfoDic count] <= 0) ||
        [systemInfoDic isKindOfClass:[NSNull class]]) {
        if (callback) {
            callback(nil, msgContent->param1);
            callback = nil;
        }
        return;
    }
    // 2、普通场景
    // 1、取出本地token
    char szToken[80] = {0};
    FUN_DevGetLocalEncToken(CSTR(self.devId), szToken);
    NSString *devToken = OCSTR(szToken);
    XMLog(@"[JF]设备配网之获取本地token:%@", devToken);
    // 登出设备
//    FUN_DevLogout(0, CSTR(self.devId));
    BOOL devTokenEnable = NO;
    if (ISLEGALSTR(devToken)) {
        devTokenEnable = YES;
        // 缓存token
        [self jf_cacheDevTokenWithToken:devToken];
        
    }
    // 更新随机用户信息 是否支持token设备
    [self jf_updateRandomCacheWithKey:JF_SupportToken value:@(devTokenEnable)];
    if (callback) {
        callback(self.randomInfoCache[self.devId], msgContent->param1);
        callback = nil;
    }
}
// MARK: 获取特征值
- (void)queryCloudCryNumHandleWithMsgContent:(MsgContent *)msgContent callback:(void(^)(id responseObj, NSInteger errCode))callback{
    NSDictionary *jsonDic = [self jf_jsonHandleWithMsgObj:msgContent->pObject];
    NSDictionary *cloudCryDic = jsonDic[JF_CloudCryNum];
    if (!jsonDic || !cloudCryDic || [cloudCryDic isKindOfClass:[NSNull class]]) {
        if (callback) {
            callback(nil, msgContent->param1);
            callback = nil;
        }
        return;
    }
    NSString *cloudCryNumStr = cloudCryDic[JF_CloudCryNum_Value];
    // 缓存特征值
    [self jf_cacheCloudCryNum:cloudCryNumStr];
    if (callback) {
        callback(cloudCryNumStr, msgContent->param1);
        callback = nil;
    }
}

// MARK: 缓存token
- (void)jf_cacheDevTokenWithToken:(NSString *)devToken{
    if (!ISLEGALSTR(devToken)) return;
    // 1、缓存devtoken
    self.devTokenCache[self.devId] = devToken;
    // 2、更新本地登录token
    Fun_DevSetLocalEncToken(CSTR(self.devId), CSTR(devToken));
}
// MARK: 取出缓存中的token
- (NSString *)jf_queryDevTokenWithDevId:(NSString *)devId{
    NSString *devToken = nil;
    // 1、从缓存中取
    devToken = self.devTokenCache[self.devId];
    // 2、若缓存中没有则从本地取
    if (!ISLEGALSTR(devToken)) {
        // 取出本地token
        char szToken[80] = {0};
        FUN_DevGetLocalEncToken(CSTR(self.devId), szToken);
        devToken = OCSTR(szToken);
    }
    return devToken;
}

// MARK: 缓存特征值
- (void)jf_cacheCloudCryNum:(NSString *)cloudCryNum{
    if (!ISLEGALSTR(cloudCryNum)) return;
    self.cloudCryNumCache[self.devId] = cloudCryNum;
}
// MARK: 取出特征值
- (NSString *)jf_queryCloudCryNumWithDevId:(NSString *)devId{
    if (!ISLEGALSTR(devId)) return nil;
    return self.cloudCryNumCache[devId];
}

#pragma mark - private method
// MARK: 默认随机用户信息
- (NSDictionary *)jf_defaultRandomInfoDic{
    NSDictionary *dic = @{
        JF_DevName:@"admin",
        JF_DevPwd:@"",
        JF_RandomEnable:@(NO),          // 是否支持随机用户、密码
        JF_AutoChangeRandomInfoEnable:@(NO) // 是否支持修改随机用户、密码
    };
    return dic;
}
// MARK: 解密设备随机用户信息
- (void)decodeDevRandomUserInfo:(NSString *)randomUserInfo{
    char randomUserInfoData[512] = {0};
    // 随机用户名密码数据的解密
    Fun_DecDevRandomUserInfo([self.devId UTF8String],[randomUserInfo UTF8String], randomUserInfoData);
    NSString *str = [NSString stringWithFormat:@"%s",randomUserInfoData];
    NSArray *arr = [str componentsSeparatedByString:@" "];
    if (!ISLEGALSTR(str) || (!arr || [arr count] <= 0)) {
        [self jf_cacheRandomInfoWithSource:[self jf_defaultRandomInfoDic]];
        NSString *processStr = [NSString stringWithFormat:@"[JF]快速配置流程,解析设备账号随机信息失败😭, %@", str];
        Fun_Log(CSTR(processStr));
        XMLog(@"%@", processStr);
        return;
    }
    NSString *randomUser = [arr firstObject];
    NSString *randomPwd = arr[1];
    if ((!ISLEGALSTR(randomUser) || randomUser.length <= 3) || (!ISLEGALSTR(randomPwd) || randomPwd.length <= 3)) {
        [self jf_cacheRandomInfoWithSource:[self jf_defaultRandomInfoDic]];
        NSString *processStr = [NSString stringWithFormat:@"[JF]快速配置流程,解析设备账号随机信息失败😭, %@, randomUser:%@, randomPwd:%@", arr, randomUser, randomPwd];
        Fun_Log(CSTR(processStr));
        XMLog(@"%@", processStr);
        return;
    };
    NSString *sRandomUser = [randomUser substringFromIndex:3];
    NSString *sRandomPwd = [randomPwd substringFromIndex:3];
    NSMutableDictionary *dic = nil;
    if (ISLEGALSTR(sRandomUser) && ISLEGALSTR(sRandomPwd)) {
        dic = @{JF_DevName:sRandomUser, JF_DevPwd:sRandomPwd, JF_RandomEnable:@(YES), JF_AutoChangeRandomInfoEnable:@(NO)};
        NSString *processStr = [NSString stringWithFormat:@"[JF]快速配置流程,解析设备账号随机信息成功😊"];
        Fun_Log(CSTR(processStr));
        XMLog(@"%@", processStr);
    }else{
        dic = [self jf_defaultRandomInfoDic];
        NSString *processStr = [NSString stringWithFormat:@"[JF]快速配置流程,解析设备账号随机信息失败😭, randomUser:%@, randomPwd:%@", randomUser, randomPwd];
        Fun_Log(CSTR(processStr));
        XMLog(@"%@", processStr);
    }
    // 缓存数据
    [self jf_cacheRandomInfoWithSource:dic];
}
// MARK: 更新随机用户信息以及相关数据
- (void)jf_updateRandomCacheWithKey:(NSString *)key value:(id)value{
    NSDictionary *randomInfoDic = self.randomInfoCache[self.devId];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:randomInfoDic];
    tempDic[key] = value;
    [self jf_cacheRandomInfoWithSource:[tempDic copy]];
}
// MARK: 临时缓存到本地数据源
- (void)jf_cacheRandomInfoWithSource:(NSDictionary *)source{
    if (!ISLEGALSTR(self.devId)) {
        XMLog(@"This devId is illegal.check it,please!");
        return;
    }
    self.randomInfoCache[self.devId] = source;
    NSString *processStr = [NSString stringWithFormat:@"[JF]快速配置流程,保存设备账号随机信息:%@", source];
    Fun_Log(CSTR(processStr));
    XMLog(@"%@", processStr);
}
@end
