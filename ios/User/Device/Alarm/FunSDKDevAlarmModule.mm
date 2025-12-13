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
  NSString *szAppType = params[@"szAppType"];
  
  SMCInitInfo info = {0};
  info.appType = [pushType intValue];
  STRNCPY(info.token, [token UTF8String]);
  strcpy(info.user, [username UTF8String]);
  strcpy(info.password, [password UTF8String]);
  info.language = [language intValue];
  
  NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
  NSString *bundleIdentifiler = [infoDictionary objectForKey:@"CFBundleIdentifier"];

  STRNCPY(info.szAppType, [bundleIdentifiler UTF8String]);
  
  if (szAppType) {
      strcpy(info.szAppType, [szAppType UTF8String]);
  }
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_Init(self.msgHandle, &info, [key intValue]);
}

#pragma - mark Инициализация сервера тревожных сообщений V2
RCT_EXPORT_METHOD(initAlarmServerV2:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *username = params[@"username"];
  NSString *password = params[@"password"];
  NSString *userID = params[@"userID"];
  NSNumber *language = params[@"language"];
  NSString *token = params[@"token"];
  NSString *pushType = params[@"pushType"];
  NSString *szAppType = params[@"szAppType"];

  SMCInitInfoV2 info = {0};
  info.appType = [pushType intValue];
  STRNCPY(info.token, [token UTF8String]);
  STRNCPY(info.user, [username UTF8String]);
  STRNCPY(info.password, [password UTF8String]);
  STRNCPY(info.userID, [userID UTF8String]);
  info.language = [language intValue];

  if (szAppType) {
      STRNCPY(info.szAppType, [szAppType UTF8String]);
  }

  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }

  self.requestCounter++;
  NSNumber *key = @(self.requestCounter);
    self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};

  MC_InitV2(self.msgHandle, &info, [key intValue]);
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

#pragma - mark Подписка на тревожные сообщения
RCT_EXPORT_METHOD(linkDevGeneral:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *devId = params[@"deviceId"];
  NSString *devName = params[@"deviceName"] ?: @"";
  NSString *voice = params[@"voice"] ?: @"";
  NSString *devUserName = params[@"devUserName"] ?: @"";
  NSString *devUserPwd = params[@"devUserPwd"] ?: @"";
  NSString *appToken = params[@"appToken"] ?: @"";
  NSString *appType = params[@"appType"] ?: @"";

  self.requestCounter++;
  NSNumber *key = @(self.requestCounter);
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};

  MC_LinkDevGeneral(self.msgHandle, [devId UTF8String], [devName UTF8String], [voice UTF8String], [devUserName UTF8String], [devUserPwd UTF8String], [appToken UTF8String], [appType UTF8String], [key intValue]);
}

#pragma - mark Подписка на тревожные сообщения для нескольких устройств
RCT_EXPORT_METHOD(linkDevsBatch:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *devIDs = params[@"deviceIds"];
  NSString *sDevName = params[@"devName"] ?: @"";
  NSString *voice = params[@"voice"] ?: @"";
  NSString *devUserName = params[@"devUserName"] ?: @"";
  NSString *devUserPwd = params[@"devUserPwd"] ?: @"";
  NSString *appToken = params[@"appToken"] ?: @"";
  NSString *appType = params[@"appType"] ?: @"";

  self.requestCounter++;
  NSNumber *key = @(self.requestCounter);
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject };

  MC_LinkDevsBatch(self.msgHandle, [devIDs UTF8String], [sDevName UTF8String], [voice UTF8String], [devUserName UTF8String], [devUserPwd UTF8String], [appToken UTF8String], [appType UTF8String], [key intValue]);
}

#pragma - mark Подписка на тревожные сообщения
RCT_EXPORT_METHOD(devAlarmSubscribe:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *devId = params[@"deviceId"];
  NSString *devName = params[@"deviceName"] ?: @"";
  NSString *rules = params[@"rules"] ?: @"";
  NSString *voice = params[@"voice"] ?: @"";
  NSString *appToken = params[@"appToken"] ?: @"";
  NSString *appType = params[@"appType"] ?: @"";

  self.requestCounter++;
  NSNumber *key = @(self.requestCounter);
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};

  MC_DevAlarmSubscribe(self.msgHandle, [devId UTF8String], [devName UTF8String], [rules UTF8String], [voice UTF8String], [appToken UTF8String], [appType UTF8String], [key intValue]);
}

#pragma - mark Подписка на тревожные сообщения для нескольких устройств
RCT_EXPORT_METHOD(devAlarmSubscribeBatch:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *szDevSNs = params[@"deviceIds"];
  NSString *szDevName = params[@"deviceName"] ?: @"";
  NSString *szRules = params[@"rules"] ?: @"";
  NSString *szVoice = params[@"voice"] ?: @"";
  NSString *szAppToken = params[@"appToken"] ?: @"";
  NSString *szAppType = params[@"appType"] ?: @"";

  self.requestCounter++;
  NSNumber *key = @(self.requestCounter);
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};

  MC_BatchDevAlarmSubscribe(self.msgHandle, [szDevSNs UTF8String], [szDevName UTF8String], [szRules UTF8String], [szVoice UTF8String], [szAppToken UTF8String], [szAppType UTF8String], [key intValue]);
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


#pragma - mark Отписка от тревожных сообщений
RCT_EXPORT_METHOD(unlinkDevGeneral:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSString *sAppToken = params[@"appToken"];
  NSString *nFlag = params[@"flag"];
    
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_UnlinkDevGeneral(self.msgHandle, SZSTR(deviceId), SZSTR(sAppToken), [nFlag intValue], [key intValue]);
}


#pragma - mark Отменить подписку на сигналы тревоги для всех учетных записей на устройстве
RCT_EXPORT_METHOD(unlinkAllAccountsOfDev:(NSDictionary *)params
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
  
  MC_UnlinkAllAccountsOfDev(self.msgHandle, SZSTR(deviceId), [key intValue]);
}

#pragma - mark Отписка от тревожных сообщений для нескольких устройств
RCT_EXPORT_METHOD(unlinkDevsBatch:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSString *sAppToken = params[@"appToken"];
  NSString *nFlag = params[@"flag"];
    
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_UnLinkDevsBatch(self.msgHandle, SZSTR(deviceId), SZSTR(sAppToken), [nFlag intValue], [key intValue]);
}

#pragma - mark Верхний уровень получает сообщение об аномальной подписке на сигналы тревоги, например, о сигнале тревоги устройства, которого нет в списке устройств, и отменяет подписку
RCT_EXPORT_METHOD(unlinkDevAbnormal:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSString *sAppToken = params[@"appToken"];
    
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_UnlinkDevAbnormal(self.msgHandle, SZSTR(deviceId), SZSTR(sAppToken), [key intValue]);
}


#pragma - mark Получите статус подписки на сигналы тревоги устройства со стороны сервера через тип подписки
RCT_EXPORT_METHOD(getDevAlarmSubStatusByType:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceIds"];
  NSString *sAppToken = params[@"appToken"];
    
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_GetDevAlarmSubStatusByType(self.msgHandle, SZSTR(deviceId), SZSTR(sAppToken), [key intValue]);
}

#pragma - mark Получить статус подписки на сигнализацию устройства с сервера через ТОКЕН.
RCT_EXPORT_METHOD(getDevAlarmSubStatusByToken:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSString *sAppToken = params[@"appTokens"];
    
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_GetDevAlarmSubStatusByToken(self.msgHandle, SZSTR(deviceId), SZSTR(sAppToken), [key intValue]);
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

#pragma - mark Поиск alarm изображения.
RCT_EXPORT_METHOD(searchAlarmPic:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSString *fileName = params[@"fileName"];
  NSString *uId = params[@"uId"];
  NSString *res = params[@"res"];
  
  XPMS_SEARCH_ALARMPIC_REQ _req;
  memset(&_req, 0, sizeof(_req));
  STRNCPY(_req.Uuid, SZSTR(deviceId));
  _req.ID = [uId longLongValue];
  
  if (res) {
    if (res && [res length] >= sizeof(_req.Res)) {
      reject(@"MC_SearchAlarmPic_error", @"Parameter 'res' is too long (max 31 characters)", [NSError errorWithDomain:@"FunSDK" code:EMSG_MC_SearchAlarmPic userInfo:nil]);
      return;
    }
    memcpy(_req.Res, SZSTR(res), 32);
  }
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_SearchAlarmPic(self.msgHandle, SZSTR(fileName), &_req, [key intValue]);
}

#pragma - mark Загрузка alarm изображения.
RCT_EXPORT_METHOD(downloadAlarmImage:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSString *path = params[@"path"];
  NSString *picInfo = params[@"picInfoJSONstring"];
  NSNumber *width = params[@"width"];
  NSNumber *height = params[@"height"];
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_DownloadAlarmImage(self.msgHandle, SZSTR(deviceId),  SZSTR(path), SZSTR(picInfo), [width intValue], [height intValue], [key intValue]);
}


#pragma - mark Отмена загрузки изображений (также для MC_SearchAlarmPic и MC_DownloadAlarmImage)
RCT_EXPORT_METHOD(stopDownloadAlarmImages:(NSDictionary *)params
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
  
  MC_StopDownloadAlarmImages(self.msgHandle, [key intValue]);
  
  resolve(@{
    @"s": @(""),
    @"i": @1,
  });
}

#pragma - mark Получить дату изображения облака текущего месяца
RCT_EXPORT_METHOD(searchAlarmByMoth:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSNumber *channelId = params[@"deviceChannel"];
  NSString *streamType = params[@"streamType"];
  NSDictionary *date = params[@"date"];
  
  SDK_SYSTEM_TIME nTime;
  nTime.year = [date[@"year"] intValue];
  nTime.month = [date[@"month"] intValue];
  nTime.day = [date[@"day"] intValue];
  nTime.hour = [date[@"hour"] intValue];
  nTime.minute = [date[@"minute"] intValue];
  nTime.second = [date[@"second"] intValue];
  time_t ToTime_t(SDK_SYSTEM_TIME *time);
  int time =(int)ToTime_t(&nTime);
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_SearchAlarmByMoth(self.msgHandle, SZSTR(deviceId), [channelId intValue], SZSTR(streamType), time, [key intValue]);
}


#pragma - mark Получить дату изображения облака текущего месяца
RCT_EXPORT_METHOD(searchAlarmLastTimeByType:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSNumber *channelId = params[@"deviceChannel"];
  NSString *streamType = params[@"streamType"];
  NSString *alarmType = params[@"alarmType"];
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_SearchAlarmLastTimeByType(self.msgHandle, SZSTR(deviceId), SZSTR(streamType), SZSTR(alarmType), [channelId intValue], [key intValue]);
}


#pragma - mark Запрос истории состояния устройства
RCT_EXPORT_METHOD(queryDevsStatusHistoryRecord:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSNumber *startTime = params[@"startTime"];
  NSNumber *endTime = params[@"endTime"];
  NSNumber *queryCount = params[@"queryCount"];
  NSNumber *sortType = params[@"sortType"];
  
  SQueryDevHistoryParams queryParams;
  queryParams.nStartTime = startTime ? [startTime intValue] : 0;
  queryParams.nEndTime = endTime ? [endTime intValue] : 0;
  queryParams.nQueryCount = queryCount ? [queryCount intValue] : 500;
  queryParams.nSortType = sortType ? (ESortType)[sortType intValue] : E_SORT_TYPE_REVERSE_ORDER;
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_QueryDevsStatusHistoryRecord(self.msgHandle, SZSTR(deviceId), &queryParams, [key intValue]);
}

#pragma - mark Подписка на тревожные сообщения по user id
RCT_EXPORT_METHOD(alarmLinkByUserID:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *szUserID = params[@"userId"];
  NSString *szVoice = params[@"voice"];
  NSString *szAppToken = params[@"appToken"];
  NSString *szAppType = params[@"appType"];
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(_requestCounter);
  
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_LinkByUserID(self.msgHandle, SZSTR(szUserID), SZSTR(szVoice), SZSTR(szAppToken), SZSTR(szAppType), [key intValue]);
}

#pragma mark - Установка флага "прочитано" для сообщений тревоги
RCT_EXPORT_METHOD(setAlarmMsgReadFlag:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSString *alarmIds = params[@"alarmIds"];
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(self.requestCounter);
  
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_SetAlarmMsgReadFlag(self.msgHandle, SZSTR(deviceId), SZSTR(alarmIds), [key intValue]);
}


#pragma mark - Установка флага "прочитано" для сообщений тревоги
RCT_EXPORT_METHOD(batchDevAlarmMsgQuery:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceIds = params[@"deviceIds"];
  int startTime = [params[@"startTime"] intValue];
  int endTime = [params[@"endTime"] intValue];
  int channel = [params[@"deviceChannel"] intValue];
  int maxNumber = [params[@"maxNumber"] intValue];
  int pageIndex = [params[@"pageIndex"] intValue];
  NSString *alarmType = params[@"alarmType"];
  
  const char *szDevSNs = [deviceIds UTF8String];
  
  SBatchDevAlarmMsgQueryReqParams queryParams;
  memset(&queryParams, 0, sizeof(queryParams));
  queryParams.nStartTime = startTime;
  queryParams.nEndTime = endTime;
  queryParams.nChannel = channel;
  queryParams.nMaxNumber = maxNumber > 0 ? maxNumber : 300;
  queryParams.nPageIndex = pageIndex > 0 ? pageIndex : 1;
  
  if (alarmType) {
    strncpy(queryParams.szAlarmType, [alarmType UTF8String], sizeof(queryParams.szAlarmType));
  }
  
  memset(queryParams.Res, 0, sizeof(queryParams.Res));
  
  if (!self.resolvers) {
      self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(self.requestCounter);
  
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_BatchDevAlarmMsgQuery(self.msgHandle, szDevSNs, &queryParams, "", [key intValue]);
}

#pragma mark - Запрос сообщений тревоги для одного устройства
RCT_EXPORT_METHOD(devAlarmMsgQuery:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSString *alarmType = params[@"alarmType"];
  int startTime = [params[@"startTime"] intValue];
  int endTime = [params[@"endTime"] intValue];
  int channel = [params[@"deviceChannel"] intValue];
  int pageNum = [params[@"pageNum"] intValue];
  int pageSize = [params[@"pageSize"] intValue];

  const char *szDevID = [deviceId UTF8String];

  SDevAlarmMsgQueryReqParams queryParams;
  memset(&queryParams, 0, sizeof(queryParams));
  strncpy(queryParams.szDevID, szDevID, sizeof(queryParams.szDevID) - 1);
  strncpy(queryParams.szAlarmType, [alarmType UTF8String], sizeof(queryParams.szAlarmType) - 1);
  queryParams.nStartTime = startTime;
  queryParams.nEndTime = endTime;
  queryParams.nChannel = channel;
  queryParams.nPageNum = pageNum > 0 ? pageNum : 1;
  queryParams.nPageSize = (pageSize > 0 && pageSize <= 20) ? pageSize : 20;

  memset(queryParams.Res, 0, sizeof(queryParams.Res));

  if (!self.resolvers) {
    self.resolvers = [NSMutableDictionary dictionary];
  }
  
  self.requestCounter++;
  NSNumber *key = @(self.requestCounter);
  
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  MC_DevAlarmMsgQuery(self.msgHandle, &queryParams, "", [key intValue]);
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
      case EMSG_MC_ON_AlarmCb:
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
            reject(@"MC_LinkDevGeneral_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
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
      case EMSG_MC_LinkDevs_Batch:
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
            reject(@"MC_LinkDevsBatch_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
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
      case EMSG_MC_UnLinkDevs_Batch:
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
            reject(@"MC_UnLinkDevsBatch_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
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
      case EMSG_MC_GET_DEV_ALARM_SUB_STATUS_BY_TYPE:
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
              reject(@"MC_GetDevAlarmSubStatusByType_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
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
      case EMSG_MC_GET_DEV_ALARM_SUB_STATUS_BY_TOKEN:
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
              reject(@"MC_GetDevAlarmSubStatusByToken_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
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
      case EMSG_MC_SearchAlarmPic:
      case 4116: // EMSG_MC_SearchAlarmPicV2
      case EMSG_MC_SearchAlarmByMoth:
      case EMSG_MC_SearchAlarmLastTimeByType:
      case EMSG_MC_LINK_BY_USERID:
      case EMSG_MC_SET_ALARM_MSG_READ_FLAG:
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
              reject(@"error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
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
      case EMSG_MC_QUERY_DEVS_STATUS_HISTORY_RECORD:
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
              reject(@"MC_QueryDevsStatusHistoryRecord_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
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
      case EMSG_MC_BATCH_DEV_ALARM_MSG_QUERY:
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
              reject(@"EMSG_MC_BATCH_DEV_ALARM_MSG_QUERY_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
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
                    @"s": @{
                      @"str": @(msg->szStr),
                      @"param2": @(msg->param2),
                      @"param3": @(msg->param3),
                    },
                    @"i": @1,
                    @"value": pObjectString ?: @""
                  });
                } else {
                  resolve(@{
                    @"s": @{
                      @"str": @(msg->szStr),
                      @"param2": @(msg->param2),
                      @"param3": @(msg->param3),
                    },
                    @"i": @1,
                    @"value": pObjectDict
                  });
                }
            }
          }
          
          [self.resolvers removeObjectForKey:key];

        }
          break;
      case EMSG_MC_DEV_ALARM_MSG_QUERY:
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
              reject(@"EMSG_MC_DEV_ALARM_MSG_QUERY_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
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
                    @"s": @{
                      @"str": @(msg->szStr),
                      @"param2": @(msg->param2),
                      @"param3": @(msg->param3),
                    },
                    @"i": @1,
                    @"value": pObjectString ?: @""
                  });
                } else {
                  resolve(@{
                    @"s": @{
                      @"str": @(msg->szStr),
                      @"param2": @(msg->param2),
                      @"param3": @(msg->param3),
                    },
                    @"i": @1,
                    @"value": pObjectDict
                  });
                }
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
                reject(@"default_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
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
    }
}

@end
