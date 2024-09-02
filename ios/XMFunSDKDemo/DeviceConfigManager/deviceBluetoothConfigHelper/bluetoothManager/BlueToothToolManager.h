//
//  BlueToothToolManager.h
//  JLink
//
//  Created by 吴江波 on 2022/2/28.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BlueToothManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlueToothToolManager : NSObject
@property(nonatomic,assign) BOOL isShowBluetoothTip;
@property(nonatomic, strong) NSMutableDictionary *devDic;

@property (nonatomic,strong) BlueToothManager *blueToothManager;

//蓝牙状态变化回调（是否需要提示）
@property(nonatomic, copy) void(^blueToothStateBlock)(BOOL isShowBluetoothTip);
//搜索发现设备回调
@property(nonatomic, copy) void(^blueToothFoundDevice)(NSString *pid,NSString *name,NSString *mac);
//连接设备成功回调
@property(nonatomic, copy) void(^blueToothConnectSuccessBlock)(void);
//连接设备失败回调
@property(nonatomic, copy) void(^blueToothConnectFailedBlock)(NSError *error);
//蓝牙设备返回数据（不管成功失败）
@property(nonatomic, copy) void(^blueToothResponse)(void);
//蓝牙设备返回数据回调
@property(nonatomic, copy) void(^blueToothResponseSuccessBlock)(NSString *userName,NSString *password,NSString *sn,NSString *ip,NSString *mac,NSString *token,BOOL result);
//蓝牙设备配网失败
@property(nonatomic, copy) void(^blueToothResponseFailedBlock)(NSString *result);
//初始化蓝牙，蓝牙打开则开始搜索设备
-(void)initBlueTooth;
//开始搜索设备
-(void)startSearch;
-(void)startSearchWithTimeOut:(int)timeout;
//停止搜索设备
-(void)stopSearch;
//开始连接设备 mac(mac+pid)
-(void)connectPeripheral:(NSString *)mac;
//断开连接
-(void)cancelConnection;
//开始配网
-(void)startAddBlueToothDevice:(NSString *)ssid password:(NSString *)password mac:(NSString *)Mac;
+(instancetype)sharedBlueToothToolManager;
-(BOOL)getBlueToothOpenState;
/**
 * @brief 获取手机蓝牙开关状态
 * 首次初始化后获取状态需要等到回调managerDidUpdateState后再去取值才是准确的
 */
@end

NS_ASSUME_NONNULL_END
