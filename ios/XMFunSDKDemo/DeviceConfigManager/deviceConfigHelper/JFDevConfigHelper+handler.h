//
//  JFDevConfigHelper+handler.h
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/26.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFDevConfigHelper.h"

@interface JFDevConfigHelper (handler)
#pragma mark - local API
/** 取出缓存中的token */
- (NSString *)jf_queryDevTokenWithDevId:(NSString *)devId;
/** 取出缓存中的特征值 */
- (NSString *)jf_queryCloudCryNumWithDevId:(NSString *)devId;
#pragma mark - server API
/** 获取随机用户名、密码 */
- (void)queryRandomInfoHandleWithMsgContent:(MsgContent *)msgContent callback:(void(^)(id responseObj, NSInteger errCode))callback;
/** 修改随机用户名、密码 */
- (void)modifyRandomInfoHandleWithMsgContent:(MsgContent *)msgContent callback:(void(^)(id responseObj, NSInteger errCode))callback;
/** 获取systeminfo */
- (void)querySystemInfoHandleWithMsgContent:(MsgContent *)msgContent callback:(void(^)(id responseObj, NSInteger errCode))callback;
/** 获取特征值 */
- (void)queryCloudCryNumHandleWithMsgContent:(MsgContent *)msgContent callback:(void(^)(id responseObj, NSInteger errCode))callback;

@end


