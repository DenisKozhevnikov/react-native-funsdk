//
//  FunSDKDevConfigModule.mm
//  Funsdk
//
//  Created by Денис Кожевников on 15.01.2025.
//  Copyright © 2025 Facebook. All rights reserved.
//

#import "FunSDK/FunSDK.h"
#import <FunSDK/FunSDK2.h>
#import <FunSDK/Fun_MC.h>
#import "FunSDKDevConfigModule.h"
#import "DeviceControl.h"

@interface FunSDKDevConfigModule()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;
@property (nonatomic, assign) NSInteger requestCounter;

@end

@implementation FunSDKDevConfigModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (id)init {
  self = [super init];
  
  self.requestCounter = 1;
  
  return self;
}


#pragma - mark Получение данных с устройства
RCT_EXPORT_METHOD(getDevCmdGeneral:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  if (!self.resolvers) {
    self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  NSString *deviceId = params[@"deviceId"]; // id устройства
  NSNumber *cmdReq = params[@"cmdReq"]; // 1452
  NSString *cmd = params[@"cmd"]; // "OPTimeQuery"
  NSNumber *nBinary = params[@"nBinary"]; // 0, 1430, 4096?
  NSNumber *timeout = params[@"timeout"];
  NSString *param = params[@"param"];
  if ([param isKindOfClass:[NSNull class]]) {
    param = nil;
  }
  NSNumber *inParamLen = params[@"inParamLen"];
  NSNumber *cmdRes = params[@"cmdRes"];
  
  char *pInParam = param ? strdup([param UTF8String]) : NULL;
  
  FUN_DevCmdGeneral(
    self.msgHandle,
    [deviceId UTF8String], // fklwejnf3f23
    [cmdReq intValue], // 1452
    [cmd UTF8String], // "OPTimeQuery"
    [nBinary intValue], // 0, 1430, 4096?
    [timeout intValue], // 5000
    pInParam, // NULL
    [inParamLen intValue], // 0
    [cmdRes intValue], // 0
    [key intValue]
  );
  
  //  FUN_DevCmdGeneral(SELF, SZSTR(param.devId), (int)param.cmdGet, SZSTR(param.name), 0, 5000, cmd, (int)strlen(cmd) + 1,  -1, 0);
  
  //  int FUN_DevCmdGeneral(UI_HANDLE hUser, const char *szDevId, int nCmdReq, const char *szCmd, int nIsBinary, int nTimeout, char *pInParam = NULL, int nInParamLen = 0, int nCmdRes = -1, int nSeq = 0);
  
  // примеры отправки данных
  //  FUN_DevCmdGeneral(self.msgHandle, [deviceId UTF8String], 1452, "OPTimeQuery", 0, [timeout intValue], NULL, 0, -1, [key intValue]);
  
  //  restart device example
  //  char szParam[128] = {0};
  //  sprintf(szParam, "{\"Name\":\"OPMachine\",\"SessionID\":\"0x00000001\",\"OPMachine\":{\"Action\":\"Reboot\"}}");
  //  FUN_DevCmdGeneral(self.msgHandle, SZSTR(channel.deviceMac), 1450, "OPMachine", 0, 5000, szParam, 0);
}


#pragma - mark Получение данных с устройства
RCT_EXPORT_METHOD(getDevConfig:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  if (!self.resolvers) {
    self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  NSString *deviceId = params[@"deviceId"];
  NSString *name = params[@"name"];
  NSNumber *nOutBufLen = params[@"nOutBufLen"];
  NSNumber *channel = params[@"channel"];
  NSNumber *timeout = params[@"timeout"];
  
  NSLog(@"Device Data - Device ID: %@, Name: %@, Output Buffer Length: %@, Channel: %@, Timeout: %@",
        deviceId, name, nOutBufLen, channel, timeout);
  //  int FUN_DevGetConfig_Json(UI_HANDLE hUser, const char *szDevId, const char *szCommand, int nOutBufLen, int nChannelNO = -1, int nTimeout = 15000, int nSeq = 0);
  FUN_DevGetConfig_Json(
    self.msgHandle,
    [deviceId UTF8String],
    [name UTF8String],
    [nOutBufLen intValue],
    [channel intValue],
    [timeout intValue],
    [key intValue]
  );
}


#pragma - mark Сохраннение настроек устройства
RCT_EXPORT_METHOD(setDevConfig:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  if (!self.resolvers) {
    self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  NSString *deviceId = params[@"deviceId"];
  NSString *name = params[@"name"];
  NSString *param = params[@"param"];
  NSNumber *channel = params[@"channel"];
  NSNumber *timeout = params[@"timeout"];
//  FUN_DevSetConfig_Json(self.msgHandle, [self.devID UTF8String],"General.TimimgPtzTour", [pCfgBufString UTF8String], (int)(strlen([pCfgBufString UTF8String]) + 1), -1, 10000);
  
//  int FUN_DevSetConfig_Json(UI_HANDLE hUser, const char *szDevId, const char *szCommand, const void *pConfig, int nConfigLen, int nChannelNO = -1, int nTimeout = 15000, int nSeq = 0);
  
  FUN_DevSetConfig_Json(
    self.msgHandle,
    [deviceId UTF8String],
    [name UTF8String],
    [param UTF8String],
    (int)(strlen([param UTF8String]) + 1),
    [channel intValue],
    [timeout intValue],
    [key intValue]
  );
}


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
      case EMSG_DEV_GET_CONFIG_JSON:
      case EMSG_DEV_CMD_EN: {
        
          NSNumber *key = @(msg->seq);
          NSDictionary *callbacks = self.resolvers[key];
          
          RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
          RCTPromiseRejectBlock reject = callbacks[@"reject"];

          
          if (msg->param1 < 0) {
            if (reject) {
              NSLog(@"Начало обработки ошибки");
              NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
              reject(@"EMSG_DEV_GET_CONFIG_JSON_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
            }
          } else {
            if (resolve) {
              NSLog(@"Начало обработки сообщения с param3 == 1452");
              
              char *result = (char *)msg->pObject;
              NSLog(@"Получен указатель result: %s", result);
              
              NSData *resultData = [NSData dataWithBytes:result length:strlen(result)];
              NSLog(@"Преобразовано в NSData: %@", resultData);
              
              NSError *error;
              NSMutableDictionary *socketInfoDic = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
              
              if (error) {
                NSLog(@"Ошибка при преобразовании JSON: %@", error.localizedDescription);
                
                NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
                reject(@"EMSG_DEV_GET_CONFIG_JSON_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
              } else {
                NSLog(@"Преобразованный JSON в NSDictionary: %@", socketInfoDic);
                resolve(socketInfoDic);
              }
              
              NSLog(@"Завершение обработки сообщения");
            }
          }
        [self.resolvers removeObjectForKey:key];
      }
        break;
      case EMSG_DEV_SET_CONFIG_JSON:{
        NSNumber *key = @(msg->seq);
        NSDictionary *callbacks = self.resolvers[key];
        
        RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
        RCTPromiseRejectBlock reject = callbacks[@"reject"];
        
        if (msg->param1 < 0) {
          if (reject) {
            NSLog(@"Начало обработки ошибки");
            NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
            reject(@"EMSG_DEV_SET_CONFIG_JSON_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
          }
        } else {
          if (resolve) {
            NSLog(@"Начало обработки сообщения с EMSG_DEV_SET_CONFIG_JSON");
            
            char *result = (char *)msg->pObject;
            NSLog(@"Получен указатель result: %s", result);
            
            NSData *resultData = [NSData dataWithBytes:result length:strlen(result)];
            NSLog(@"Преобразовано в NSData: %@", resultData);
            
            NSError *error;
            NSMutableDictionary *socketInfoDic = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
            
            if (error) {
              resolve(@{
                @"s": @(msg->szStr),
                @"i": @1,
                @"value": [NSNull null]
              });
            } else {
              NSLog(@"Преобразованный JSON в NSDictionary: %@", socketInfoDic);
              resolve(@{
                @"s": @(msg->szStr),
                @"i": @1,
                @"value": socketInfoDic
              });
            }
            
            NSLog(@"Завершение обработки сообщения");
          }
        }
      }
    }
}


@end

