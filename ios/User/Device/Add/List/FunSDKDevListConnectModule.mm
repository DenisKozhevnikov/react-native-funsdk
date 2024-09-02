//
//  FunSDKDevListConnectModule.m
//  react-native-funsdk
//
//  Created by Денис Кожевников on 18.08.2024.
//

#import "FunSDKDevListConnectModule.h"
#import "FunSDK/FunSDK.h"
#import <React/RCTLog.h>
#import "DoorBellModel.h"
#import "DeviceManager.h"

@interface FunSDKDevListConnectModule()<DeviceManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;

@end

@implementation FunSDKDevListConnectModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

#pragma - mark Запрос на получение списка устройств
RCT_EXPORT_METHOD(getDetailDeviceList:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    const NSMutableArray *deviceArray  = [[DeviceControl getInstance] currentDeviceArray];
    
    if (deviceArray == nil) {
        deviceArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    // Выводим содержимое массива в консоль
    // RCTLogInfo(@"Device Array: %@", deviceArray);
    
    NSMutableArray *resultArray = [NSMutableArray array];
        
    for (id device in deviceArray) {
        // Используем KVC для получения всех доступных свойств
        NSDictionary *deviceDict = [device dictionaryWithValuesForKeys:@[@"deviceMac", @"deviceName", @"deviceIp", @"nPort", @"state", @"deviceType", @"loginName", @"loginPsw", @"state", @"nType", @"nID", @"ret"]];
        
        // Преобразуем примитивные значения в NSNumber
        NSNumber *devPort = [NSNumber numberWithInt:[deviceDict[@"nPort"] intValue]];
        NSNumber *devState = [NSNumber numberWithInt:[deviceDict[@"state"] intValue]];
        NSNumber *devType = [NSNumber numberWithInt:[deviceDict[@"deviceType"] intValue]];
        NSNumber *state = [NSNumber numberWithInt:[deviceDict[@"state"] intValue]];
        NSNumber *nType = [NSNumber numberWithInt:[deviceDict[@"nType"] intValue]];
        NSNumber *nID = [NSNumber numberWithInt:[deviceDict[@"nID"] intValue]];
        NSNumber *ret = [NSNumber numberWithInt:[deviceDict[@"ret"] intValue]];

        // Создаем словарь для каждого устройства
        NSDictionary *resultDict = @{
            @"devId": deviceDict[@"deviceMac"] ?: @"",
            @"devIp": deviceDict[@"deviceIp"] ?: @"",
            @"devIpPort": [NSString stringWithFormat:@"%@", devPort],
            @"devName": deviceDict[@"deviceName"] ?: @"",
            @"devPort": devPort,
            @"devState": devState,
            @"devType": devType,
            @"loginName": deviceDict[@"loginName"] ?: @"",
            @"loginPsw": deviceDict[@"loginPsw"] ?: @"",
            @"state": state,
            @"nType": nType,
            @"nID": nID,
            @"ret": ret
        };

        
        [resultArray addObject:resultDict];
    }

    resolve([resultArray copy]);
}

#pragma - mark Запрос на обновление состояния устройства
RCT_EXPORT_METHOD(updateAllDevStateFromServer:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if (!self.resolvers) {
        self.resolvers = [NSMutableDictionary dictionary];
    }
    
    NSNumber *key = @(EMSG_SYS_GET_DEV_STATE);
    // Сохраняем блоки resolve и reject в маппинг
    self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
    
    
    DeviceManager *manager = [DeviceManager getInstance];
    manager.delegate = self;
    [manager getDeviceState:nil];
    
    // Устанавливаем таймер на 15 секунд
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *callbacks = self.resolvers[key];
        
        if (callbacks) {
            RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
            resolve(@"timeout");
            [self.resolvers removeObjectForKey:key];
        }
    });
}

#pragma - mark Результат запроса на обновление состояния устройства
- (void)getDeviceState:(NSString *)sId result:(int)result {
    NSNumber *key = @(EMSG_SYS_GET_DEV_STATE);
    
    NSDictionary *callbacks = self.resolvers[key];
    
    if (callbacks) {
        RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
        resolve(@"updated");
        [self.resolvers removeObjectForKey:key];
    }
}

@end
