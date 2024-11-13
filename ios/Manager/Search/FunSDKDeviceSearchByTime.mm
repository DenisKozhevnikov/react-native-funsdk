//
//  FunSDKDeviceSearchByTime.m
//  Funsdk
//
//  Created by Денис Кожевников on 03.11.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#define MAX_FINDFILE_SIZE        10000
#import "FunSDKDeviceSearchByTime.h"
#import "FunSDK/FunSDK.h"
#import "FunSDK/Fun_MC.h"
#import <React/RCTLog.h>
#import "NSDate+TimeCategory.h"
#import "TimeInfo.h"

@interface FunSDKDeviceSearchByTime()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;
@property (nonatomic, assign) NSInteger requestCounter;

@end

@implementation FunSDKDeviceSearchByTime

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

- (NSNumber *)generateRequestKeyWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    if (!self.resolvers) {
        self.resolvers = [NSMutableDictionary dictionary];
    }
    
    self.requestCounter++;
    NSNumber *key = @(_requestCounter);
    
    // Сохраняем блоки resolve и reject в маппинг
    self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
    
    return key;
}


#pragma - mark Получение данных о статусе работы тревожных сообщений на устройстве
RCT_EXPORT_METHOD(searchTimeinfo:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *devId = params[@"deviceId"];
  NSDictionary *start = params[@"start"];
  NSDictionary *end = params[@"end"];
  int channelId = [params[@"deviceChannel"] intValue];
  int fileType = [params[@"fileType"] intValue];
  int streamType = [params[@"streamType"] intValue];
  int seq = [params[@"seq"] intValue];
  int timeout = [params[@"timeout"] intValue];

  NSNumber *key = [self generateRequestKeyWithResolver:resolve rejecter:reject];
  
  SDK_SearchByTime info;
  memset(&info, 0, sizeof(info));
  info.nHighChannel = 0;
  info.nLowChannel  = 0;
  info.nFileType  = 0;
  info.iSync  = 0;
  
  SDK_SYSTEM_TIME stBeginTime;
  memset(&stBeginTime, 0, sizeof(stBeginTime));
  stBeginTime.year = [start[@"year"] intValue];
  stBeginTime.month = [start[@"month"] intValue];
  stBeginTime.day = [start[@"day"] intValue];
  stBeginTime.hour = [start[@"hour"] intValue];;
  stBeginTime.minute = [start[@"minute"] intValue];
  stBeginTime.second = [start[@"second"] intValue];
  info.stBeginTime = stBeginTime;
  
  SDK_SYSTEM_TIME stEndTime = {0};
  stEndTime.year = [end[@"year"] intValue];
  stEndTime.month = [end[@"month"] intValue];
  stEndTime.day = [end[@"day"] intValue];
  stEndTime.hour = [end[@"hour"] intValue];
  stEndTime.minute = [end[@"minute"] intValue];
  stEndTime.second = [end[@"second"] intValue];
  info.stEndTime = stEndTime;
  
  if (channelId > 31){
      info.nHighChannel = (1 << (channelId - 32));
  }else{
      info.nLowChannel = (1 << channelId);
  }
  
  FUN_DevFindFileByTime(self.msgHandle, SZSTR(devId), &info, timeout, [key intValue]);
}

#pragma mark - вывод в консоль данных по каждому из каналов
- (void)logSearchByTimeResult:(SDK_SearchByTimeResult)result {
    NSLog(@"Количество записей в канале: %d", result.nInfoNum);
    
    for (int i = 0; i < result.nInfoNum; i++) {
        SDK_SearchByTimeInfo info = result.ByTimeInfo[i];
        NSLog(@"Канал %d - Номер канала: %d", i, info.iChannel);
        
        NSMutableString *bitmapString = [NSMutableString string];
        for (int j = 0; j < 720; j++) {
            [bitmapString appendFormat:@"%02X ", info.cRecordBitMap[j]];
        }
        
        NSLog(@"Канал %d - Полный массив записи:\n%@", i, bitmapString);
    }
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
    case EMSG_DEV_FIND_FILE_BY_TIME:
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
          
        // получение результата
        SDK_SearchByTimeResult *pResult = (SDK_SearchByTimeResult *)msg->pObject;
        // получение количество "результатов"
        int *infoNum = &pResult->nInfoNum;

        
//        [self logSearchByTimeResult:*pResult];
        
        // повторяет выполнение из java
        NSMutableArray *charArray = [NSMutableArray array];
        NSMutableArray *minutesStatusArray = [NSMutableArray array];
        int charsCount = 0;
        int minutesCount = 0;
        
        for (int i = 0; i < *infoNum; i++) {
          SDK_SearchByTimeInfo *info = &pResult->ByTimeInfo[i];
          
          for (int j = 0; j < 720; j++) {
            int recordInfo = info->cRecordBitMap[j];  // Get the byte
            
            // Добавляем в charArray значение byte в целочисленном виде
            [charArray addObject:@(recordInfo)];
            charsCount++;
            
            // Преобразуем recordInfo в двоичный формат и выполняем побитовую операцию "и" с 15 (1111), получая номер статуса
            int firstMinute = recordInfo & 15;  // Применяем побитовую операцию "и" для первой минуты
            [minutesStatusArray addObject:@(firstMinute)];
            minutesCount++;
            
            // Сдвигаем на 4 бита вправо и выполняем побитовую операцию "и" снова для второй минуты
            int secondMinute = (recordInfo >> 4) & 15;  // Сдвигаем и применяем "и" для второй минуты
            [minutesStatusArray addObject:@(secondMinute)];
            minutesCount++;
          }
        }
        
        if (resolve) {
          NSMutableDictionary *resultMap = [NSMutableDictionary dictionary];
          resultMap[@"charList"] = charArray;
          resultMap[@"minutesStatusList"] = minutesStatusArray;
          resultMap[@"charsCount"] = @(charsCount);
          resultMap[@"minutesCount"] = @(minutesCount);
          
          resolve(resultMap);
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
