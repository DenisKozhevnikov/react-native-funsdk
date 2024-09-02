//
//  JFDevConfigHelper.m
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/26.
//  Copyright © 2023 coderXY. All rights reserved.
//

/**
 * token设备配网流程
 * 1、FUN_DevStartAPConfig发送配网的路由器信息，SDK通过回调函数EMSG_DEV_AP_CONFIG返回配网成功的设备信息；
 * 2、非登录方式获取设备随机用户名、密码，请求命令值GetRandomUser，
 * 将获取到的随机用户名、密码保存到本地且获取是否支持随机用户名、密码配置数据，
 * 若获取数据成功，第3步，
 * 若失败，第4步；
 * 3、获取设备token，判断是否为token设备，返回数据
 * 若为token设备，且支持支持随机用户名、密码配置，使用非登录方式设置一次随机用户名和密码，并根据是否设置成功更新本地设备用户名、密码，
 * 若有token，不支持随机用户名、密码配置，第4步；
 * 若非token设备，不支持随机用户名、密码配置，第4步；
 *【若非token设备，支持支持随机用户名、密码配置；（不存在此场景）】
 * 4、进入手动设置用户名、密码界面，设置完成后第5步；否则第5步；
 * 5、获取设备特征值；
 * 6、根据能力集判断是否支持绑定，
 * 若支持绑定且未绑定则设置绑定且清空订阅，设置主账号；
 * 若支持绑定且已绑定则获取绑定配置且无特征值则普通添加，
 * 若非且有特征值则特殊添加且清除历史账号记录，
 * 若非且无特征值则普通添加。
 *
 */

#import "JFDevConfigHelper.h"
//#import <FunSDK/FunSDK.h>
#import "JFDevConfigHelper+handler.h"

// 未登录方式结果回调
typedef void(^JFWithoutLoginCompletion)(id responseObj, NSInteger errCode);
// 获取ConfigJson
typedef void(^JFQuerySytemInfoCompletion)(id responseObj, NSInteger errCode);
// cmdGeneral
typedef void(^JFQueryCloudCryNumCompletion)(id responseObj, NSInteger errCode);
// 设置随机用户名
typedef void(^JFModifyConfigJsonCompletion)(id responseObj, NSInteger errCode);

@interface JFDevConfigHelper ()
/** 设备id */
@property (nonatomic, copy, readwrite) NSString * devId;
/** withoutLogin 结果回调 */
@property (nonatomic, copy) JFWithoutLoginCompletion jfWithoutLoginCompletion;
/** systemInfo 结果回调 */
@property (nonatomic, copy) JFQuerySytemInfoCompletion jfConfigJsonInfoCompletion;
/** CmdGeneral 特征值 */
@property (nonatomic, copy) JFQueryCloudCryNumCompletion jfCmdGeneralCompletion;
/**  */
@property (nonatomic, copy) JFModifyConfigJsonCompletion jfModifyRandomComletion;
/** 随机用户名、密码 缓存 */
@property (nonatomic, strong, readwrite) NSMutableDictionary *randomInfoCache;
/** 设备token缓存数据源 */
@property (nonatomic, strong, readwrite) NSMutableDictionary *devTokenCache;
/** 特征值缓存数据源 */
@property (nonatomic, strong, readwrite) NSMutableDictionary *cloudCryNumCache;

@end

@implementation JFDevConfigHelper
#pragma mark - public method
// MARK: 清除配网缓存
- (void)jf_clearDevConfigCacheWithDevId:(NSString *)devId{
    if (!ISLEGALSTR(devId)) return;
    [self.randomInfoCache removeObjectForKey:devId];
    [self.cloudCryNumCache removeObjectForKey:devId];
    [self.devTokenCache removeObjectForKey:devId];
}
// MARK: query infomation for device.
- (void)jf_queryDevInfoWithoutLoginWithDevId:(NSString *)devId completion:(void(^)(id responseObj, NSInteger errCode))completion{
    if(!ISLEGALSTR(devId)){
        XMLog(@"[JF][Fun_DevConfigJson_NotLoginPtl] The paramter devId is not legal for this device.");
        return;
    }
    self.devId = devId;
    self.jfWithoutLoginCompletion = completion;
    // 设备配置获取、设置(not login)
    Fun_DevConfigJson_NotLoginPtl(self.msgHandle, CSTR(devId), CSTR(JF_Query_RamdomUserInfo), NULL, 1660, -1, 0, 10000, 0);
}
// MARK: 使用非登录方式设置一次随机用户名、密码
- (void)jf_modifyDevInfoWithoutLoginWithDevId:(NSString *)devId devName:(NSString *)devName devPwd:(NSString *)devPwd completion:(void(^)(id responseObj, NSInteger errCode))completion{
    if(!ISLEGALSTR(devId)){
        XMLog(@"[JF][FUN_DevCmdGeneral] The paramter devId is not legal for this device.");
        return;
    }
    self.devId = devId;
    self.jfModifyRandomComletion = completion;
    NSDictionary *cacheDic = self.randomInfoCache[self.devId];
    NSString *cacheName = cacheDic[JF_DevName];
    NSString *cachePwd = cacheDic[JF_DevPwd];
    NSString *originalName = ISLEGALSTR(cacheName)?cacheName:@"admin";
    NSString *originalPwd = ISLEGALSTR(cachePwd)?cachePwd:@"";
    NSDictionary *jsonDic = @{JF_RandomName:originalName, JF_RandomPwd:originalPwd, JF_RandomName_Modify:devName, JF_RandomName_Modify:devPwd};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    Fun_DevConfigJson_NotLoginPtl(self.msgHandle, CSTR(devId), CSTR(JF_Change_RamdomUserInfo), CSTR(jsonStr), 1660);
}
// MARK: query system infomation for device.
- (void)jf_queryDevInfoWithConfigJsonWithDevId:(NSString *)devId completion:(void(^)(id responseObj, NSInteger errCode))completion{
    if(!ISLEGALSTR(devId)){
        XMLog(@"[JF][FUN_DevGetConfig_Json] The paramter devId is not legal for this device.");
        return;
    }
    self.devId = devId;
    self.jfConfigJsonInfoCompletion = completion;
    FUN_DevGetConfig_Json(self.msgHandle, CSTR(devId), CSTR(JF_SystemInfo), 0);
}
// MARK: query CloudCryNum for device.
- (void)jf_queryDevInfoWithCmdGeneralWithDevId:(NSString *)devId completion:(void(^)(id responseObj, NSInteger errCode))completion{
    if(!ISLEGALSTR(devId)){
        XMLog(@"[JF][FUN_DevCmdGeneral] The paramter devId is not legal for this device.");
        return;
    }
    self.devId = devId;
    self.jfCmdGeneralCompletion = completion;
    // FUN_DevCmdGeneral(UI_HANDLE hUser, const char *szDevId, int nCmdReq, const char *szCmd, int nIsBinary, int nTimeout, char *pInParam = NULL, int nInParamLen = 0, int nCmdRes = -1, int nSeq = 0);
    FUN_DevCmdGeneral(self.msgHandle, CSTR(devId), 1020, CSTR(JF_CloudCryNum), -1, 15000);
}
// MARK: set config json 设备配置
- (void)jf_modifyDevInfoConfigJsonWithDevId:(NSString *)devId devName:(NSString *)devName devPwd:(NSString *)devPwd completion:(void(^)(id responseObj, NSInteger errCode))completion{
    if(!ISLEGALSTR(devId)){
        XMLog(@"[JF][FUN_DevCmdGeneral] The paramter devId is not legal for this device.");
        return;
    }
    self.devId = devId;
    self.jfModifyRandomComletion = completion;
    NSDictionary *cacheDic = self.randomInfoCache[self.devId];
    NSDictionary *jsonDic = @{JF_RandomName:cacheDic[JF_DevName], JF_RandomPwd:cacheDic[JF_DevPwd], JF_RandomName_Modify:devName, JF_RandomName_Modify:devPwd};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    FUN_DevSetConfigJson(self.msgHandle, CSTR(devId), CSTR(JF_Change_RamdomUserInfo), CSTR(jsonStr), -1, 1660);
}
#pragma mark - private method
// MARK: 随机用户名缓存数据源
- (NSMutableDictionary *)randomInfoCache{
    if (!_randomInfoCache) {
        _randomInfoCache = [[NSMutableDictionary alloc] init];
    }
    return _randomInfoCache;
}
// MARK: 设备token 缓存数据源
- (NSMutableDictionary *)devTokenCache{
    if (!_devTokenCache) {
        _devTokenCache = [[NSMutableDictionary alloc] init];
    }
    return _devTokenCache;
}
// MARK: 特征值
- (NSMutableDictionary *)cloudCryNumCache{
    if (!_cloudCryNumCache) {
        _cloudCryNumCache = [[NSMutableDictionary alloc] init];
    }
    return _cloudCryNumCache;
}
#pragma mark - callback
- (void)OnFunSDKResult:(NSNumber *)pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msgContent = (MsgContent *)nAddr;
    // 消息类型
    NSInteger msgId = msgContent->id;
    // 错误码
    NSInteger errCode = msgContent->param1;
    // jsonName
    NSString *cmdStr = OCSTR(msgContent->szStr);
    switch (msgId) {
        case EMSG_DEV_CMD_EN:// 特征值
        {
            if (JF_IsEqualToStr(cmdStr, JF_CloudCryNum)) {
                [self queryCloudCryNumHandleWithMsgContent:msgContent callback:self.jfCmdGeneralCompletion];
            }
        }
            break;
        case EMSG_DEV_GET_CONFIG_JSON:// 获取systeminfo
        {
            if (JF_IsEqualToStr(cmdStr, JF_SystemInfo)) {
                [self querySystemInfoHandleWithMsgContent:msgContent callback:self.jfConfigJsonInfoCompletion];
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG:{// 修改随机用户名
            if (JF_IsEqualToStr(cmdStr, JF_Change_RamdomUserInfo)) {
                [self modifyRandomInfoHandleWithMsgContent:msgContent callback:self.jfModifyRandomComletion];
            }
        }
            break;
        case EMSG_DEV_CONFIG_JSON_NOT_LOGIN:{ // 非登录方式
            if (JF_IsEqualToStr(cmdStr, JF_Query_RamdomUserInfo)) {     // 获取随机用户名
                [self queryRandomInfoHandleWithMsgContent:msgContent callback:self.jfWithoutLoginCompletion];
            }
            if (JF_IsEqualToStr(cmdStr, JF_Change_RamdomUserInfo)) {    // 修改随机用户名
                [self modifyRandomInfoHandleWithMsgContent:msgContent callback:self.jfModifyRandomComletion];
            }
        }
            break;
        default:
            break;
    }
}


@end
