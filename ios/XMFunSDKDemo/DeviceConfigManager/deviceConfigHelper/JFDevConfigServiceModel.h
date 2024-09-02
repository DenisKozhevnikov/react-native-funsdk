//
//  JFDevConfigServiceModel.h
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/28.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFDevConfigServiceModel : NSObject
/** 随机设备名 */
@property (nonatomic, copy) NSString * randomDevName;
/** 随机密码 */
@property (nonatomic, copy) NSString * randomDevPwd;
/** token值 */
@property (nonatomic, copy) NSString * devToken;
/** 特征值 */
@property (nonatomic, copy) NSString * cloudCryNum;
/** 是否支持token */
@property (nonatomic, assign) BOOL devTokenEnable;
/** 是否支持自动修改设备随机登录名、密码 */
@property (nonatomic, assign) BOOL autoModifyRandomInfoEnable;

@end

