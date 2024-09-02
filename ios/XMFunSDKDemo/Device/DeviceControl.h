//
//  DeviceControl.h
//  FunSDKDemo
//
//  Created by XM on 2018/5/10.
//  Copyright © 2018年 XM. All rights reserved.
//
/***
 
设备和通道信息的内存控制器，存储从服务器请求到的设备和通道信息。这个类中的方法都是从已经请求到的内存数据中读取设备信息。获取设备通道信息、在线状态的方法在DeviceManager中
 
 *****/
#import <Foundation/Foundation.h>
#import "DeviceObject.h"
@interface DeviceControl : NSObject
+ (instancetype)getInstance;

@property(nonatomic) int allChannelNum;  //通道总数

#pragma mark  清空所有缓存的设备
- (void)clearDeviceArray;
#pragma mark  添加设备
- (void)addDevice:(DeviceObject *)devObject;
#pragma mark  获取所有设备
- (NSMutableArray *)currentDeviceArray;
#pragma mark 服务器获取到的设备和本地缓存的设备进行比较
- (void)checkDeviceValid;
#pragma mark 保存设备到本地存储
- (void)saveDeviceList;
#pragma mark  通过序列号获取deviceObject对象,这个只是读取设备对象，设备的在线状态和通道信息等需要使用DeviceManager中的接口先行获取
- (DeviceObject *)GetDeviceObjectBySN:(NSString *)devSN;
#pragma mark 初始化channelObject对象
- (ChannelObject *)addName:(NSString*)channelName ToDeviceObject:(DeviceObject*)devObject;

#pragma mark - 将要播放的设备和通道信息处理
- (void)setSelectChannel:(ChannelObject *)channel;
- (NSMutableArray *)getSelectChannelArray;
- (void)cleanSelectChannel;

#pragma mark - 设置当前正要处理的通道，比如抓图录像中的通道，设备配置中的通道等(单画面预览时默认为0)
- (void)setSelectChannelIndex:(NSInteger)selectChannel;
- (NSInteger)getSelectChannelIndex;
- (ChannelObject*)getSelectChannel;
@end
