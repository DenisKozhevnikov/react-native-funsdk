//
//  DeviceManager.m
//  MobileVideo
//
//  Created by XM on 2018/4/18.
//  Copyright © 2018年 XM. All rights reserved.
//
#import "FunSDK/FunSDK.h"
#import <FunSDK/FunSDK2.h>
#import <FunSDK/Fun_MC.h>
#import <string>
#import "GTMNSString+HTML.h"
#import "AlarmManager.h"
#import "DeviceManager.h"
#import "XMNetInterface/NetInterface.h"
#import "DeviceShareManager.h"
#import "DoorBellModel.h"
#import "DeviceRandomPwdManager.h"
#import "DevicePairingNetworkManager.h"
#import "DeviceBindedManager.h"

@implementation NSMessage
+ (id)SendMessag:(NSString *) name obj:(void *) obj p1:(int)param1 p2:(int)param2 {
    NSMessage *pNew = [NSMessage alloc];
    [pNew setObj:obj];
    [pNew setParam1:param1];
    [pNew setParam2:param2];
    return pNew;
}
@end

@interface DeviceManager ()
{
    NSString *deviceMac;
    SDBDeviceInfo wifiDevInfo;
    NSInteger deviceStateRequestCounter; // Новый счетчик запросов состояния устройств
}

@property (nonatomic,strong) DevicePairingNetworkManager *devicePairingNetworkManager;
//临时缓存特征码
@property (nonatomic,strong) NSMutableDictionary *dicCloudCryNum;

@property (nonatomic,strong) DeviceBindedManager *bindManager;


@end

@implementation DeviceManager
+ (instancetype)getInstance {
    static DeviceManager *Manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Manager = [[DeviceManager alloc]init];
    });
    return Manager;
}
- (id)init {
    self = [super init];
    if (self) {
        deviceStateRequestCounter = 0; // Инициализация счетчика
    }
    return self;
}
#pragma mark -通过序列号、局域网搜索、ap模式连接添加设备
- (void)addDeviceByDeviseSerialnumber:(NSString*)serialNumber deviceName:(NSString *)deviceName loginName:(NSString *)loginName loginPassword:(NSString *)loginPassword devType:(int)type devPort:(NSNumber *)port deviceIp:(NSString *)devIp {//通过输入设备序列号添加,包含设备登录名和密码
    //直接通过序列号添加设备
    if (deviceName == nil) {
        deviceName = serialNumber;
    }
    
    SDBDeviceInfo devInfo = {0};
    
    STRNCPY(devInfo.loginName, SZSTR(loginName.length==0?@"admin":loginName));
    
    STRNCPY(devInfo.loginPsw, SZSTR(loginPassword.length==0?@"":loginPassword));
    
    STRNCPY(devInfo.Devmac, SZSTR(serialNumber));
    
    devInfo.nType = type;
    
    STRNCPY(devInfo.Devname, SZSTR(deviceName));
    
    if (port == nil) {
        devInfo.nPort = 34567;
    } else {
        devInfo.nPort = [port intValue];
    }
    
    if (devIp != nil) {
        STRNCPY(devInfo.devIP, SZSTR(devIp));
    }
    
    
    //添加设备（不会从其他账号中删除）
    FUN_SysAdd_Device(self.msgHandle, &devInfo,"","",1);

    //添加设备（会从其他账号中删除，demo中使用不删除的接口）
    //FUN_SysAdd_Device(self.msgHandle, &devInfo, "ma=true&delOth=true","",1);
    
}


#pragma mark -WIFi配网
- (void)addDeviceByWiFiConfig:(NSString*)serialNumber deviceName:(NSString *)deviceName loginName:(NSString *)loginName loginPassword:(NSString *)loginPassword devType:(int)type{//通过输入设备序列号添加,包含设备登录名和密码
    //直接通过序列号添加设备
    if (deviceName == nil) {
        deviceName = serialNumber;
    }

    STRNCPY(wifiDevInfo.loginName, SZSTR(loginName.length==0?@"admin":loginName));
    STRNCPY(wifiDevInfo.loginPsw, SZSTR(loginPassword.length==0?@"":loginPassword));
    STRNCPY(wifiDevInfo.Devmac, SZSTR(serialNumber));
    wifiDevInfo.nType = type;
    STRNCPY(wifiDevInfo.Devname, SZSTR(deviceName));
    wifiDevInfo.nPort = 34567;
    
    NSString *loginTokenJsonStr = [NSString convertToJSONData:@{@"AdminToken":self.loginToken.length==0?@"":self.loginToken}];
    NSString *param = @"";
    
    __weak typeof(self) weakSelf = self;
    self.bindManager.devID = serialNumber;
    //如果是客户手动重启的wifi配网或者蓝牙配网 需要获取设备特征码
    [self.devicePairingNetworkManager requestCloudCryNum:serialNumber completed:^(int result, NSString *crynum) {
        if (result >= 0 && crynum.length > 0) {
            [weakSelf.dicCloudCryNum setObject:crynum forKey:serialNumber];
        }
        Fun_Log((char *)"快速配置流程: 添加设备前判断绑定标志 \n");
        [weakSelf.bindManager getBindConfig:^(AddDeviceStyle style) {
            if (style == AddDeviceStyleNormal || crynum.length > 0) {
                [weakSelf addDeviceSpecify:serialNumber];
            }
            [weakSelf.bindManager cleanContent];
        } bindResult:^(BOOL ifBinded) {
            if (ifBinded && crynum.length <= 0) {
                [weakSelf addDeviceNormal:wifiDevInfo];
            }
            else{
                [weakSelf addDeviceSpecify:serialNumber];
            }
            
            [weakSelf.bindManager cleanContent];
        }];
    }];
    
    
    //添加设备（不会从其他账号中删除）
//    FUN_SysAdd_Device(self.msgHandle, &devInfo,param.UTF8String,(self.loginToken.length > 0 && loginTokenJsonStr) ? loginTokenJsonStr.UTF8String : "");

    //添加设备（会从其他账号中删除，demo中使用不删除的接口）
    //FUN_SysAdd_Device(self.msgHandle, &devInfo, "ma=true&delOth=true","",1);
    
}
// MARK: token设备
- (void)addTokenDevWithDevSerialNumber:(NSString*)serialNumber deviceName:(NSString *)deviceName loginName:(NSString *)loginName loginPassword:(NSString *)loginPassword devType:(int)type configModel:(JFDevConfigServiceModel *)model{//通过输入设备序列号添加,包含设备登录名和密码
    //直接通过序列号添加设备
    deviceName = ISLEGALSTR(deviceName)?deviceName:serialNumber;
    self.loginToken = model.devToken;
    STRNCPY(wifiDevInfo.loginName, SZSTR(loginName.length==0?@"admin":loginName));
    STRNCPY(wifiDevInfo.loginPsw, SZSTR(loginPassword.length==0?@"":loginPassword));
    STRNCPY(wifiDevInfo.Devmac, SZSTR(serialNumber));
    wifiDevInfo.nType = type;
    STRNCPY(wifiDevInfo.Devname, SZSTR(deviceName));
    wifiDevInfo.nPort = 34567;
    
    __weak typeof(self) weakSelf = self;
    self.bindManager.devID = serialNumber;
    //如果是客户手动重启的wifi配网或者蓝牙配网 需要获取设备特征码
    if (model.cloudCryNum) {
        self.dicCloudCryNum[serialNumber] = model.cloudCryNum;
    }
    Fun_Log((char *)"快速配置流程: 添加设备前判断绑定标志 \n");
    [self.bindManager getBindConfig:^(AddDeviceStyle style) {
        if (style == AddDeviceStyleNormal || model.cloudCryNum.length > 0) {
            [weakSelf addDeviceSpecify:serialNumber];
        }
        [weakSelf.bindManager cleanContent];
    } bindResult:^(BOOL ifBinded) {
        if (ifBinded && model.cloudCryNum.length <= 0) {
            [weakSelf addDeviceNormal:wifiDevInfo];
        }else{
            [weakSelf addDeviceSpecify:serialNumber];
        }
        [weakSelf.bindManager cleanContent];
    }];
    //添加设备（不会从其他账号中删除）
//    FUN_SysAdd_Device(self.msgHandle, &devInfo,param.UTF8String,(self.loginToken.length > 0 && loginTokenJsonStr) ? loginTokenJsonStr.UTF8String : "");

    //添加设备（会从其他账号中删除，demo中使用不删除的接口）
    //FUN_SysAdd_Device(self.msgHandle, &devInfo, "ma=true&delOth=true","",1);
    
}


//通过序列号、局域网搜索、ap模式连接添加设备，并且从其他账号中删除此设备
- (void)addDeviceAndDeleteFromOther:(NSString*)serialNumber deviceName:(NSString *)deviceName devType:(int)type {
    //直接通过序列号添加设备
    if (deviceName == nil) {
        deviceName = serialNumber;
    }
    SDBDeviceInfo devInfo = {0};
    STRNCPY(devInfo.loginName, SZSTR(@"admin"));
    STRNCPY(devInfo.loginPsw, SZSTR(@""));
    STRNCPY(devInfo.Devmac, SZSTR(serialNumber));
    devInfo.nType = type;
    STRNCPY(devInfo.Devname, SZSTR(deviceName));
    devInfo.nPort = 34567;
    //添加设备（不会从其他账号中删除）
    //FUN_SysAdd_Device(self.msgHandle, &devInfo);
    //添加设备（会从其他账号中删除，demo中使用不删除的接口）
    FUN_SysAdd_Device(self.msgHandle, &devInfo, "ma=true&delOth=true","",1);
}
#pragma mark - 通过ip/域名添加
- (void)addDeviceByDeviceIP:(NSString *)deviceIP deviceName:(NSString *)name password:(NSString *)psw port:(NSString *)port{
    SDBDeviceInfo devInfo = {0};
    STRNCPY(devInfo.Devname, SZSTR(name));
    STRNCPY(devInfo.loginName, SZSTR(@"admin"));
    STRNCPY(devInfo.loginPsw, SZSTR(psw));
    NSString *myPort = (port.length == 0) ? @"34567" :port;
    devInfo.nPort = [myPort intValue];
    
    NSString *index = [NSString stringWithFormat:@"%@:%@",deviceIP, myPort];
    STRNCPY(devInfo.Devmac, SZSTR(index));
    FUN_SysAdd_Device(self.msgHandle, &devInfo);
}
#pragma mark - 局域网搜索设备
//先搜索局域网设备，搜索到之后才能进行添加
- (void)SearchDevice {
     FUN_DevSearchDevice(self.msgHandle, 4000, 0);
}
//搜索到之后，再选择要添加的设备添加
- (void)addDeviceBySerialNum:(NSString *)serialNumber deviceName:(NSString *)name type:(int)devType{
    SDBDeviceInfo devInfo = {0};
    STRNCPY(devInfo.loginName, SZSTR(@"admin"));
    STRNCPY(devInfo.loginPsw, SZSTR(@""));
    STRNCPY(devInfo.Devmac, SZSTR(serialNumber));
    STRNCPY(devInfo.Devname, SZSTR(name));
    devInfo.nType = devType;
    devInfo.nPort = 34567;
    //FUN_SysAdd_Device(self.msgHandle, &devInfo, "ma=true&delOth=true","",1);
    FUN_SysAdd_Device(self.msgHandle, &devInfo);
}

#pragma mark - ap添加设备
- (void)addDeviceByAP {
    //参考 loginWithTypeAP 方法 （UserAccountModel文件中）
}

#pragma mark - 开始快速配置
//因为苹果官方限制，iOS14.5以后的系统，需要申请广播权限才能配网，申请地址：https://developer.apple.com/contact/request/networking-multicast
-(void)startConfigWithSSID:(NSString*)ssid password:(NSString*)password{
    
    char data[128] = {0};
    char infof[256] = {0};
    int encmode = 1;
    unsigned char mac[6] = {0};
    sprintf(data, "S:%sP:%sT:%d", [ssid UTF8String], SZSTR(password), encmode);
    NSString* sGateway = [NetInterface getDefaultGateway];
    sprintf(infof, "gateway:%s ip:%s submask:%s dns1:%s dns2:%s mac:0", SZSTR(sGateway), [[NSString getCurrent_IP_Address] UTF8String],"255.255.255.0",SZSTR(sGateway),SZSTR(sGateway));
    NSString* sMac = [NetInterface getCurrent_Mac];
    if (sMac == nil || sMac.length == 0) {
        sMac = @"28:f0:70:60:3f:76";
        sMac = @"21:f1:70:63:2f:76";
    }
    sscanf(SZSTR(sMac), "%x:%x:%x:%x:%x:%x", &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]);
    
    NSLog(@"快速配置流程：发送路由器信息");
    FUN_DevStartAPConfig(self.msgHandle, 3, SZSTR(ssid), data, infof, SZSTR(sGateway), encmode, 0, mac, 180000);
}

#pragma mark - 开始快速配置 (从网络配置界面跳转到这里并直接开始快速配置，正常快速配置功能不会调用到个方法)
-(void)startOtherWayConfig:(NSString*)ssid password:(NSString*)password {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    if (channel != nil) {
        FUN_DevStartWifiConfig(self.msgHandle, SZSTR(channel.deviceMac), SZSTR(ssid), SZSTR(password), 180000);
    }else{
        //如果没有获取到设备通道信息，则从网络配置跳转的设备配置失败
    }
    
}

#pragma mark - 停止快速配置
-(void)stopConfig{
    FUN_DevStopAPConfig();
}

-(void)addDeviceSpecify:(NSString *)devID{
    Fun_Log((char *)"快速配置流程: 清除所有账号订阅 \n");
    
    deviceMac = devID;
    MC_UnlinkAllAccountsOfDev(self.msgHandle, CSTR(devID),101);
}

-(void)addDeviceNormal:(SDBDeviceInfo)devInfo{
    Fun_Log((char *)"快速配置流程: FUN_SysAdd_Device \n");
    
    NSString *loginTokenJsonStr = [NSString convertToJSONData:@{@"AdminToken":self.loginToken.length==0?@"":self.loginToken}];
    
    NSString *param = @"";
    if ([self.dicCloudCryNum objectForKey:OCSTR(devInfo.Devmac)]) {
        param = [NSString stringWithFormat:@"cryNum=%@",[self.dicCloudCryNum objectForKey:OCSTR(devInfo.Devmac)]];
        [self.dicCloudCryNum removeAllObjects];
    }
    FUN_SysAdd_Device(self.msgHandle, &devInfo,param.UTF8String,(self.loginToken.length > 0 && loginTokenJsonStr) ? loginTokenJsonStr.UTF8String : "");
}

#pragma mark - 解析二维码
-(NSArray *)decodeDevInfo:(NSString*)info{
    char szDevId[256] = {0};
    char szUserName[64] = {0};
    char szPassword[64] = {0};
    int nType = 0;
    int time = 0;
    FUN_DecDevInfo([info UTF8String], szDevId, szUserName, szPassword, nType, time);
    NSArray* array = [[NSArray alloc] initWithObjects:[NSString stringWithUTF8String:szDevId], [NSString stringWithUTF8String:szUserName],[NSString stringWithUTF8String:szPassword], [NSString stringWithFormat:@"%d", nType], nil];
    return array;
}

#pragma mark - 获取设备状态
- (void)getDeviceState:(NSString *)deviceMac {
    std::string myDev;
    if (deviceMac != nil) {
        myDev.append([deviceMac UTF8String]);
        myDev.append(";");
        deviceStateRequestCounter = 1;
    }else{
        NSMutableArray *deviceArray = [[DeviceControl getInstance] currentDeviceArray];
        deviceStateRequestCounter = deviceArray.count;
        
        for (int i = 0; i < deviceArray.count; i ++) {
            DeviceObject *devObject = [deviceArray objectAtIndex:i];
            if(devObject!= nil){
                myDev.append([devObject.deviceMac UTF8String]);
                myDev.append(";");
            }
        }
    }
    if (myDev.length() > 0){

        FUN_SysGetDevState(self.msgHandle, myDev.c_str());
    }else{
        //没有设备  直接回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(getDeviceState:result:)]) {
            [self.delegate getDeviceState:nil result:YES];
        }
    }
}

#pragma mark - 唤醒睡眠中的设备
- (void)deviceWeakUp:(NSString*)string {
    DeviceObject *object = [[DeviceControl getInstance] GetDeviceObjectBySN:string];
    //门铃门锁等设备才需要每次唤醒,为防止后续增加新设备类型需要唤醒而demo未适配，这里不判断类型，都进行唤醒
    if (object.nType == XM_DEV_CAT || object.nType == XM_DEV_DOORBELL || object.nType == CZ_DOORBELL || object.nType == XM_DEV_DOORBELL_A) {
        
    }
        deviceMac = string;
        FUN_DevWakeUp(self.msgHandle, SZSTR(deviceMac), 0);
}


#pragma mark - 获取设备通道
- (void)getDeviceChannel:(NSString *)devMac {
    
    DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:devMac];
    if (devObject == nil) {
        return;
    }
    int nChnCount = FUN_GetDevChannelCount(SZSTR(devMac));
    if (nChnCount > 0) {
        NSLog(@"DSS设备可以直接读取设备的通道数量，不需要再获取。nChnCount= %d",nChnCount);
        //DSS设备如果不需要获取通道的具体信息，则可以在这里直接回调(具体信息包括通道名称等等)
        NSMutableArray *channelArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < nChnCount; i ++) {
            NSString *str = @"Channel Name";
            ChannelObject *channel = [[DeviceControl getInstance] addName:str ToDeviceObject:devObject];
            channel.channelNumber = i;
            [channelArray addObject: channel];
        }
        devObject.channelArray = [channelArray mutableCopy];
        if (self.delegate &&  [self.delegate respondsToSelector:@selector(getDeviceChannel:result:)]) {
            [self.delegate getDeviceChannel:devObject.deviceMac result:1];
        }
        return;
    }
    //1、先判断本地是否有保存，底层库是否已经获取到（DSS设备能直接获取到）
    NSMutableArray *nameArr = [self getChannleFromUserDB:devMac];
    if (devObject.channelArray.count>0 || nameArr.count >0){
        if (devObject.channelArray.count == 0) {
            //本地保存的有通道，则传递给deviceObject对象
            NSMutableArray *channelArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i =0; i< nameArr.count; i++) {
                NSString *str = [nameArr objectAtIndex:i];
                ChannelObject *channel = [[DeviceControl getInstance] addName:str ToDeviceObject:devObject];
                channel.channelNumber = i;
                [channelArray addObject:channel];
            }
            devObject.channelArray = [channelArray mutableCopy];
        }
        //本地已经有保存，后台更新通道名称
        FUN_DevGetChnName(self.msgHandle, [devObject.deviceMac UTF8String], "", "", -1);
        return;
    }
    //2、从服务器获取通道信息，获取成功后刷新
    FUN_DevGetChnName(self.msgHandle, [devMac UTF8String], "", "", 0);
}

#pragma mark - 修改设备名称
- (void)changeDevice:(NSString *)devMac devName:(NSString *)name username:(NSString *)user password:(NSString *)psw {
    NSMutableArray *deviceArray = [[DeviceControl getInstance] currentDeviceArray];
    DeviceObject *devObj = [[DeviceControl getInstance] GetDeviceObjectBySN:devMac];
    devObj.loginName = user;
    devObj.loginPsw = psw;
    SDBDeviceInfo devInfo = {0};
    strncpy(devInfo.Devmac, SZSTR(devMac), 64);
    strncpy(devInfo.Devname, SZSTR(name), 128);
    devInfo.nPort = devObj.nPort;
    devInfo.nType = devObj.nType;
    strncpy(devInfo.loginName, SZSTR(user), 16);
    strncpy(devInfo.loginPsw, SZSTR(psw), 16);
    FUN_SysChangeDevInfo(self.msgHandle, &devInfo, "", "",(int)[deviceArray indexOfObject:devObj]);
    FUN_DevSetLocalPwd(devInfo.Devmac, [user UTF8String], [psw UTF8String]);
}

#pragma mark - 修改设备密码
- (void)changeDevicePsw:(NSString *)devMac loginName:(NSString *)name password:(NSString *)psw {
    FUN_DevSetLocalPwd(SZSTR(devMac),SZSTR(name), SZSTR(psw));
}

#pragma mark - 删除设备
- (void)deleteDeviceWithDevMac:(NSString *)devMac {
  NSMutableArray *deviceArray = [[DeviceControl getInstance] currentDeviceArray];
  
  DeviceObject *devObj = [[DeviceControl getInstance] GetDeviceObjectBySN:devMac];
  
  Fun_SysDeleteDevice(self.msgHandle, [devMac UTF8String], (int)[deviceArray indexOfObject:devObj]);
  
//    FUN_SysDelete_Dev(self.msgHandle, [devMac UTF8String], "", "", (int)[deviceArray indexOfObject:devObj]);
}

#pragma mark - 判断是否是主账号
- (void)checkMasterAccount:(NSString *)devMac {
    if (devMac == nil) {
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        devMac = channel.deviceMac;
    }
    Fun_SysIsDevMasterAccountFromServer(self.msgHandle, [devMac UTF8String], 0);
}
#pragma mark 获取设备列表和添加设备成功之后放入内存
- (void)resiveDevicelist:(NSMessage *)msg {
    [[DeviceControl getInstance] clearDeviceArray];
    SDBDeviceInfo *pInfos = (SDBDeviceInfo *)[msg obj];
    for(int i = 0; i < [msg param1]; ++i){
        //把结构体数据转换为对象数据
        DeviceObject *devObject = [self addDevice:&(pInfos[i])];
        [[DeviceControl getInstance] addDevice:devObject];
    }
    //获取到的数组，和本地已经保存的数组进行对比
    [[DeviceControl getInstance] checkDeviceValid];
}

#pragma mark Очистка массива устройств
- (void)clearDeviceList{
  [[DeviceControl getInstance] clearDeviceArray];
}

#pragma mark 获取被分享的设备
- (void)getShareToMeList{
    DeviceShareManager * deviceSharemanager = [[DeviceShareManager alloc] init];
    [deviceSharemanager requestDeviceSharedToMe:^(int result, NSArray * _Nonnull sharedToMeList) {
        //获取成功 解析设备信息
        for (int i = 0; i < sharedToMeList.count; i++){
            NSDictionary *dicInfo = [sharedToMeList objectAtIndex:i];
            NSString *uuid = [dicInfo objectForKey:@"uuid"];
            
            DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:uuid];
            //判断如果账号下已经存在该设备 就不显示分享的设备了
            if (devObject) {
                return;
            }
            
            devObject = [[DeviceObject alloc] init];
            devObject.deviceMac = uuid;
            devObject.deviceName = uuid;
            devObject.loginName = [dicInfo objectForKey:@"username"];
            devObject.loginPsw = [dicInfo objectForKey:@"password"];
            devObject.nPort = [[dicInfo objectForKey:@"port"] integerValue];
            devObject.nType =[[dicInfo objectForKey:@"type"] integerValue];
            devObject.ret = [[dicInfo objectForKey:@"ret"] intValue];
            
            SDBDeviceInfo devInfo = {0};
            strncpy(devInfo.Devmac, CSTR(devObject.deviceMac), 64);
            strncpy(devInfo.Devname, CSTR(devObject.deviceName), 128);
            strncpy(devInfo.loginName, CSTR(devObject.loginName), 16);
            strncpy(devInfo.loginPsw, CSTR(devObject.loginPsw), 64);
            devInfo.nType = devObject.nType;
            
            int result = Fun_AddDevInfoToDataCenterAsync(self.msgHandle, &devInfo, 0, 0, "",10000,0);
            if (result < 0) {
              return;
            }
          
            [[DeviceControl getInstance] addDevice:devObject];
        }
    }];
}

/*
-(DeviceObject *)deviceObjectInfoFormShare:(DeviceObject *)devObject DicInfo:(NSDictionary *)dicInfo{
    int ret = [[dicInfo objectForKey:@"ret"] intValue];
    NSString *uuid = [dicInfo objectForKey:@"uuid"];
    devObject.shareID = [dicInfo objectForKey:@"id"];
    devObject.shareUserName = [dicInfo objectForKey:@"account"];

    NSString *strPowers = [dicInfo objectForKey:@"powers"];
    if (![strPowers isMemberOfClass:[NSNull class]]) {
        strPowers = [strPowers gtm_stringByUnescapingFromHTML];
        NSDictionary *dicPowers = [self dictionaryWithJsonString:strPowers];
        if (dicPowers && [dicPowers objectForKey:@"devInfo"]) {
            NSString *info = [dicPowers objectForKey:@"devInfo"];
            NSArray *arrayInfo = [ShareModel decodeDevInfo:info];
            devObject.sharePD = [arrayInfo objectAtIndex:2];
            devObject.loginName = [arrayInfo objectAtIndex:1];
        }else{
            devObject.sharePD = @"";
        }
    }else{
        devObject.sharePD = @"";
    }

    if (ret == 0) {
        devObject.iShareSign = 2;
    }else{
        devObject.iShareSign = 1;
    }
    
    devObject.nType = 0;
    if ([dicInfo objectForKey:@"type"]) {
        devObject.nType = [[dicInfo objectForKey:@"type"] intValue];
    }
    
//    devObject.deviceName = uuid;
//    devObject.deviceMac = uuid;
    if (devObject.loginName.length <= 0) {
        devObject.loginName = @"admin";
    }
    
    SDBDeviceInfo devInfo = {0};
    strncpy(devInfo.Devmac, CSTR(devObject.deviceMac), 64);
    strncpy(devInfo.Devname, CSTR(devObject.deviceName), 128);
    strncpy(devInfo.loginName, CSTR(devObject.loginName), 16);
    strncpy(devInfo.loginPsw, "", 64);
    devInfo.nType = devObject.nType;
    
    Fun_AddDevInfoToDataCenterAsync(&devInfo, 0, 0, "");
    
    //取出本地密码
    char szPassword[80] = {0};
    FUN_DevGetLocalPwd(CSTR(devObject.deviceMac), szPassword);
    //判断本地密码是否为空
    if (OCSTR(szPassword).length <= 0) {
//        [[DeviceLocalConfig shareDeviceLocalConfig] changeDevice:devObject.deviceMac userName:devObject.loginName password:OCSTR(szPassword)];
    }
    
    //解析分享权限
    NSArray *arrayPermission = [dicInfo objectForKey:@"permissions"];
    NSString *permissions = @"";
    if (arrayPermission) {
        for (int i = 0; i < arrayPermission.count; i++) {
            NSDictionary *dicP = [arrayPermission objectAtIndex:i];
            NSString *param = [dicP objectForKey:@"label"];
            if ([[dicP objectForKey:@"enabled"] boolValue] && param) {
                permissions = [permissions stringByAppendingFormat:@",%@",param];
            }
        }
        
//        [devObject analyseShareAbility:permissions];
    }
    return devObject;
}
*/


- (void)addDeviceToList:(NSMessage *)msg {
    SDBDeviceInfo *pDevInfo = (SDBDeviceInfo *)[msg obj];
    DeviceObject *devObject = [self addDevice:pDevInfo];
    [[DeviceControl getInstance] addDevice:devObject];
}


#pragma mark 读取数据、数组中添加设备
- (DeviceObject *)addDevice:(SDBDeviceInfo *)pInfo {
    DeviceObject *devObject = [[DeviceObject alloc] init];
    devObject.deviceMac = [NSString stringWithUTF8String:(pInfo->Devmac)];
    devObject.deviceName = [NSString stringWithUTF8String:(pInfo->Devname)];
    devObject.loginName = [NSString stringWithUTF8String:(pInfo->loginName)];
    devObject.loginPsw = [NSString stringWithUTF8String:(pInfo->loginPsw)];
    devObject.nPort = pInfo->nPort;
    devObject.nType = pInfo->nType;
    return devObject;
}

#pragma mark 获取通道名称数组
- (NSMutableArray *)getChannleFromUserDB:(NSString *)devMac {
    int nChnCount = FUN_GetDevChannelCount(SZSTR(devMac));
    NSMutableArray *channel = [[NSMutableArray alloc] initWithCapacity:0];
    if (nChnCount > 0) {
        for (int i = 0; i < nChnCount; i++) {
            [channel addObject:[NSString stringWithFormat:@"%@%d", TS("Channel"), i + 1]];
        }
    }
    return channel;
}

#pragma mark 查询设备状态
-(void)requestDeviceStateWithDeviceIds:(NSString *)devID{
    [[DoorBellModel shareInstance] requestDeviceStateWithDeviceIds:devID];
    __weak typeof(self) weakSelf = self;
    [DoorBellModel shareInstance].DoorBellRequestDeviceStateCallBack = ^(NSString *devID) {
        //两次间隔小于0.2秒不刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf];
            [weakSelf performSelector:@selector(sortAndReload:) withObject:nil afterDelay:0.2];
        });
    };
}

#pragma mark - 刷新排序，两次间隔小于2秒不刷新
BOOL canRank = NO;
- (void)canReloadRankState {
    canRank = YES;
}
-(void)sortAndReload:(BOOL)quickly{
    //刷新设备在线状态
    if ([self.delegate respondsToSelector:@selector(getDeviceState:result:)]) {
        [self.delegate getDeviceState:nil result:YES];
    }
}

#pragma mark - 修改设备本地用户名密码 设置用户名密码会将支持token登录的设备token清空 注意设置顺序
-(void)changeDeviceUserNamePasswordLocal:(NSString*)sId userName:(NSString*)username password:(NSString*)password{
    if (!username || (username.length == 0)) {
        username = @"admin";
    }
    
    if (!password || password.length == 0) {
        password = @"";
    }
    //限制输入设备密码长度不超过64位 防止崩溃
    if (password.length > 64) {
        password = [password substringToIndex:65];
    }
    char szToken1[80] = {0};
    FUN_DevGetLocalEncToken(sId.UTF8String, szToken1);
    NSString *adminToken1 = [self tokenFromSDK:sId];
    FUN_DevSetLocalPwd(CSTR(sId), CSTR(username), CSTR(password));
    char szToken[80] = {0};
    FUN_DevGetLocalEncToken(sId.UTF8String, szToken);
    NSString *adminToken = OCSTR(szToken);
    if (adminToken.length <= 0 && adminToken1.length > 0) {
        [self changeDeviceLocal:sId loginToken:adminToken1];
    }
}

//MARK: 获取SDK缓存的Token
- (NSString *)tokenFromSDK:(NSString *)devID{
    char szToken[80] = {0};
    FUN_DevGetLocalEncToken(devID.UTF8String, szToken);
    
    return OCSTR(szToken);
}

//MARK: 修改本地登录token
- (void)changeDeviceLocal:(NSString *)devID loginToken:(NSString *)token{
    if (!token){
        token = @"";
    }
    Fun_DevSetLocalEncToken(CSTR(devID), CSTR(token));
}


#pragma mark - 回调 OnFunSDKResult
- (void)OnFunSDKResult:(NSNumber *) pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    NSLog(@"sender: %d", msg->sender);
    NSLog(@"id: %d", msg->id);
    NSLog(@"param1: %d", msg->param1);
    NSLog(@"param2: %d", msg->param2);
    NSLog(@"param3: %d", msg->param3);
    NSLog(@"szStr: %s", msg->szStr);
    NSLog(@"pObject: %s", msg->pObject);
    NSLog(@"nDataLen: %d", msg->nDataLen);
    NSLog(@"seq: %d", msg->seq);
    NSLog(@"pMsg: %p", msg->pMsg);
    NSLog(@"DeviceManager onFunSDKResult");

    switch (msg->id) {
        case EMSG_DEV_OPTION:{
            //MARK:串口收到回调
            NSLog(@"EMSG_DEV_OPTION = %d",msg->param1);
            NSLog(@"EMSG_DEV_OPTIO");
        }
            break;
        case EMSG_DEV_ON_TRANSPORT_COM_DATA: { //MARK:串口收到数据
            NSLog(@"收到串口数据:[%s] from [%s]",msg->pObject,msg->szStr);
            NSLog(@"收到");
        }
            break;
            #pragma mark 添加设备回调
        case EMSG_SYS_ADD_DEVICE:{
            [SVProgressHUD dismiss];
            if (msg->param1 < 0) {
                
                if (msg->param1 == -99992) {
                    if ([NSString checkSSID:[NSString getCurrent_SSID]]) {//直连方式增加设备
                    }else{
//                       [MessageUI ShowErrorInt:msg->param1];//非直连增加设备
                    }
                }else{
//                    [MessageUI ShowErrorInt:msg->param1];
                }
            }else{
                //添加设备成功
//                [SVProgressHUD showSuccessWithStatus:TS("Success")];
                [[DeviceManager getInstance] addDeviceToList:[NSMessage SendMessag:nil obj:msg->pObject p1:msg->param1 p2:0]];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(addDeviceResult:)]) {
              NSLog(@"EMSG_SYS_ADD_DEVICE delegate");

                [self.delegate addDeviceResult:msg->param1];
            }
        }
            break;
        #pragma mark 获取设备状态回调
        case EMSG_SYS_GET_DEV_STATE:{
            //回调结束刷新
            DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:NSSTR(msg->szStr)];
            if(devObject != nil){
                //设备状态
                devObject.state = msg->param1;
                
                // 门铃状态发生变化时处理。。手动设置为4(等待休眠。。然后过五秒之后去请求一下设备状态)
                __weak typeof(self) weakSelf = self;
                [DoorBellModel shareInstance].DoorBellEFunStateChangeSleep = ^(NSString *devMac,NSInteger time) {
                    DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:devMac];
                    devObject.eFunDevStateNotCode = 4;
//                    [weakSelf sortAndReload:YES];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        //门铃状态改变时 如果是准备休眠导致的 回调状态后 不需要去请求sysinfo等信息
                        [weakSelf requestDeviceStateWithDeviceIds:devObject.deviceMac];
                    });
                };
                
                
                devObject.eFunDevStateNotCode = FUN_GetDevState(CSTR(devObject.deviceMac), EFunDevStateType_IDR);
                //下面这个方法在获取设备状态回调后调用准确度最高
                devObject.info.eFunDevState = FUN_GetDevState(SZSTR(devObject.deviceMac), EFunDevStateType_IDR);
//                NSLog(@"设备 = %@， 状态 = %d",devObject.deviceMac,devObject.eFunDevStateNotCode);
                //刷新排序，两次间隔小于3秒不刷新
//                [self sortAndReload:NO];
                
                //设备状态在线的话,如果是低功耗设备。。获取一下当前设备休眠状态
                if(msg->param1 > 0){
                    if ([devObject getDeviceTypeLowPowerConsumption]) {
                        devObject.eFunDevStateNotCode = FUN_GetDevState(CSTR(devObject.deviceMac), EFunDevStateType_IDR);
                        //下面这个方法在获取设备状态回调后调用准确度最高
                        devObject.info.eFunDevState = FUN_GetDevState(SZSTR(devObject.deviceMac), EFunDevStateType_IDR);
                        if ([NSSTR(msg->szStr) containsString:@"5c9b"]) {
                            NSLog(@"设备装态%d",devObject.eFunDevStateNotCode);
                        }
                        //刷新排序，两次间隔小于3秒不刷新
//                        [self sortAndReload:NO];
                    }
                }
            }
            
            // После того как будут получены ответы на все запросы отправляем ответ
            if (--deviceStateRequestCounter == 0) {
                [self sortAndReload:YES];
            }
            
            //刷新排序，两次间隔小于3秒不刷新
//            [self sortAndReload:NO];
        }
            break;
             #pragma mark 设备唤醒回调
        case EMSG_DEV_WAKE_UP:{
            //门铃门锁类产品唤醒回调，这类产品根据设备类型不同，无操作一段时间（15/30秒）后可能会自动休眠，所以这一类设备每次操作前最好都能执行一次唤醒功能。如果想要准确实时获取这类设备的休眠状态，那么需要每过一段时间去获取一下。另外门铃门锁等智能唤醒设备，直接按门铃唤醒，会以报警推送的方式发消息给手机，app可以在收到消息后刷新状态
            //回调结束刷新，deviceMac是开始唤醒设备时保存的
                if (self.delegate && [self.delegate respondsToSelector:@selector(deviceWeakUp:result:)]) {
                    [self.delegate deviceWeakUp:deviceMac result:msg->param1];
            }
        }
            break;
        #pragma mark 获取设备通道回调
        case EMSG_DEV_GET_CHN_NAME:{
            DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:NSSTR(msg->szStr)];
            if (devObject == nil) {
                [SVProgressHUD dismiss];
            }
            //获取通道信息成功并且通道数>0
            if (msg->param1 >= 0 && msg->param3 > 0) {
                SDK_ChannelNameConfigAll *pChannels = (SDK_ChannelNameConfigAll *)msg->pObject;
                NSMutableArray *channelArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (int i = 0; i < msg->param3; i ++) {
                    NSString *str = NSSTR(pChannels->channelTitle[i]);
                    ChannelObject *channel = [[DeviceControl getInstance] addName:str ToDeviceObject:devObject];
                    channel.channelNumber = i;
                    [channelArray addObject: channel];
                }
                devObject.channelArray = [channelArray mutableCopy];
            }else if (msg->param1 == -400009){
                NSMutableArray *channelArray = [[NSMutableArray alloc] initWithCapacity:0];
                NSString *str = @"1";
                ChannelObject *channel = [[DeviceControl getInstance] addName:str ToDeviceObject:devObject];
                channel.channelNumber = 0;
                [channelArray addObject: channel];
                devObject.channelArray = [channelArray mutableCopy];
            }
            if (self.delegate &&  [self.delegate respondsToSelector:@selector(getDeviceChannel:result:)]) {
                [self.delegate getDeviceChannel:devObject.deviceMac result:msg->param1];
            }
        }
            break;
        #pragma mark 修改用户信息回调
        case  EMSG_SYS_CHANGEDEVINFO:{   // 修改用户设备信息
            NSMutableArray *deviceArray = [[DeviceControl getInstance] currentDeviceArray];
            if (deviceArray.count <= msg->seq) {
                return;
            }
            DeviceObject *devObject = [deviceArray objectAtIndex:msg->seq];
            if (devObject == nil) {
                return;
            }
            //修改成功，更新一下本地数据
            if (msg->param1 >= 0) {
                SDBDeviceInfo *pDevInfo = (SDBDeviceInfo *)msg->pObject;
                devObject.deviceName = [NSSTR(pDevInfo->Devname) gtm_stringByUnescapingFromHTML];
                devObject.loginPsw = NSSTR(pDevInfo->loginPsw);
                [deviceArray replaceObjectAtIndex:msg->seq withObject:devObject];
                //修改用户信息之后也要重新保存一遍
                [[DeviceControl getInstance] saveDeviceList];
            }
            if (self.delegate &&  [self.delegate respondsToSelector:@selector(changeDevice:changedResult:)]) {
                [self.delegate changeDevice:devObject.deviceMac changedResult:msg->param1];
            }
        }
            break;
            
#pragma mark - 修改密码
        case EMSG_SYS_EDIT_PWD_XM:
        {
            NSLog(@"修改密码成功");
        }
        #pragma mark 删除设备回调
        case EMSG_SYS_DELETE_DEV:{   // 删除设备
            NSLog(@"EMSG_SYS_DELETE_DEV");
            NSMutableArray *deviceArray = [[DeviceControl getInstance] currentDeviceArray];
            if (deviceArray.count <= msg->seq) {
                return;
            }
            DeviceObject *devObject = [deviceArray objectAtIndex:msg->seq];
            if (devObject == nil) {
                return;
            }
            if (msg->param1 >= 0) {
                //收到删除成功信息之后，注销设备报警通知
//                [[AlarmManager getInstance] UnlinkAlarm:devObject.deviceMac];
                //删除设备之后需要把数据保存本地一遍
                [deviceArray removeObject:devObject];
                [[DeviceControl getInstance] saveDeviceList];
            }
            //刷新界面
            if (self.delegate && [self.delegate respondsToSelector:@selector(deleteDevice:result:)]) {
                [self.delegate deleteDevice:devObject.deviceMac result:msg->param1];
            }
        }
            break;
        #pragma mark 局域网搜索回调
        case EMSG_DEV_SEARCH_DEVICES:{
            NSMutableArray *searchArray = [[NSMutableArray alloc] initWithCapacity:0];
            if (msg->param1 <= 0) {
                //没有搜索到设备
                [MessageUI ShowErrorInt:msg->param1];
                break;
            }
            [SVProgressHUD dismiss];
            struct SDK_CONFIG_NET_COMMON_V2* netCommonBuf = (struct SDK_CONFIG_NET_COMMON_V2*)msg->pObject;
            for (int i = 0; i < msg->param2; i++) {
                //屏蔽掉地址非法的设备
                if (netCommonBuf[i].HostIP.l == 0 || netCommonBuf[i].TCPPort == 0) {
                    continue;
                }
                DeviceObject *object = [[DeviceObject alloc] init];
                object.deviceMac  = [NSString stringWithUTF8String:netCommonBuf[i].sSn]; //设备序列号
                object.nType = netCommonBuf[i].DeviceType; //设备类型
                if (object.deviceMac == nil || (object.deviceMac.length != 16 && object.deviceMac.length != 20)) {
                    //序列号无效的话，改为设置IP
                    object.deviceMac  = [NSString stringWithFormat:@"%d.%d.%d.%d",netCommonBuf[i].HostIP.c[0],netCommonBuf[i].HostIP.c[1],netCommonBuf[i].HostIP.c[2],netCommonBuf[i].HostIP.c[3]];
                }
                object.deviceName = [NSString stringWithUTF8String:netCommonBuf[i].HostName]; //设备名称
                object.deviceIp  = [NSString stringWithFormat:@"%d.%d.%d.%d",netCommonBuf[i].HostIP.c[0],netCommonBuf[i].HostIP.c[1],netCommonBuf[i].HostIP.c[2],netCommonBuf[i].HostIP.c[3]];
                object.loginName = @"admin";
                object.loginPsw = @"";
                object.nPort = netCommonBuf[i].TCPPort;
                if (searchArray.count == 0) {
                    //设备数组为空时不需判断直接添加
                    [searchArray addObject:object];
                    continue;
                }
                BOOL find = NO;
                for (DeviceObject *device in searchArray) {
                    if ([device.deviceMac isEqualToString:object.deviceMac]) {
                        find = YES;
                    }
                }
                if (find == NO) {
                    //如果不包含则添加设备
                    [searchArray addObject:object];
                }
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(searchDevice:result:)]) {
                //局域网设备 搜索结果回调
                [self.delegate searchDevice:searchArray result:msg->param1];
            }
        }
            break;
        #pragma mark 快速配置回调
        case EMSG_DEV_AP_CONFIG:
        {
            if (msg->param1 <= 0) {
                //没有搜索到设备
                [MessageUI ShowErrorInt:msg->param1];
                break;
            }
            [SVProgressHUD dismiss];
            DeviceObject *object = [[DeviceObject alloc] init];
            SDK_CONFIG_NET_COMMON_V2 *pCfg = (SDK_CONFIG_NET_COMMON_V2 *)msg->pObject;
            NSString* devSn = @"";
            NSString* name = @"";
            int nDevType = 0;
            int nResult = msg->param1;
            if ( nResult>=0 && pCfg) {
                name = NSSTR(pCfg->HostName);
                devSn = NSSTR(pCfg->sSn);
                nDevType = pCfg->DeviceType;
            }
            object.deviceMac = devSn;
            object.nType = nDevType;
            object.deviceName = name;
            if (self.delegate && [self.delegate respondsToSelector:@selector(quickConfiguration:result:)] ) {
                [self.delegate quickConfiguration:object result:msg->param1];
            }
        }
            break;
        case EMSG_DEV_SET_WIFI_CFG:
        {
            if (msg->param1 <= 0) {
                //没有搜索到设备
                [MessageUI ShowErrorInt:msg->param1];
                break;
            }
            [SVProgressHUD dismiss];
            DeviceObject *object = [[DeviceObject alloc] init];
            SDK_CONFIG_NET_COMMON_V2 *pCfg = (SDK_CONFIG_NET_COMMON_V2 *)msg->pObject;
            NSString* devSn = @"";
            NSString* name = @"";
            int nDevType = 0;
            int nResult = msg->param1;
            if ( nResult>=0 && pCfg) {
                name = NSSTR(pCfg->HostName);
                devSn = NSSTR(pCfg->sSn);
                nDevType = pCfg->DeviceType;
            }
            object.deviceMac = devSn;
            object.nType = nDevType;
            object.deviceName = name;
            if (self.delegate && [self.delegate respondsToSelector:@selector(quickConfiguration:result:)] ) {
                [self.delegate quickConfiguration:object result:msg->param1];
            }
        }
            break;
            #pragma mark 判断是否是主账号回调
        case EMSG_SYS_IS_MASTERMA: {
            if ([self.delegate respondsToSelector:@selector(checkMaster:Result:)]) {
                [self.delegate checkMaster:nil Result:msg->param1];
            }
        }
            break;
#pragma mark - 删除设备报警
        case EMSG_MC_UnlinkDev:
        {
            if (msg->seq == 101) {
                FUN_DevLogout(self.msgHandle, deviceMac.UTF8String);
                
                //删除设备报警之后添加设备
                NSString *loginTokenJsonStr = [NSString convertToJSONData:@{@"AdminToken":self.loginToken.length==0?@"":self.loginToken}];
                /*
                 ma=true：是否是主账号添加
                 ext=just_test_ext：扩展参数，APP自定义传输，例如当前添加的是某种特定型号设备 Speical_Device
                 delOth=true：是否删除其他账号下的设备
                 */
                NSString *param = @"ma=true&ext=just_test_ext&delOth=true";
                if ([self.dicCloudCryNum objectForKey:OCSTR(wifiDevInfo.Devmac)]) {
                    param = [NSString stringWithFormat:@"%@&cryNum=%@",param,[self.dicCloudCryNum objectForKey:OCSTR(wifiDevInfo.Devmac)]];
                    [self.dicCloudCryNum removeAllObjects];
                }
                FUN_SysAdd_Device(self.msgHandle, &wifiDevInfo,param.UTF8String,(self.loginToken.length > 0 && loginTokenJsonStr) ? loginTokenJsonStr.UTF8String : "");
                
                
            }
        }
            break;

        default:
            break;
    }
}


#pragma mark - LazyLoad
- (DevicePairingNetworkManager *)devicePairingNetworkManager{
    if (!_devicePairingNetworkManager) {
        _devicePairingNetworkManager = [[DevicePairingNetworkManager alloc] init];
    }
    
    return _devicePairingNetworkManager;
}

- (NSMutableDictionary *)dicCloudCryNum{
    if (!_dicCloudCryNum) {
        _dicCloudCryNum = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return _dicCloudCryNum;
}

- (DeviceBindedManager *)bindManager{
    if (!_bindManager) {
        _bindManager = [[DeviceBindedManager alloc]init];
    }
    
    return _bindManager;
}

@end
