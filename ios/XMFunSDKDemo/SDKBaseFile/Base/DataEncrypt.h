//
//  DataEncrypt.h
//  FunSDKDemo
//
//  Created by zhang on 2021/9/1.
//  Copyright © 2021 zhang. All rights reserved.
//

/*
 *设置加密传输，默认打开。
 *是否支持是由设备固件决定（早期的的设备固件并不支持这个功能）
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataEncrypt : NSObject

//APP启动时初始化加密方式，默认开
- (void)initP2PDataEncrypt;
//手动设置加密方式
- (void)setP2PDataEncrypt:(BOOL)type;
//获取本地保存的开关状态
- (BOOL)getSavedType;
@end

NS_ASSUME_NONNULL_END
