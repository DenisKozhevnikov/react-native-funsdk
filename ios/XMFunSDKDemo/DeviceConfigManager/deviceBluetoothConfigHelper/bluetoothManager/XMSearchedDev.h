//
//  XMSearchedDev.h
//  XWorld
//
//  Created by dinglin on 2017/3/14.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMSearchedDev : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, strong) NSNumber *port;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, copy) NSString *mac;
@property (nonatomic, assign) int iDevType;
/** 是否是蓝牙设备(iot) */
@property (nonatomic, assign) BOOL isBlueTooth;
@property (nonatomic, copy) NSString *pid;
@property (nonatomic, copy) NSString *token;
/** 设备是否已经添加 */
@property (nonatomic, copy) NSString *addTips;
/** 设备已被其他用户组添加提示语 */
@property (nonatomic, copy) NSMutableAttributedString *addMutableTips;
/** 设备用户名 */
@property (nonatomic, copy) NSString *devUserName;
/** 设备密码 */
@property (nonatomic, copy) NSString *devPassword;

@end
