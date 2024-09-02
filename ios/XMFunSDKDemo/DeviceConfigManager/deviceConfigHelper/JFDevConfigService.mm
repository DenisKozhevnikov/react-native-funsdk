//
//  JFDevConfigService.m
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/26.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFDevConfigService.h"
#import "JFDevConfigHelper.h"
#import "DeviceBindedManager.h"

@interface JFDevConfigService ()
/** 请求设备能力集或者systeminfo */
@property (nonatomic, strong) JFDevConfigHelper *jfHelper;
/** 设备绑定标识管理 */
@property (nonatomic, strong) DeviceBindedManager *bindManager;
/** 特征值 */
@property (nonatomic, copy) NSString * cloudCryNumStr;
/** 配置结果 */
@property (nonatomic, strong) JFDevConfigServiceModel *configModel;

@end

@implementation JFDevConfigService

#pragma mark -- public method
// MARK: 配网
+ (void)jf_devConfigWithDevId:(NSString *)devId completion:(void(^)(id responceObj, NSInteger errCode))completion{
    [[JFDevConfigService shareInstance] jf_devConfigWithDevId:devId completion:completion];
}
- (void)jf_devConfigWithDevId:(NSString *)devId completion:(void(^)(id responceObj, NSInteger errCode))completion{
    // 用于接收回调completion且结束后置为nil，多次回调导致的线程组崩溃
    __block void(^callback)(id responceObj, NSInteger errCode) = completion;
    
    self.configModel = [[JFDevConfigServiceModel alloc] init];
    __block NSInteger errorCode = 0;
    // 自定义队列
    dispatch_queue_t globalQuene = dispatch_queue_create("devConfigQuene", 0);
    // 创建线程组
    dispatch_group_t group = dispatch_group_create();
    // 1、获取随机用户名、密码
    dispatch_group_enter(group);
//    dispatch_async(globalQuene, ^{});
    // 获取随机用户名
    @XMWeakify(self)
    [self.jfHelper jf_queryDevInfoWithoutLoginWithDevId:devId completion:^(id responseObj, NSInteger errCode) {
        XMLog(@"[JF]设备配网，未登录方式获取设备随机名、密码回调，随机信息:%@, %ld", responseObj, errCode);
        errorCode = errCode;
        dispatch_group_leave(group);
    }];
    // 2、systeminfo方式登录 获取token
    dispatch_group_enter(group);
//    dispatch_async(globalQuene, ^{});
    __block BOOL supportTokenEnable = NO;
    __block BOOL autoEditRandomInfoEnable = NO;
    [self.jfHelper jf_queryDevInfoWithConfigJsonWithDevId:devId completion:^(id responseObj, NSInteger errCode) {
        @XMStrongify(self)
        // 1、判断是否为token设备，
        // 1》支持修改随机用户名、密码，使用非登录方式设置一次，并更新本地设备名、密码,
        // 且无需进入手动设置设备名和密码界面，直接添加；
        // 2》不支持自动修改，则进入手动设置设备名、密码；
        // 2、非token设备，进入手动设置设备名、密码；
        if ([responseObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *repDic = (NSDictionary *)responseObj;
            NSNumber *supportTokenNum = repDic[JF_SupportToken];
            supportTokenEnable = [supportTokenNum boolValue];
            // 是否支持自动修改设备随机用户名、密码
            NSNumber *autoEdit = repDic[JF_AutoChangeRandomInfoEnable];
            autoEditRandomInfoEnable = [autoEdit boolValue];
            
            self.configModel.randomDevName = repDic[JF_DevName];
            self.configModel.randomDevPwd = repDic[JF_DevPwd];
            self.configModel.devToken = self.jfHelper.devTokenCache[devId];
            self.configModel.devTokenEnable = supportTokenEnable;
            self.configModel.autoModifyRandomInfoEnable = autoEditRandomInfoEnable;
        }
        errorCode = errCode;
        XMLog(@"[JF]设备配网，登录设备获取设备token回调，数据:%@, %ld", responseObj, errCode);
        dispatch_group_leave(group);
    }];
    // token设备且支持自动修改随机信息
    if (supportTokenEnable && autoEditRandomInfoEnable) {
        dispatch_group_enter(group);
        NSString *randomName = [NSString randomStrWithLength:8];
        NSString *randomPwd = [NSString randomStrWithLength:16];
        [self.jfHelper jf_modifyDevInfoWithoutLoginWithDevId:devId devName:randomName devPwd:randomPwd completion:^(id responseObj, NSInteger errCode) {
            @XMStrongify(self)
            if (errCode >= 0) {
                self.configModel.randomDevName = randomName;
                self.configModel.randomDevPwd = randomPwd;
                self.configModel.devToken = responseObj;
            }
            errorCode = errCode;
            XMLog(@"[JF]设备配网，token设备且支持自动修改设备随机信息回调结果:%@, %ld", responseObj, errCode);
            dispatch_group_leave(group);
        }];
    }
//    // 3、获取特征值
    dispatch_group_enter(group);
//    dispatch_async(globalQuene, ^{});
    [self.jfHelper jf_queryDevInfoWithCmdGeneralWithDevId:devId completion:^(id responseObj, NSInteger errCode) {
        @XMStrongify(self)
        self.cloudCryNumStr = responseObj;
        self.configModel.cloudCryNum = responseObj;
        errorCode = errCode;
        XMLog(@"[JF]设备配网，获取设备特征值标识回调,cloudCryNum:%@", responseObj);
        dispatch_group_leave(group);
    }];
    // 回调
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        @XMStrongify(self)
        if (callback) {
            callback(self.configModel, errorCode);
            callback = nil;
        }
        XMLog(@"");
    });
}
// MARK: 修改设备名、密码
+ (void)jf_changeDevId:(NSString *)devId devName:(NSString *)devName devPwd:(NSString *)devPwd completion:(void(^)(id responceObj, NSInteger errCode))completion{
    [[JFDevConfigService shareInstance] jf_changeDevId:devId devName:devName devPwd:devPwd completion:completion];
}
- (void)jf_changeDevId:(NSString *)devId devName:(NSString *)devName devPwd:(NSString *)devPwd completion:(void(^)(id responceObj, NSInteger errCode))completion{
    @XMWeakify(self)
    [self.jfHelper jf_modifyDevInfoConfigJsonWithDevId:devId devName:devName devPwd:devPwd completion:^(id responseObj, NSInteger errCode) {
        @XMStrongify(self)
        if (errCode >= 0) {
            self.configModel.randomDevName = devName;
            self.configModel.randomDevPwd = devPwd;
            self.configModel.devToken = responseObj;
        }
        if (completion) {
            completion(self.configModel, errCode);
        }
        XMLog(@"[JF]设备配网，手动修改设备名、密码回调结果:%@, %ld", responseObj, errCode);
    }];
}
// MARK: 获取设备的绑定标识能力集
+ (void)jf_queryDevSupportAppBindValueWithDevId:(NSString *)devId completion:(void(^)(BOOL bindEnable, BOOL bindFinished, NSInteger errCode))completion{
    [[JFDevConfigService shareInstance] jf_queryDevSupportAppBindValueWithDevId:devId completion:completion];
}
- (void)jf_queryDevSupportAppBindValueWithDevId:(NSString *)devId completion:(void(^)(BOOL bindEnable, BOOL bindFinished, NSInteger errCode))completion{
    [self.bindManager jf_queryDevSupportAppBindValueWithDevId:devId completion:completion];
}
// MARK: 清除配网缓存
+ (void)jf_clearDevConfigCacheWithDevId:(NSString *)devId{
    [[JFDevConfigService shareInstance] jf_clearDevConfigCacheWithDevId:devId];
}
- (void)jf_clearDevConfigCacheWithDevId:(NSString *)devId{
    [self.jfHelper jf_clearDevConfigCacheWithDevId:devId];
}
#pragma mark - private method
// MARK: make singleton class method
+ (instancetype)shareInstance{
    static JFDevConfigService *jfHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jfHelper = [[JFDevConfigService alloc] init];
    });
    return jfHelper;
}
#pragma mark - lazy load
// MARK: JFDevConfigHelper
- (JFDevConfigHelper *)jfHelper{
    if(!_jfHelper){
        _jfHelper = [[JFDevConfigHelper alloc] init];
    }
    return _jfHelper;
}
// MARK: DeviceBindedManager
- (DeviceBindedManager *)bindManager{
    if (!_bindManager) {
        _bindManager = [[DeviceBindedManager alloc] init];
    }
    return _bindManager;
}
@end
