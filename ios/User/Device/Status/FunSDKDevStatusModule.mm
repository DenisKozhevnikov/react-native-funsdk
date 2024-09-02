//
//  FunSDKDevStatusModule.m
//  react-native-funsdk
//
//  Created by Денис Кожевников on 18.08.2024.
//

#import "FunSDK/FunSDK.h"
#import <FunSDK/FunSDK2.h>
#import <FunSDK/Fun_MC.h>
#import "FunSDKDevStatusModule.h"
#import "DeviceControl.h"

@interface FunSDKDevStatusModule()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;
@property (nonatomic, assign) NSInteger requestCounter;

@end

@implementation FunSDKDevStatusModule

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

#pragma - mark Подключение к устройству
RCT_EXPORT_METHOD(loginDeviceWithCredential:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    const char *deviceId = [params[@"deviceId"] UTF8String];
    const char *deviceLogin = [params[@"deviceLogin"] UTF8String];
    const char *devicePassword = [params[@"devicePassword"] UTF8String];
    
    if (!self.resolvers) {
        self.resolvers = [NSMutableDictionary dictionary];
    }
    
    self.requestCounter++;
    NSNumber *key = @(_requestCounter);
    
    // Сохраняем блоки resolve и reject в маппинг
    self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
    
    Fun_DevSetLocalUserNameAndPwd(deviceId, deviceLogin, devicePassword);
    
//    FUN_DevLogin(self.msgHandle, deviceId, deviceLogin, devicePassword, [key intValue]);
//    int FUN_DevGetConfig_Json(UI_HANDLE hUser, const char *szDevId, const char *szCommand, int nOutBufLen, int nChannelNO = -1, int nTimeout = 15000, int nSeq = 0);
//    FunSDK.DevGetConfigByJson(userId, devId, JsonConfig.SYSTEM_INFO, 1024, -1, loginTimeOut, seq);
//    FUN_DevGetConfig_Json(self.msgHandle, CSTR(dev_id), "General.AppBindFlag", 1024);

    FUN_DevGetConfig_Json(self.msgHandle, deviceId, "SystemInfo", 1024, -1, 15000, [key intValue]);
}


#pragma - mark Управление устройством
RCT_EXPORT_METHOD(devicePTZControl:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *deviceId = params[@"deviceId"];
    NSNumber *nPTZCommand = params[@"command"];
    BOOL bStop = [params[@"bStop"] boolValue];
    NSNumber *channelId = params[@"deviceChannel"];
    NSNumber *speed = params[@"speed"];
    
    FUN_DevPTZControl(self.msgHandle, SZSTR(deviceId), [channelId intValue], [nPTZCommand intValue], bStop, [speed intValue], 0);
}

#pragma - mark Получении информации о channels
RCT_EXPORT_METHOD(getChannelInfo:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

    NSString *deviceId = params[@"deviceId"];
    
    self.requestCounter++;
    NSNumber *key = @(_requestCounter);
    
    if (!self.resolvers) {
        self.resolvers = [NSMutableDictionary dictionary];
    }
    
    // Сохраняем блоки resolve и reject в маппинг
    self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
    
    FUN_DevGetChnName(self.msgHandle, SZSTR(deviceId), "", "", [key intValue]);
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
        case EMSG_DEV_GET_CONFIG_JSON:{
            
            NSNumber *key = @(msg->seq);
            NSDictionary *callbacks = self.resolvers[key];
            
            RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
            RCTPromiseRejectBlock reject = callbacks[@"reject"];
            
            if (strcmp(msg->szStr, "SystemInfo") == 0) {
                if (msg->param1 < 0) {
                    if (reject) {
                        NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
                        reject(@"loginDeviceWithCredential_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
                    }
                } else {
                    if (resolve) {
//                        NSDictionary *pObject = @{
//                            @"Name": @"SystemInfo",
//                            @"Ret": @(100),
//                            @"SessionID": @"0xaf",
//                            
//                        };
                        NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                        NSError *error;
                        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                        
                        NSDictionary *dicInfo = [jsonDic objectForKey:@"SystemInfo"];

                        NSDictionary *responseObject = @{
                            @"i": @(1),
                            @"s": dicInfo[@"SerialNo"],
                            @"value": dicInfo
                        };

                        resolve(responseObject);
                    }

                }
            }
            [self.resolvers removeObjectForKey:key];
        }
            break;
        case EMSG_DEV_GET_CHN_NAME:{
            NSNumber *key = @(msg->seq);
            NSDictionary *callbacks = self.resolvers[key];
            
            RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
            RCTPromiseRejectBlock reject = callbacks[@"reject"];
            
            DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:NSSTR(msg->szStr)];
            
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

                NSMutableArray *channelTitles = [[NSMutableArray alloc] initWithCapacity:msg->param3];


                for (int i = 0; i < msg->param3; i++) {
                    NSString *title = [NSString stringWithUTF8String:pChannels->channelTitle[i]];
                    [channelTitles addObject:title];
                }
                
                resolve(@{
                    @"s": @(msg->szStr),
                    @"i": @1,
                    @"value": @{
                        @"canUsedChannelSize": @(msg->param3),
                        @"isComOpen": @(false),
                        @"nChnCount": @(MIN(msg->param3, 64)),
                        @"st_channelTitle": [channelTitles copy]
                    }
                });
//            value: {
//              canUsedChannelSize: number;
//              isComOpen: boolean;
//              nChnCount: number;
//              st_channelTitle: string[];
//            };
//                onDevManagerListener.onSuccess(devId, OPERA_GET_CONFIG_DEV, channelNameConfigAll);
            } else {
                NSString *errorMessage = [NSString stringWithFormat:@"%s, %d, %s, %d", msg->szStr, msg->param1, "DevGetChannelInfo", msg->id];
                
                reject(@"get_channel_info_error", errorMessage, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
            }
            [self.resolvers removeObjectForKey:key];
        }
            break;
//        case EMSG_DEV_LOGIN:{
//            NSNumber *key = @(msg->seq);
//            NSDictionary *callbacks = self.resolvers[key];
//            
//            RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
//            RCTPromiseRejectBlock reject = callbacks[@"reject"];
//            
//            if (msg->param1 < 0) {
//                if (reject) {
//                    NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
//                    reject(@"loginDeviceWithCredential_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
//                }
//            } else {
//                if (resolve) {
//                    resolve(@(msg->param1));
//                }
//            }
//            [self.resolvers removeObjectForKey:key];
//            break;
//        }
    }
}


@end
