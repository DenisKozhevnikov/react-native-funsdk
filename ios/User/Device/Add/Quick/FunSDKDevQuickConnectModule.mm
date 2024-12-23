//
//  FunSDKDevQuickConnectModule.mm
//  Funsdk
//
//  Created by Денис Кожевников on 08.12.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import "FunSDKDevQuickConnectModule.h"
#import "FunSDK/FunSDK.h"
#import <React/RCTLog.h>
#import "XMNetInterface/NetInterface.h"
#import "DeviceRandomPwdManager.h"
#import "DeviceManager.h"

@interface FunSDKDevQuickConnectModule()<DeviceManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;

@property (nonatomic,assign) UI_HANDLE msgHandle;

@property (nonatomic, strong) NSMutableDictionary *dataSourceDic;

@property (nonatomic, strong) DeviceObject *deviceInfo;
//@property (nonatomic, strong) DeviceManager *deviceManager;

@end

@implementation FunSDKDevQuickConnectModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}
//
//- (id)init {
//    self = [super init];
//    
//    self.requestCounter = 1;
//    
//    return self;
//}

-(instancetype)init{
    self = [super init];
    self.msgHandle = FUN_RegWnd((__bridge LP_WND_OBJ)self);
    return self;
    
}

-(void)dealloc{
    
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
    
}

//-(DeviceManager *)deviceManager{
//    if (!_deviceManager) {
//        _deviceManager = [[DeviceManager alloc] init];
//        _deviceManager.delegate = self;
//    }
//    return _deviceManager;
//}
//
//- (NSNumber *)generateRequestKeyWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
//    if (!self.resolvers) {
//        self.resolvers = [NSMutableDictionary dictionary];
//    }
//    
//    self.requestCounter++;
//    NSNumber *key = @(_requestCounter);
//    
//    // Сохраняем блоки resolve и reject в маппинг
//    self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
//    
//    return key;
//}

#pragma - mark Поиск устройств
RCT_EXPORT_METHOD(startSetWiFi:(NSDictionary *)params)
{
  NSString *passwordWifi = params[@"passwordWifi"];
  NSString *ssidWifi = params[@"ssidWifi"];
  BOOL isDevDeleteFromOthersUsers = params[@"isDevDeleteFromOthersUsers"];
  
  
  char data[128] = {0};
  char infof[256] = {0};
  int encmode = 1;
  unsigned char mac[6] = {0};
  sprintf(data, "S:%sP:%sT:%d", [ssidWifi UTF8String], SZSTR(passwordWifi), encmode);
  NSString* sGateway = [NetInterface getDefaultGateway];
  sprintf(infof, "gateway:%s ip:%s submask:%s dns1:%s dns2:%s mac:0", SZSTR(sGateway), [[NSString getCurrent_IP_Address] UTF8String],"255.255.255.0",SZSTR(sGateway),SZSTR(sGateway));
  NSString* sMac = [NetInterface getCurrent_Mac];
  
  sscanf(SZSTR(sMac), "%x:%x:%x:%x:%x:%x", &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]);
  
  NSLog(@"gateway: %s, sMac: %s", [sGateway UTF8String], [sMac UTF8String]);
  NSLog(@"mac: %02x:%02x:%02x:%02x:%02x:%02x", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
  
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  result[@"status"] = @"поиск начат";
  [self sendEventWithName:@"onSetWiFi" body:result];
  
  [self sendDeviceConnectStatus:@"start" errorId:nil msgId:nil xmDevInfo:nil];

  // 快速配置接口
  // WIFI配置配置接口（WIFI信息特殊方式发送给设备-->接收返回（MSGID->EMSG_DEV_AP_CONFIG））
//  int FUN_DevStartAPConfig(UI_HANDLE hUser, int nGetRetType, const char *ssid, const char *data, const char *info, const char *ipaddr, int type, int isbroad, const unsigned char wifiMac[6], int nTimeout = 10000);
  FUN_DevStartAPConfig(self.msgHandle, 3, SZSTR(ssidWifi), data, infof, SZSTR(sGateway), encmode, 1, mac, 180000);
//  NSNumber *key = [self generateRequestKeyWithResolver:resolve rejecter:reject];
}

#pragma - mark Остановить поиск устройств
RCT_EXPORT_METHOD(stopSetWiFi:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
//  NSNumber *key = [self generateRequestKeyWithResolver:resolve rejecter:reject];
//  
//  self.sendDeviceConnectStatus(@"stop", null, null, null);
  FUN_DevStopAPConfig();
  resolve(@(YES));
}

- (void)sendDeviceConnectStatus:(NSString *)status
                        errorId:(nullable id)errorId
                          msgId:(nullable id)msgId
                       xmDevInfo:(nullable NSDictionary *)xmDevInfo {
    NSMutableDictionary *addDevResult = [NSMutableDictionary dictionary];
    addDevResult[@"status"] = status;
    
    if (errorId) {
        addDevResult[@"errorId"] = errorId;
    }
    if (msgId) {
        addDevResult[@"msgId"] = msgId;
    }

//    if (xmDevInfo) {
//        NSMutableDictionary *deviceData = [NSMutableDictionary dictionary];
//        deviceData[@"devId"] = xmDevInfo[@"devId"];
//        deviceData[@"devName"] = xmDevInfo[@"devName"];
//        deviceData[@"devUserName"] = xmDevInfo[@"devUserName"];
//        deviceData[@"devPassword"] = xmDevInfo[@"devPassword"];
//        deviceData[@"devIp"] = xmDevInfo[@"devIp"];
//        deviceData[@"devPort"] = xmDevInfo[@"devPort"];
//        deviceData[@"devType"] = xmDevInfo[@"devType"];
//        deviceData[@"devState"] = xmDevInfo[@"devState"];
//        deviceData[@"string"] = xmDevInfo[@"string"];
//        deviceData[@"pid"] = xmDevInfo[@"pid"];
//        deviceData[@"mac"] = xmDevInfo[@"mac"];
//        deviceData[@"devToken"] = xmDevInfo[@"devToken"];
//        deviceData[@"cloudCryNum"] = xmDevInfo[@"cloudCryNum"];
//
//        addDevResult[@"deviceData"] = deviceData;
//    }

    [self sendEventWithName:@"onAddDeviceStatus" body:addDevResult];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onAddDeviceStatus", @"onSetWiFi"];
}

//- (void)addListener:(NSString *)type {
//    // Вызывается из JS, когда добавляется слушатель событий.
//    NSLog(@"Добавлен слушатель для события: %@", type);
//}
//
//- (void)removeListeners:(NSString *)type {
//    // Вызывается из JS, когда удаляется слушатель событий.
//    NSLog(@"Удален слушатель для события: %@", type);
//}

#pragma mark - получение результатов OnFunSDKResult
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
  
  switch (msg->id) {
    // Результат от FUN_DevStartAPConfig
    case EMSG_DEV_AP_CONFIG: {
      if (msg->param1 < 0) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        result[@"status"] = @"ошибка при поиске";
        result[@"error"] = [NSString stringWithFormat:@"errorId: %@", @(msg->param1)];
        [self sendEventWithName:@"onSetWiFi" body:result];
        
        [self sendDeviceConnectStatus:@"error" errorId:@(msg->param1) msgId:nil xmDevInfo:nil];
        
      } else {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        result[@"status"] = @"успешно найдено устройство, идём получать случайное имя пользователя и пароль";
        [self sendEventWithName:@"onSetWiFi" body:result];
        
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
          
          NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionary];
          deviceInfo[@"status"] = @"полученные данные";
          deviceInfo[@"hostName"] = NSSTR(pCfg->HostName);
          deviceInfo[@"sSn"] = NSSTR(pCfg->sSn);
          
          [self sendEventWithName:@"onSetWiFi" body:result];
        }
        object.deviceMac = devSn;
        object.nType = nDevType;
        object.deviceName = name;
        
        self.deviceInfo = object;
        
//        взято из AddLANCameraViewController
        __weak typeof(self) weakSelf = self;
        [[DeviceRandomPwdManager shareInstance] getDeviceRandomPwd:self.deviceInfo.deviceMac autoSetUserNameAndPassword:YES Completion:^(BOOL completion) {

            if (completion) {
                
                weakSelf.dataSourceDic = [[[DeviceRandomPwdManager shareInstance] getDeviceRandomPwdFromLocal:weakSelf.deviceInfo.deviceMac] mutableCopy];
              
              NSMutableDictionary *result = [NSMutableDictionary dictionary];
              result[@"status"] = weakSelf.dataSourceDic;
              [self sendEventWithName:@"onSetWiFi" body:result];
              
              
              BOOL canBeRandom = [[self.dataSourceDic objectForKey:@"random"] boolValue];
            }
        }];
//        todoshnik:
//        разобраться и понять действительно ли будут рандомные логин и пароль, видимо надо еще отсылать их и запоминать в приложении (иначе будет сложно поделиться)
        // deviceIsValidatePassword понять надо ли устанавливать пароль согласно правилам
        // понять как подгтовить данные чтобы успнш отправить в addDeviceWithDeviceName
      }
    }
//      example
//    case EMSG_DEV_GET_CONFIG_JSON:{
//      NSNumber *key = @(msg->seq);
//      NSDictionary *callbacks = self.resolvers[key];
//      
//      RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
//      RCTPromiseRejectBlock reject = callbacks[@"reject"];
//      
//      if (msg->param1 < 0) {
//          if (reject) {
//              NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
//              reject(@"loginDeviceWithCredential_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
//          }
//      } else {
//        if (resolve) {
          
//          NSDictionary *responseObject = @{
//              @"i": @(1),
//              @"s": dicInfo[@"SerialNo"],
//              @"value": dicInfo
//          };
//          resolve();
//        }
//      }
//      [self.resolvers removeObjectForKey:key];
//    }
//      break;
  }
}
          
@end

