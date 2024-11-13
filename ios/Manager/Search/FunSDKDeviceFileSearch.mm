//
//  FunSDKDeviceFileSearch.mm
//  Pods
//
//  Created by Денис Кожевников on 10.11.2024.
//

#import "FunSDK/FunSDK.h"
#import "FunSDKDeviceFileSearch.h"
#import "NSDate+TimeCategory.h"
#import <React/RCTLog.h>


@interface FunSDKDeviceFileSearch ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;
@property (nonatomic, assign) NSInteger requestCounter;

@end

@implementation FunSDKDeviceFileSearch

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

#pragma mark - Поиск файлов (видео и изображений) на устройстве
RCT_EXPORT_METHOD(searchDeviceFilesByDate:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  
  NSNumber *deviceChannel = params[@"deviceChannel"];
  NSString *deviceId = params[@"deviceId"];
  NSNumber *maxFileCount = params[@"maxFileCount"];
  NSNumber *fileType = params[@"fileType"];
  NSString *fileName = params[@"fileName"];
  NSNumber *streamType = params[@"streamType"];
  NSDictionary *start = params[@"start"];
  NSDictionary *end = params[@"end"];
  NSNumber *timeout = params[@"timeout"];

  NSNumber *key = [self generateRequestKeyWithResolver:resolve rejecter:reject];

  H264_DVR_FINDINFO info;
  memset(&info, 0, sizeof(info));
  info.nChannelN0 = [deviceChannel intValue];
  info.nFileType = [fileType intValue];

  info.startTime.dwYear = [start[@"year"] intValue];
  info.startTime.dwMonth = [start[@"month"] intValue];
  info.startTime.dwDay = [start[@"day"] intValue];
  info.startTime.dwHour = [start[@"hour"] intValue];
  info.startTime.dwMinute = [start[@"minute"] intValue];
  info.startTime.dwSecond = [start[@"second"] intValue];
  
  info.endTime.dwYear = [end[@"year"] intValue];
  info.endTime.dwMonth = [end[@"month"] intValue];
  info.endTime.dwDay = [end[@"day"] intValue];
  info.endTime.dwHour = [end[@"hour"] intValue];
  info.endTime.dwMinute = [end[@"minute"] intValue];
  info.endTime.dwSecond = [end[@"second"] intValue];
  
  if (fileName) {
    strncpy(info.szFileName, [fileName UTF8String], sizeof(info.szFileName) - 1);
  }
  
  if (streamType) {
    info.StreamType = [streamType intValue];
  }
  
  FUN_DevFindFile(self.msgHandle, SZSTR(deviceId), &info, [maxFileCount intValue], [timeout intValue], [key intValue]);
}


#pragma mark - Обработка результатов поиска по файлам
- (void)OnFunSDKResult:(NSNumber *) pParam {
//    [super OnFunSDKResult:pParam];
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
      
    if (msg->id == EMSG_DEV_FIND_FILE) { // Поиск записей по файлам
      NSNumber *key = @(msg->seq);
      NSDictionary *callbacks = self.resolvers[key];
      
      RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
      RCTPromiseRejectBlock reject = callbacks[@"reject"];
    
      if (msg->param1 < 0) {
        if (reject) {
          NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
          reject(@"searchDeviceFilesByDate_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
        }
      } else {
        if (resolve) {
          int fileCount = msg->param1;
          H264_DVR_FILE_DATA *pFile = (H264_DVR_FILE_DATA *)msg->pObject;
          
          NSMutableArray *resultsArray = [NSMutableArray array];
          
          if (fileCount > 0) {
            for (int i = 0; i < fileCount; i++) {
              H264_DVR_FILE_DATA file = pFile[i];
              
              // Преобразуем структуру в словарь с нужными полями
              NSDictionary *fileInfo = @{
                  @"channel": @(file.ch), // Номер канала
                  @"size": @(file.size), // Размер файла
                  @"fileName": [NSString stringWithUTF8String:file.sFileName], // Имя файла
                  @"startTime": @{
                      @"year": @(file.stBeginTime.year),
                      @"month": @(file.stBeginTime.month),
                      @"day": @(file.stBeginTime.day),
                      @"hour": @(file.stBeginTime.hour),
                      @"minute": @(file.stBeginTime.minute),
                      @"second": @(file.stBeginTime.second)
                  },
                  @"endTime": @{
                      @"year": @(file.stEndTime.year),
                      @"month": @(file.stEndTime.month),
                      @"day": @(file.stEndTime.day),
                      @"hour": @(file.stEndTime.hour),
                      @"minute": @(file.stEndTime.minute),
                      @"second": @(file.stEndTime.second)
                  },
                  @"streamType": @(file.StreamType) // Тип потока
              };
              
              // Добавляем информацию в resultsArray
              [resultsArray addObject:fileInfo];
              
            }

            resolve(resultsArray);
          } else {
            resolve(@[]);
          }
        }
          
      }
      
    }
}

@end
