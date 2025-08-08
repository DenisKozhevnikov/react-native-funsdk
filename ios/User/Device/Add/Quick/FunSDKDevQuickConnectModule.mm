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
  if (sMac == nil || sMac.length == 0) {
      sMac = @"28:f0:70:60:3f:76";
      sMac = @"21:f1:70:63:2f:76";
  }
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
  [self sendDeviceConnectStatus:@"stop" errorId:nil msgId:nil xmDevInfo:nil];
  resolve(@(YES));
}

#pragma - mark Поиск устройств (новый метод)
RCT_EXPORT_METHOD(startDeviceSearch:(NSDictionary *)params)
{
  NSString *passwordWifi = params[@"passwordWifi"];
  NSString *ssidWifi = params[@"ssidWifi"];

  char data[128] = {0};
  char infof[256] = {0};
  int encmode = 1;
  unsigned char mac[6] = {0};
  sprintf(data, "S:%sP:%sT:%d", [ssidWifi UTF8String], SZSTR(passwordWifi), encmode);
  NSString* sGateway = [NetInterface getDefaultGateway];
  sprintf(infof, "gateway:%s ip:%s submask:%s dns1:%s dns2:%s mac:0", SZSTR(sGateway), [[NSString getCurrent_IP_Address] UTF8String],"255.255.255.0",SZSTR(sGateway),SZSTR(sGateway));
  NSString* sMac = [NetInterface getCurrent_Mac];
  if (sMac == nil || sMac.length == 0) {
      sMac = @"28:f0:70:60:3f:76";
      sMac = @"21:f1:70:63:2f:76";
  }
  sscanf(SZSTR(sMac), "%x:%x:%x:%x:%x:%x", &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]);

  NSLog(@"gateway: %s, sMac: %s", [sGateway UTF8String], [sMac UTF8String]);
  NSLog(@"mac: %02x:%02x:%02x:%02x:%02x:%02x", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);

  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  result[@"status"] = @"поиск начат";
  [self sendEventWithName:@"onSetWiFi" body:result];

  [self sendDeviceConnectStatus:@"start" errorId:nil msgId:nil xmDevInfo:nil];

  // Быстрая конфигурация
  FUN_DevStartAPConfig(self.msgHandle, 3, SZSTR(ssidWifi), data, infof, SZSTR(sGateway), encmode, 1, mac, 180000);
}

#pragma - mark Добавление найденного устройства (новый метод)
RCT_EXPORT_METHOD(addFoundDevice:(NSDictionary *)deviceInfo
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  if (!self.resolvers) {
    self.resolvers = [NSMutableDictionary dictionary];
  }
  
  // Сохраняем resolve и reject для добавления
  NSNumber *addKey = @(EMSG_SYS_ADD_DEVICE);
  self.resolvers[addKey] = @{@"resolve": resolve, @"reject": reject};
  
  NSString *deviceMac = deviceInfo[@"deviceMac"];
  NSString *deviceName = deviceInfo[@"deviceName"];
  NSString *loginName = deviceInfo[@"loginName"];
  NSString *loginPassword = deviceInfo[@"loginPassword"];
  NSNumber *deviceType = deviceInfo[@"deviceType"];
  
  if (!deviceMac) {
    reject(@"invalid_params", @"deviceMac обязателен", [NSError errorWithDomain:@"FunSDK" code:-1 userInfo:nil]);
    return;
  }
  
  // Создаем объект устройства
  DeviceObject *object = [[DeviceObject alloc] init];
  object.deviceMac = deviceMac;
  object.deviceName = deviceName ?: deviceMac;
  object.nType = deviceType ? [deviceType intValue] : 0;
  
  self.deviceInfo = object;
    
  // Получаем случайные учетные данные
  __weak typeof(self) weakSelf = self;
  [[DeviceRandomPwdManager shareInstance] getDeviceRandomPwd:deviceMac autoSetUserNameAndPassword:YES Completion:^(BOOL completion) {
    
    if (completion) {
      NSMutableDictionary *dic = [[[DeviceRandomPwdManager shareInstance] getDeviceRandomPwdFromLocal:deviceMac] mutableCopy];
      
      // Проверяем, нужны ли случайные учетные данные
      if ([[dic objectForKey:@"random"] boolValue]) {
        // Устройство с случайными учетными данными
        NSString *finalLoginName = loginName ?: dic[@"userName"] ?: @"admin";
        NSString *finalPassword = loginPassword ?: dic[@"password"] ?: @"";
        
        // Изменяем случайные учетные данные
        [[DeviceRandomPwdManager shareInstance] ChangeRandomUserWithDevID:deviceMac newUser:finalLoginName newPassword:finalPassword result:^(int result, NSString *adminToken, NSString *guestToken) {
          if (result >= 0) {
            [weakSelf addDeviceWithDeviceName:deviceName ?: deviceMac loginName:finalLoginName loginPassword:finalPassword deviceType:object.nType];
          } else {
            NSDictionary *callbacks = weakSelf.resolvers[addKey];
            if (callbacks) {
              RCTPromiseRejectBlock reject = callbacks[@"reject"];
              reject(@"random_user_error", [NSString stringWithFormat:@"Ошибка изменения случайных учетных данных: %d", result], [NSError errorWithDomain:@"FunSDK" code:result userInfo:nil]);
              [weakSelf.resolvers removeObjectForKey:addKey];
            }
          }
        }];
      } else {
        // Обычное устройство
        NSString *finalLoginName = loginName ?: @"admin";
        NSString *finalPassword = loginPassword ?: @"";
        
        [weakSelf addDeviceWithDeviceName:deviceName ?: deviceMac loginName:finalLoginName loginPassword:finalPassword deviceType:object.nType];
      }
    } else {
      NSDictionary *callbacks = weakSelf.resolvers[addKey];
      if (callbacks) {
        RCTPromiseRejectBlock reject = callbacks[@"reject"];
        reject(@"random_pwd_error", @"Не удалось получить случайные учетные данные", [NSError errorWithDomain:@"FunSDK" code:-1 userInfo:nil]);
        [weakSelf.resolvers removeObjectForKey:addKey];
      }
    }
  }];
}

// Вспомогательный метод для добавления устройства
- (void)addDeviceWithDeviceName:(NSString *)deviceName 
                     loginName:(NSString *)loginName 
                 loginPassword:(NSString *)loginPassword 
                   deviceType:(int)deviceType {
  
  SDBDeviceInfo devInfo = {0};
  STRNCPY(devInfo.Devname, SZSTR(deviceName));
  STRNCPY(devInfo.Devmac, SZSTR(self.deviceInfo.deviceMac));
  STRNCPY(devInfo.loginName, SZSTR(loginName));
  STRNCPY(devInfo.loginPsw, SZSTR(loginPassword));
  devInfo.nType = deviceType;
  devInfo.nPort = 34567;
  
  // Создаем DeviceManager для добавления устройства
  DeviceManager *deviceManager = [[DeviceManager alloc] init];
  deviceManager.delegate = self;
  
  // Добавляем устройство через WiFi конфигурацию
  [deviceManager addDeviceByWiFiConfig:self.deviceInfo.deviceMac 
                             deviceName:deviceName 
                              loginName:loginName 
                          loginPassword:loginPassword 
                                devType:deviceType];
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

    if (xmDevInfo) {
        addDevResult[@"deviceData"] = xmDevInfo;
    }

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
        // Ошибка поиска
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        result[@"status"] = @"ошибка при поиске";
        result[@"error"] = [NSString stringWithFormat:@"errorId: %@", @(msg->param1)];
        [self sendEventWithName:@"onSetWiFi" body:result];
        [self sendDeviceConnectStatus:@"error" errorId:@(msg->param1) msgId:nil xmDevInfo:nil];
      } else {
        // Успешный поиск
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        result[@"status"] = @"успешно найдено устройство";
        [self sendEventWithName:@"onSetWiFi" body:result];
        [self sendDeviceConnectStatus:@"connected" errorId:nil msgId:nil xmDevInfo:nil];

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
          [self sendEventWithName:@"onSetWiFi" body:deviceInfo];
        }
        object.deviceMac = devSn;
        object.nType = nDevType;
        object.deviceName = name;

        // Получаем случайные учетные данные
        __weak typeof(self) weakSelf = self;
        [[DeviceRandomPwdManager shareInstance] getDeviceRandomPwd:devSn autoSetUserNameAndPassword:YES Completion:^(BOOL completion) {
            if (completion) {
              NSMutableDictionary *dic = [[[DeviceRandomPwdManager shareInstance] getDeviceRandomPwdFromLocal:devSn] mutableCopy];
              NSMutableDictionary *xmDevInfo = [NSMutableDictionary dictionary];
              xmDevInfo[@"devId"] = object.deviceMac ?: @"";
              xmDevInfo[@"devType"] = @(object.nType);
              xmDevInfo[@"devName"] = object.deviceName ?: @"";
              xmDevInfo[@"devUserName"] = dic[@"userName"] ?: @"";
              xmDevInfo[@"devPassword"] = dic[@"password"] ?: @"";
              xmDevInfo[@"withRandomPassword"] = dic[@"random"];
              NSLog(@"xmDevInfo: %@", xmDevInfo);

              [self sendDeviceConnectStatus:@"readyToAdd" errorId:nil msgId:nil xmDevInfo:xmDevInfo];
              [self sendEventWithName:@"onSetWiFi" body:dic];
            }
        }];
      }
    }
      break;
      
    // Результат добавления устройства
    case EMSG_SYS_ADD_DEVICE: {
      NSNumber *addKey = @(EMSG_SYS_ADD_DEVICE);
      NSDictionary *addCallbacks = self.resolvers[addKey];
      
      if (msg->param1 < 0) {
        // Ошибка добавления устройства
        NSString *errorMessage;
        if (msg->param1 == -99992 || msg->param1 == -604101) {
          errorMessage = @"Устройство уже существует";
        } else {
          errorMessage = [NSString stringWithFormat:@"Ошибка добавления устройства: %d", msg->param1];
        }
        
        if (addCallbacks) {
          RCTPromiseRejectBlock reject = addCallbacks[@"reject"];
          reject(@"add_device_error", errorMessage, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
          [self.resolvers removeObjectForKey:addKey];
        }
      } else {
        // Успешное добавление устройства
        SDBDeviceInfo *pDevInfo = (SDBDeviceInfo *)msg->pObject;
        
        if (addCallbacks) {
          RCTPromiseResolveBlock resolve = addCallbacks[@"resolve"];
          NSMutableDictionary *result = [NSMutableDictionary dictionary];
          result[@"success"] = @(YES);
          result[@"deviceMac"] = self.deviceInfo.deviceMac;
          result[@"deviceName"] = self.deviceInfo.deviceName;
          result[@"message"] = @"Устройство успешно добавлено";
          resolve(result);
          [self.resolvers removeObjectForKey:addKey];
        }
      }
    }
      break;
  }
}

#pragma mark - DeviceManagerDelegate

- (void)addDeviceResult:(int)result {
  NSNumber *addKey = @(EMSG_SYS_ADD_DEVICE);
  NSDictionary *addCallbacks = self.resolvers[addKey];
  
  if (result >= 0) {
    // Успешное добавление
    if (addCallbacks) {
      RCTPromiseResolveBlock resolve = addCallbacks[@"resolve"];
      NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
      resultDict[@"success"] = @(YES);
      resultDict[@"deviceMac"] = self.deviceInfo.deviceMac;
      resultDict[@"deviceName"] = self.deviceInfo.deviceName;
      resultDict[@"message"] = @"Устройство успешно добавлено";
      resolve(resultDict);
      [self.resolvers removeObjectForKey:addKey];
    }
  } else {
    // Ошибка добавления
    if (addCallbacks) {
      RCTPromiseRejectBlock reject = addCallbacks[@"reject"];
      NSString *errorMessage = [NSString stringWithFormat:@"Ошибка добавления устройства: %d", result];
      reject(@"add_device_error", errorMessage, [NSError errorWithDomain:@"FunSDK" code:result userInfo:nil]);
      [self.resolvers removeObjectForKey:addKey];
    }
  }
}
          
@end

