//
//  JFDevConfigHelper.h
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/26.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "FunMsgListener.h"

@interface JFDevConfigHelper : FunMsgListener
/** 设备id */
@property (nonatomic, copy, readonly) NSString * devId;
/** 随机用户名、密码 缓存 */
@property (nonatomic, strong, readonly) NSMutableDictionary *randomInfoCache;
/** 设备token缓存数据源 */
@property (nonatomic, strong, readonly) NSMutableDictionary *devTokenCache;
/** 特征值缓存数据源 */
@property (nonatomic, strong, readonly) NSMutableDictionary *cloudCryNumCache;
/** 清除配网缓存 */
- (void)jf_clearDevConfigCacheWithDevId:(NSString *)devId;
/**
 * 非登录方式获取随机用户名
 * @param devId device id
 * @param completion callback
 */
- (void)jf_queryDevInfoWithoutLoginWithDevId:(NSString *)devId completion:(void(^)(id responseObj, NSInteger errCode))completion;
/**
 * 获取systemInfo
 * @param devId device id
 * @param completion callback
 */
- (void)jf_queryDevInfoWithConfigJsonWithDevId:(NSString *)devId completion:(void(^)(id responseObj, NSInteger errCode))completion;
/**
 * 获取特征值
 * @param devId device id
 * @param completion callback
 */
- (void)jf_queryDevInfoWithCmdGeneralWithDevId:(NSString *)devId completion:(void(^)(id responseObj, NSInteger errCode))completion;
/**
 * 修改随机用户名
 * @param devId device id
 * @param devName devName
 * @param devPwd devPwd
 * @param completion callback
 */
- (void)jf_modifyDevInfoConfigJsonWithDevId:(NSString *)devId devName:(NSString *)devName devPwd:(NSString *)devPwd completion:(void(^)(id responseObj, NSInteger errCode))completion;
/**
 * 使用非登录方式设置一次随机用户名、密码
 * @param devId device id
 * @param devName devName
 * @param devPwd devPwd
 * @param completion callback
 */
- (void)jf_modifyDevInfoWithoutLoginWithDevId:(NSString *)devId devName:(NSString *)devName devPwd:(NSString *)devPwd completion:(void(^)(id responseObj, NSInteger errCode))completion;
@end

