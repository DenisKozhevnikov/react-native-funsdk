//
//  DeviceManager.h
//  MobileVideo
//
//  Created by XM on 2018/4/18.
//  Copyright © 2018年 XM. All rights reserved.
//
/**
 *登录账号后对设备的增删改查操作
 *通过输入序列号和IP添加设备时最好提供给用户选择设备类型的入口，因为通过序列号、IP等方式添加的设备无法知道设备类型，只有快速配置和局域网搜索添加的设备可以直接获取到设备类型
 *
 *特殊说明：
 *快速配置添加设备时，如果需要把这个设备从其他账号下删除，则执行以下方法（int  FUN_SysAdd_Device(UI_HANDLE hUser, SDBDeviceInfo *pDevInfo, const char *szExInfo = "", const char *szExInfo2 = "", int nSeq = 0);
    szExInfo格式 param1=value1&param2=value2）
    其中“ma=true&delOth=true”设置此帐户为此设备的主帐户，且其他的设备列表下删除此设备
 */
@protocol DeviceManagerDelegate <NSObject>
@optional

// 搜索局域网设备回调
- (void)searchDevice:(NSMutableArray*)searchArray result:(int)result;
// 添加设备结果回调
- (void)addDeviceResult:(int)result;
// 快速配置结果回调
- (void)quickConfiguration:(id)device result:(int)resurt;

// 获取设备在线状态结果
- (void)getDeviceState:(NSString *)sId result:(int)result;

// 设备唤醒结果
- (void)deviceWeakUp:(NSString *)sId result:(int)result;

// 获取设备通道结果
- (void)getDeviceChannel:(NSString *)sId result:(int)result;

// 删除设备结果
- (void)deleteDevice:(NSString *)sId result:(int)result;

// 修改设备信息结果
- (void)changeDevice:(NSString *)sId changedResult:(int)result;

// 判断主账号信息结果
- (void)checkMaster:(NSString *)sId Result:(int)result;

@end

#import <Foundation/Foundation.h>
#import "FunMsgListener.h"
#import "DeviceObject.h"

@interface NSMessage : NSObject

@property(nonatomic, strong) NSObject *nsObj;
@property(nonatomic, strong) NSString *strParam;
@property(nonatomic, strong) id objId;
@property(readwrite, assign) void *obj;
@property(readwrite, assign) int param1;
@property(readwrite, assign) int param2;



+ (id)SendMessag:(NSString *) name obj:(void *) obj p1:(int)param1 p2:(int)param2;

@end

@interface DeviceManager : FunMsgListener

@property (nonatomic, assign) id <DeviceManagerDelegate> delegate;

@property(readwrite, copy)NSString *loginToken;

+ (instancetype)getInstance;
- (void)resiveDevicelist2:(MsgContent *)msg;
#pragma mark 获取设备列表和添加设备成功之后放入内存
- (void)resiveDevicelist:(NSMessage *)msg;
#pragma mark 获取被分享的设备
- (void)getShareToMeList;

- (void)addDeviceToList:(NSMessage *)msg;

#pragma mark -WIFi配网
- (void)addDeviceByWiFiConfig:(NSString*)serialNumber deviceName:(NSString *)deviceName loginName:(NSString *)loginName loginPassword:(NSString *)loginPassword devType:(int)type;
#pragma mark -通过序列号、局域网搜索、ap模式连接添加设备
- (void)addDeviceByDeviseSerialnumber:(NSString*)serialNumber deviceName:(NSString *)deviceName loginName:(NSString *)loginName loginPassword:(NSString *)loginPassword devType:(int)type devPort:(NSNumber *)port deviceIp:(NSString *)devIp;//通过输入设备序列号添加,包含设备登录名和密码
- (void)addDeviceByDeviceIP:(NSString *)deviceIP deviceName:(NSString *)name password:(NSString *)psw port:(NSString *)port;//通过ip/域名进行添加
- (void)addDeviceByAP;//ap模式下只能直接连接打开，无法进行账号相关操作 //参考 loginWithTypeAP 方法
- (void)SearchDevice;//搜索局域网下的设备
- (void)addDeviceBySerialNum:(NSString *)serialNumber deviceName:(NSString *)name type:(int)devType;//搜索到之后，再选择要添加的设备添加
/** token设备 */
- (void)addTokenDevWithDevSerialNumber:(NSString*)serialNumber deviceName:(NSString *)deviceName loginName:(NSString *)loginName loginPassword:(NSString *)loginPassword devType:(int)type configModel:(JFDevConfigServiceModel *)model;
   //通过序列号、局域网搜索、ap模式连接添加设备，并且从其他账号中删除此设备
- (void)addDeviceAndDeleteFromOther:(NSString*)serialNumber deviceName:(NSString *)deviceName devType:(int)type;
#pragma mark - 开始快速配置
//因为苹果官方限制，iOS14.5以后的系统，需要申请广播权限才能配网，申请地址：https://developer.apple.com/contact/request/networking-multicast
-(void)startConfigWithSSID:(NSString*)ssid password:(NSString*)password;
#pragma mark - 开始快速配置 (从网络配置界面跳转到这里并直接开始快速配置，正常快速配置功能不会调用到个方法)
-(void)startOtherWayConfig:(NSString*)ssid password:(NSString*)password;

#pragma mark - 停止快速配置
-(void)stopConfig;

#pragma mark - 获取设备状态 序列号传空值时获取所有设备的状态
- (void)getDeviceState:(NSString *)deviceMac;

#pragma mark - 唤醒睡眠中的设备
- (void)deviceWeakUp:(NSString*)deviceMac;

#pragma mark - 获取设备通道
- (void)getDeviceChannel:(NSString *)devMac;

#pragma mark - 修改设备在云端的信息 name:设备名称，user：设备用户名，默认admin，psw：设备密码
/*
 设备用户名和密码请输入正确的用户名和密码，如果输入错误的值，则可能会影响后续的设备登录预览等功能
  如果想要修改设备密码，请参考 PasswordConfig.h
*/
- (void)changeDevice:(NSString *)devMac devName:(NSString *)name username:(NSString *)user password:(NSString *)psw;
#pragma mark - 修改APP保存的本地设备密码
- (void)changeDevicePsw:(NSString *)devMac loginName:(NSString *)name password:(NSString *)psw;
#pragma mark - 删除设备
- (void)deleteDeviceWithDevMac:(NSString *)devMac;
#pragma mark - 判断是否是主账号
- (void)checkMasterAccount:(NSString *)devMac;
#pragma mark - 解析二维码
-(NSArray *)decodeDevInfo:(NSString*)info;


#pragma mark - 修改设备本地用户名密码 设置用户名密码会将支持token登录的设备token清空 注意设置顺序
-(void)changeDeviceUserNamePasswordLocal:(NSString*)sId userName:(NSString*)username password:(NSString*)password;
@end
