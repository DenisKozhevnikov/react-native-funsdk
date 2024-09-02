//
//  JFDevConfigService.h
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/26.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFDevConfigService : NSObject
/** 设备配网 */
+ (void)jf_devConfigWithDevId:(NSString *)devId completion:(void(^)(id responceObj, NSInteger errCode))completion;
/** 修改设备名、密码 */
+ (void)jf_changeDevId:(NSString *)devId devName:(NSString *)devName devPwd:(NSString *)devPwd completion:(void(^)(id responceObj, NSInteger errCode))completion;
/** 获取设备的绑定标识能力集 */
+ (void)jf_queryDevSupportAppBindValueWithDevId:(NSString *)devId completion:(void(^)(BOOL bindEnable, BOOL bindFinished, NSInteger errCode))completion;
/** 清除配网缓存 */
+ (void)jf_clearDevConfigCacheWithDevId:(NSString *)devId;
@end

