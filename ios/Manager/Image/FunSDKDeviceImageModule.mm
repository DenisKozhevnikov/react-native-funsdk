//
//  FunSDKDeviceImageModule.mm
//  Pods
//
//  Created by Денис Кожевников on 11.11.2024.
//

#import "FunSDKDeviceImageModule.h"
#import "FunSDK/FunSDK.h"
#import "FunSDK/Fun_MC.h"
#import <React/RCTLog.h>

@interface FunSDKDeviceImageModule()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;
@property (nonatomic, assign) NSInteger requestCounter;

@end

@implementation FunSDKDeviceImageModule

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

- (NSNumber *)generateRequestKeyWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject saveImageDir:(NSString *)mSaveImageDir{
    if (!self.resolvers) {
        self.resolvers = [NSMutableDictionary dictionary];
    }
    
    self.requestCounter++;
    NSNumber *key = @(_requestCounter);
    
    // Сохраняем блоки resolve и reject в маппинг
    self.resolvers[key] = @{@"resolve": resolve, @"reject": reject, @"mSaveImageDir": mSaveImageDir};
    
    return key;
}


#pragma - mark Загрузка одного изображения на устройство
RCT_EXPORT_METHOD(downloadSingleImage:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSNumber *deviceChannel = params[@"deviceChannel"];
  NSString *mSaveImageDir = params[@"mSaveImageDir"];
  NSDictionary *time = params[@"time"];
  
  NSNumber *key = [self generateRequestKeyWithResolver:resolve rejecter:reject saveImageDir:mSaveImageDir];
  
  
  SDK_SYSTEM_TIME nTime;
  memset(&nTime, 0, sizeof(nTime));
  nTime.year = [time[@"year"] intValue];
  nTime.month = [time[@"month"] intValue];
  nTime.day = [time[@"day"] intValue];
  nTime.hour = [time[@"hour"] intValue];;
  nTime.minute = [time[@"minute"] intValue];
  nTime.second = [time[@"second"] intValue];
  
  time_t ToTime_t(SDK_SYSTEM_TIME *time);
  
  FUN_DownloadRecordBImage(self.msgHandle, CSTR(deviceId), [deviceChannel intValue], (int)ToTime_t(&nTime), CSTR(mSaveImageDir), 0, [key intValue]);
}

#pragma - mark Загрузка видео на устройство по имени файла
RCT_EXPORT_METHOD(downloadSingleFile:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSNumber *deviceChannel = params[@"deviceChannel"];
  NSString *mSaveImageDir = params[@"mSaveImageDir"];
  NSDictionary *start = params[@"startTime"];
  NSDictionary *end = params[@"endTime"];
  NSString *fileName = params[@"fileName"];
  
  NSNumber *key = [self generateRequestKeyWithResolver:resolve rejecter:reject saveImageDir:mSaveImageDir];
  
  // Информация о файле
  H264_DVR_FILE_DATA info;
  memset(&info, 0, sizeof(info));
  
  SDK_SYSTEM_TIME stBeginTime;
  memset(&stBeginTime, 0, sizeof(stBeginTime));
  stBeginTime.year = [start[@"year"] intValue];
  stBeginTime.month = [start[@"month"] intValue];
  stBeginTime.day = [start[@"day"] intValue];
  stBeginTime.hour = [start[@"hour"] intValue];;
  stBeginTime.minute = [start[@"minute"] intValue];
  stBeginTime.second = [start[@"second"] intValue];
  // Начало
  info.stBeginTime = stBeginTime;
  
  SDK_SYSTEM_TIME stEndTime = {0};
  stEndTime.year = [end[@"year"] intValue];
  stEndTime.month = [end[@"month"] intValue];
  stEndTime.day = [end[@"day"] intValue];
  stEndTime.hour = [end[@"hour"] intValue];
  stEndTime.minute = [end[@"minute"] intValue];
  stEndTime.second = [end[@"second"] intValue];
  // Окончание
  info.stEndTime = stEndTime;
  
  // Имя файла
  strncpy(info.sFileName, [fileName UTF8String], sizeof(info.sFileName));
  
  // Номер канала
  info.ch = [deviceChannel intValue];
  
//  FUN_HANDLE FUN_DevDowonLoadByFile(UI_HANDLE hUser, const char *szDevId, H264_DVR_FILE_DATA *pH264_DVR_FILE_DATA, const char *szFileName, int nSeq = 0);
  FUN_DevDowonLoadByFile(self.msgHandle,CSTR(deviceId), &info,  CSTR(mSaveImageDir), [key intValue]);
}


#pragma - mark Загрузка видео на устройство по выбранному времени
RCT_EXPORT_METHOD(downloadSingleFileByTime:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  NSNumber *deviceChannel = params[@"deviceChannel"];
  NSString *mSaveImageDir = params[@"mSaveImageDir"];
  NSDictionary *start = params[@"startTime"];
  NSDictionary *end = params[@"endTime"];
  NSNumber *streamType = params[@"streamType"];
  NSNumber *fileType = params[@"fileType"];

 NSNumber *key = [self generateRequestKeyWithResolver:resolve rejecter:reject saveImageDir:mSaveImageDir];

  // // Информация о файле
  H264_DVR_FINDINFO info;
  memset(&info, 0, sizeof(info));

  H264_DVR_TIME startTime;
  memset(&startTime, 0, sizeof(startTime));
  startTime.dwYear = [start[@"year"] intValue];
  startTime.dwMonth = [start[@"month"] intValue];
  startTime.dwDay = [start[@"day"] intValue];
  startTime.dwHour = [start[@"hour"] intValue];;
  startTime.dwMinute = [start[@"minute"] intValue];
  startTime.dwSecond = [start[@"second"] intValue];
  // Начало
  info.startTime = startTime;
  
  H264_DVR_TIME endTime = {0};
  endTime.dwYear = [end[@"year"] intValue];
  endTime.dwMonth = [end[@"month"] intValue];
  endTime.dwDay = [end[@"day"] intValue];
  endTime.dwHour = [end[@"hour"] intValue];
  endTime.dwMinute = [end[@"minute"] intValue];
  endTime.dwSecond = [end[@"second"] intValue];
  // Окончание
  info.endTime = endTime;
  
  // тип качества 0 (основной) или 1 (вспомогательный)
  info.StreamType = [streamType intValue];
  
  // тип файла
  info.nFileType = [fileType intValue];
  
  // // Имя файла
  // strncpy(info.sFileName, [fileName UTF8String], sizeof(info.sFileName));
  
  // // Номер канала
  info.nChannelN0 = [deviceChannel intValue];
  
  //  FUN_HANDLE FUN_DevDowonLoadByTime(
  //      UI_HANDLE hUser,
  //      const char*szDevId,
  //      H264_DVR_FINDINFO *pH264_DVR_FINDINFO,
  //      const char *szFileName,
  //      int nSeq = 0
  //  );
  FUN_DevDowonLoadByTime(self.msgHandle, CSTR(deviceId), &info,  CSTR(mSaveImageDir), [key intValue]);
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
    case EMSG_DOWN_RECODE_BPIC_START:
      break;
    case EMSG_DOWN_RECODE_BPIC_FILE:
      break;
    case EMSG_DOWN_RECODE_BPIC_COMPLETE:
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
          reject(@"EMSG_DOWN_RECODE_BPIC_COMPLETE_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
        }
      } else{
        // success result
        if (resolve) {
          NSMutableDictionary *resultMap = [NSMutableDictionary dictionary];

          resultMap[@"isSuccess"] = @(true);
          resultMap[@"imagePath"] = callbacks[@"mSaveImageDir"];
          resultMap[@"seq"] = @(msg->seq);
          
          resolve(resultMap);
        }
      }
      
      [self.resolvers removeObjectForKey:key];

    }
      break;
    case EMSG_ON_FILE_DOWNLOAD:
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
          reject(@"EMSG_ON_FILE_DLD_COMPLETE_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
        }
        
        [self.resolvers removeObjectForKey:key];
      }
    }
      break;
    case EMSG_ON_FILE_DLD_POS:
      break;
    case EMSG_ON_FILE_DLD_COMPLETE:
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
          reject(@"EMSG_ON_FILE_DLD_COMPLETE_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
        }
      } else{
        // success result
        if (resolve) {
          NSMutableDictionary *resultMap = [NSMutableDictionary dictionary];

          resultMap[@"isSuccess"] = @(true);
          resultMap[@"filePath"] = callbacks[@"mSaveImageDir"];
          resultMap[@"seq"] = @(msg->seq);
          
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
