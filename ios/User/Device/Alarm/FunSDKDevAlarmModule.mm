//
//  FunSDKDevAlarmModule.m
//  react-native-funsdk
//
//  Created by Денис Кожевников on 15.09.2024.
//

#import "FunSDKDevAlarmModule.h"
#import "FunSDK/FunSDK.h"
#import "FunSDK/Fun_MC.h"
#import <React/RCTLog.h>
#import "AlarmMessageInfo.h"

@interface FunSDKDevAlarmModule()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;
@property (nonatomic, assign) NSInteger requestCounter;

@end

@implementation FunSDKDevAlarmModule

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

#pragma - mark Инициализация сервера тревожных сообщений
RCT_EXPORT_METHOD(initAlarmServer:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *username = params[@"username"];
  NSString *password = params[@"password"];
  NSNumber *language = params[@"language"];
  NSString *token = params[@"token"];
  NSString *pushType = params[@"pushType"];
  NSString *pushThirdServerURL = params[@"pushThirdServerURL"];
  
  
  SMCInitInfo info = {0};
  info.appType = [pushType intValue];
  STRNCPY(info.token, [token UTF8String]);
  strcpy(info.user, [username UTF8String]);
  strcpy(info.password, [password UTF8String]);
  info.language = [language intValue];
  
  NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
  NSString *bundleIdentifiler = [infoDictionary objectForKey:@"CFBundleIdentifier"];

  STRNCPY(info.szAppType, [bundleIdentifiler UTF8String]);
  
  if (pushThirdServerURL) {
      strcpy(info.szAppType, [pushThirdServerURL UTF8String]);
  }
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_Init(self.msgHandle, &info, 0);
}

#pragma - mark Подписка на тревожные сообщения
RCT_EXPORT_METHOD(linkAlarm:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSString *deviceLogin = params[@"deviceLogin"];
  NSString *devicePassword = params[@"devicePassword"];
  
  const NSString *deviceName = NULL;
  
  if (params[@"deviceName"]) {
    deviceName = params[@"deviceName"];
  }
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  
  MC_LinkDev(self.msgHandle, SZSTR(deviceId), SZSTR(deviceLogin), SZSTR(devicePassword), [key intValue], SZSTR(deviceName));
}

#pragma - mark Отписка от тревожных сообщений
RCT_EXPORT_METHOD(unlinkAlarm:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
    
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_UnlinkDev(self.msgHandle, SZSTR(deviceId), [key intValue]);
}


#pragma - mark Поиск тревожных сообщений
RCT_EXPORT_METHOD(searchAlarmMsgByTime:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *deviceId = params[@"deviceId"];
    NSNumber *channelId = params[@"deviceChannel"];
    NSNumber *alarmType = params[@"alarmType"];
    NSNumber *startTime = params[@"startTime"];
    NSNumber *endTime = params[@"endTime"];
    
    if (!self.resolvers) {
        self.resolvers = [NSMutableDictionary dictionary];
    }
    
    self.requestCounter++;
    NSNumber *key = @(_requestCounter);
    
    // Сохраняем блоки resolve и reject в маппинг
    self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
    
    
    XPMS_SEARCH_ALARMINFO_REQ alarmInfo = {0};
    strcpy(alarmInfo.Uuid, SZSTR(deviceId));
    alarmInfo.Channel = [channelId intValue];
    alarmInfo.Number = -1;
    alarmInfo.Index = 0;
    if (alarmType != nil) {
        alarmInfo.AlarmType = [alarmType intValue];
    }
    
    if (startTime != nil && endTime != nil) {
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[startTime doubleValue] / 1000];
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[endTime doubleValue] / 1000];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *startCompt = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:startDate];
        NSDateComponents *endCompt = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:endDate];
        
        alarmInfo.StarTime.year = (int)startCompt.year;
        alarmInfo.StarTime.month = (int)startCompt.month;
        alarmInfo.StarTime.day = (int)startCompt.day;
        alarmInfo.StarTime.hour = (int)startCompt.hour;
        alarmInfo.StarTime.minute = (int)startCompt.minute;
        alarmInfo.StarTime.second = (int)startCompt.second;
        
        alarmInfo.EndTime.year = (int)endCompt.year;
        alarmInfo.EndTime.month = (int)endCompt.month;
        alarmInfo.EndTime.day = (int)endCompt.day;
        alarmInfo.EndTime.hour = (int)endCompt.hour;
        alarmInfo.EndTime.minute = (int)endCompt.minute;
        alarmInfo.EndTime.second = (int)endCompt.second;
      
        NSLog(@"(int)startCompt.year: %d", (int)startCompt.year);
        NSLog(@"(int)startCompt.month: %d", (int)startCompt.month);
        NSLog(@"(int)startCompt.day: %d", (int)startCompt.day);
        NSLog(@"(int)startCompt.hour: %d", (int)startCompt.hour);
      
        NSLog(@"(int)endCompt.year: %d", (int)endCompt.year);
        NSLog(@"(int)endCompt.month: %d", (int)endCompt.month);
        NSLog(@"(int)endCompt.day: %d", (int)endCompt.day);
        NSLog(@"(int)endCompt.hour: %d", (int)endCompt.hour);
    }
    
    MC_SearchAlarmInfoByTime(self.msgHandle, &alarmInfo, [key intValue]);
}

#pragma - mark Удаление тревожного сообщения
RCT_EXPORT_METHOD(deleteOneAlarmInfo:(NSDictionary *)params
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
    NSString *deleteType = params[@"deleteType"];
    NSString *alarmID = params[@"alarmID"];

    MC_Delete(self.msgHandle, CSTR(deviceId), [deleteType UTF8String], CSTR(alarmID), [key intValue]);
}

#pragma - mark Удаление всех тревожных сообщений
RCT_EXPORT_METHOD(deleteAllAlarmMsg:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    // TODO: add
//    if (!self.resolvers) {
//        self.resolvers = [NSMutableDictionary dictionary];
//    }
}

// 设备协议常用命令ID
//  typedef enum EDEV_PTL_CMD
//  {
//      EDEV_PTL_CONFIG_GET_JSON = 1042, - команда получения данных
//      EDEV_PTL_CONFIG_SET_JSON = 1040, - команда сохранения данных
//  }EDEV_PTL_CMD;

// Получение данных о том включены ли пуши или нет
//  FUN_DevCmdGeneral(self.msgHandle, [deviceId UTF8String], 1042, "NetWork.PMS", 0, 5000, NULL, 0, -1, 2222);
//
// включение/отключение пушей на камере
//  const int pushInterval = 10;
//  char szCfg[512] = {0};
//  sprintf(szCfg, "{ \"Name\":\"NetWork.PMS\",\"NetWork.PMS\" : {\"Enable\" : false, \"ServName\":\"push.umeye.cn\",\"Port\":80,\"BoxID\":\"\",\"PushInterval\":%d}}", pushInterval);
//  NSLog(@"%s", szCfg);
//  FUN_DevCmdGeneral(self.msgHandle, [deviceId UTF8String], 1040, "NetWork.PMS", 0, 5000, szCfg, (int)strlen(szCfg)+1, -1, 1111);

#pragma - mark Получение данных о статусе работы тревожных сообщений на устройстве
RCT_EXPORT_METHOD(getAlarmState:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];

  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  FUN_DevCmdGeneral(self.msgHandle, [deviceId UTF8String], 1042, "NetWork.PMS", 0, 5000, NULL, 0, -1, [key intValue]);
}

#pragma - mark Изменение работы тревожных сообщений на устройстве
RCT_EXPORT_METHOD(setAlarmState:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  BOOL isAlertEnabled = [params[@"isAlertEnabled"] boolValue];
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  const int pushInterval = 10;
  const char *enablingAlert = isAlertEnabled ? "true" : "false";
  char szCfg[512] = {0};
  
  sprintf(szCfg, "{ \"Name\":\"NetWork.PMS\",\"NetWork.PMS\" : {\"Enable\" : %s, \"ServName\":\"push.umeye.cn\",\"Port\":80,\"BoxID\":\"\",\"PushInterval\":%d}}", enablingAlert, pushInterval);
  
  FUN_DevCmdGeneral(self.msgHandle, [deviceId UTF8String], 1040, "NetWork.PMS", 0, 5000, szCfg, (int)strlen(szCfg)+1, -1, [key intValue]);
}


#pragma mark - Получение результатов OnFunSDKResult
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
        case EMSG_MC_SearchAlarmInfo:{
          NSNumber *key = @(msg->seq);
          NSDictionary *callbacks = self.resolvers[key];
          
          RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
          RCTPromiseRejectBlock reject = callbacks[@"reject"];
          
          if (msg->param1 < 0) {
            // error
            if (reject) {
              NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
              reject(@"EMSG_MC_SearchAlarmInfo_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
            }
          } else {
            // success result
            char *pStr = (char *)msg->pObject;
            NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:0];
            // msg->param3 - количество найденных элементов
            for (int i = 0; i < msg->param3; ++i) {
              NSData *data = [[[NSString alloc]initWithUTF8String:pStr] dataUsingEncoding:NSUTF8StringEncoding];
              AlarmMessageInfo *json = [[AlarmMessageInfo alloc]init];
              [json parseJsonData:data];
              NSString *startTime = [json getStartTime]; //开始时间
              if (startTime) {
                [dataArray addObject:json];
              }
              
              pStr += (strlen(pStr) + 1);
            }
            
            
            NSMutableArray *resultArray = [NSMutableArray array];
            for (AlarmMessageInfo *info in dataArray) {
              NSDictionary *jsonInfo = [info getDicinfoSelf];
              if (jsonInfo) {
                [resultArray addObject:jsonInfo];
              }
            }
          
            if (resolve) {
              resolve(resultArray);
            }
          }
          
          [self.resolvers removeObjectForKey:key];
        }
            break;
        case EMSG_MC_DeleteAlarm:
        {
          NSNumber *key = @(msg->seq);
          NSDictionary *callbacks = self.resolvers[key];
          
          RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
          RCTPromiseRejectBlock reject = callbacks[@"reject"];
          
          int result = msg->param1;
          if (result < 0) {
            // error
            if (reject) {
              NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
              reject(@"EMSG_MC_DeleteAlarm_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
            }
          } else{
            // success result
            if (resolve) {
              resolve(@{
                @"s": @(msg->szStr),
                @"i": @1,
                @"value": @"success"
              });
            }
          }
          [self.resolvers removeObjectForKey:key];

        }
            break;
        case EMSG_MC_LinkDev:
        {
          NSNumber *key = @(msg->seq);
          NSDictionary *callbacks = self.resolvers[key];
          
          RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
          RCTPromiseRejectBlock reject = callbacks[@"reject"];
        
          int result = msg->param1;
          if (result < 0) {
            // error
            if (reject) {
              NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
              reject(@"linkDeviceAlarm_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
            }
          } else{
            // success result
            if (resolve) {
              resolve(@{
                @"s": @(msg->szStr),
                @"i": @1,
              });
            }
          }
          
          [self.resolvers removeObjectForKey:key];

        }
          break;
        case EMSG_MC_UnlinkDev:
        {
          NSNumber *key = @(msg->seq);
          NSDictionary *callbacks = self.resolvers[key];
          
          RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
          RCTPromiseRejectBlock reject = callbacks[@"reject"];
          
          int result = msg->param1;
          if (result < 0) {
            // error
            if (reject) {
              NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
              reject(@"unlinkDeviceAlarm_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
            }
          } else{
            // success result
            if (resolve) {
              resolve(@{
                @"s": @(msg->szStr),
                @"i": @1,
              });
            }
          }
          
          [self.resolvers removeObjectForKey:key];
          
        }
          break;
      case EMSG_MC_INIT_INFO:
        {
          NSNumber *key = @(msg->seq);
          NSDictionary *callbacks = self.resolvers[key];
          
          RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
          RCTPromiseRejectBlock reject = callbacks[@"reject"];
          
          int result = msg->param1;
          if (result < 0) {
            // error
            if (reject) {
              NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
              reject(@"unlinkDeviceAlarm_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
            }
          } else{
            // success result
            if (resolve) {
              resolve(@{
                @"s": @(msg->szStr),
                @"i": @1,
              });
            }
          }
          
          [self.resolvers removeObjectForKey:key];

        }
          break;
      case EMSG_DEV_CMD_EN:
        {
          NSNumber *key = @(msg->seq);
          NSDictionary *callbacks = self.resolvers[key];
          
          RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
          RCTPromiseRejectBlock reject = callbacks[@"reject"];
          
          int result = msg->param1;
          if (result < 0) {
            // error
            if (reject) {
              NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
              reject(@"EMSG_DEV_CMD_EN_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
            }
          } else{
            // success result
            if (resolve) {
              NSString *pObjectString = [NSString stringWithUTF8String:msg->pObject];
                            
              // Попытка преобразовать строку в JSON объект
              NSData *jsonData = [pObjectString dataUsingEncoding:NSUTF8StringEncoding];
              NSError *error = nil;
              NSDictionary *pObjectDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
              
              NSLog(@"NSError: %@", error);
              NSLog(@"pObjectDict: %@", pObjectDict);
              
              if (error || !pObjectDict) {
                  resolve(@{
                    @"s": @(msg->szStr),
                    @"i": @1,
                    @"value": pObjectString ?: @""
                  });
                } else {
                  resolve(@{
                    @"s": @(msg->szStr),
                    @"i": @1,
                    @"value": pObjectDict
                  });
                }
            }
          }
          
          [self.resolvers removeObjectForKey:key];

        }
          break;
        default:
            break;
    }
}

@end
