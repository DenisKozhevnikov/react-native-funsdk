//
//  ChangeWifiConfig.h
//  FunSDKDemo
//
//  Created by zhang on 2019/6/12.
//  Copyright © 2019 zhang. All rights reserved.
//

/************
 
 设备网络设置
 1、获取设备网络信息 （Wi-Fi的ssid，Wi-Fi密码，加密方式等）
 2、获取当前设备网络模式 （AP模式和非AP模式，AP模式下，设备会开启一个热点，手机连接设备的热点，之后就可以正常操作设备手机热点默认密码：1234567890）
 3、获取设备附近的Wi-Fi列表
 4、把设备设置成AP模式 （非AP->AP）
 5、设置设备Wi-Fi，根据设备附近的Wi-Fi列表，选择其中一个Wi-Fi堆设备进行配网
 
 **********/

@protocol ChangeWifiConfigDelegate <NSObject>

@optional
//获取设备Wi-Fi信息回调
- (void)getNetWorkWifiConfigResult:(NSInteger)result;
//获取设备Wi-Fi列表回调
- (void)getWifiArrayConfigResult:(NSInteger)result;

//把设备设置成AP模式回调
- (void)setAPModelConfigResult:(NSInteger)result;

@end

#import <Foundation/Foundation.h>
#import "ConfigControllerBase.h"
#import "WifiConfigDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChangeWifiConfig : ConfigControllerBase

@property (nonatomic, assign) id <ChangeWifiConfigDelegate> delegate;


#pragma mark 获取设备Wi-Fi信息
- (void)getNetWorkWifiConfig;
#pragma mark 获取设备Wi-Fi列表
- (void)getWifiListArrayConfig;

#pragma mark 把设备设置成AP模式
- (void)changeToAPModel;

#pragma mark 读取请求到的Wi-Fi信息
- (NSString*)getWifiSSID;
- (NSString*)getWifiPassword;

#pragma mark 读取请求到的设备附近Wi-Fi列表信息
- (NSMutableArray *)getWifiArray;
@end

NS_ASSUME_NONNULL_END
