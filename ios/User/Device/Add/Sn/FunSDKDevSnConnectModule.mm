//
//  FunSDKDevSnConnectModule.m
//  react-native-funsdk
//
//  Created by Денис Кожевников on 18.08.2024.
//

#import "FunSDKDevSnConnectModule.h"
#import "FunSDK/FunSDK.h"
#import "DeviceManager.h"

@interface FunSDKDevSnConnectModule()<DeviceManagerDelegate>
{
    DeviceManager *deviceManager; // Менеджер управления устройствами
}

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;

@end

@implementation FunSDKDevSnConnectModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

#pragma - mark Добавление устройства по серийному номеру
RCT_EXPORT_METHOD(addDev:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  // DEV_SN / IP / DNS
  NSString *deviceId = params[@"deviceId"];
  NSString *deviceName = params[@"deviceName"];
  NSString *deviceIp = params[@"deviceIp"];
  NSString *username = params[@"username"];
  NSString *password = params[@"password"];
  
  NSNumber *DMZTcpPort = params[@"DMZTcpPort"];
  NSNumber *deviceType = params[@"deviceType"];
  
  if(!deviceManager) {
    deviceManager = [[DeviceManager alloc] init];
    deviceManager.delegate = self;
  }
  
  if (!self.resolvers) {
    self.resolvers = [NSMutableDictionary dictionary];
  }
  
  NSNumber *key = @(EMSG_SYS_ADD_DEVICE);
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  [deviceManager addDeviceByDeviseSerialnumber:deviceId deviceName:deviceName loginName:username loginPassword:password devType:[deviceType intValue] devPort:DMZTcpPort deviceIp: deviceIp];
}

-(void)addDeviceResult:(int)reslut
{
  
  NSNumber *key = @(EMSG_SYS_ADD_DEVICE);
  
  NSDictionary *callbacks = self.resolvers[key];
  
  if (callbacks) {
    if (reslut >= 0) {
      RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
      resolve(key);
    } else {
      RCTPromiseRejectBlock reject = callbacks[@"reject"];
      
      NSString *errorString = [NSString stringWithFormat:@"%d %d", EMSG_SYS_ADD_DEVICE, reslut];
      reject(@"login_error", errorString, [NSError errorWithDomain:@"FunSDK" code:reslut userInfo:nil]);
    }
    
    [self.resolvers removeObjectForKey:key];
  }
}

#pragma - mark Удаление устройства по серийному номеру
RCT_EXPORT_METHOD(deleteDev:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *deviceId = params[@"deviceId"];
  
  if(!deviceManager) {
    deviceManager = [[DeviceManager alloc] init];
    deviceManager.delegate = self;
  }
  
  if (!self.resolvers) {
    self.resolvers = [NSMutableDictionary dictionary];
  }
  
  NSNumber *key = @(EMSG_SYS_DELETE_DEV);
  // Сохраняем блоки resolve и reject в маппинг
  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  [deviceManager deleteDeviceWithDevMac:deviceId];
}


- (void)deleteDevice:(NSString *)sId result:(int)reslut
{
    NSLog(@"cb удаления устройства %@ %d", sId, reslut);
  
    NSNumber *key = @(EMSG_SYS_DELETE_DEV);
    
    NSDictionary *callbacks = self.resolvers[key];
  
    // какое-то откуда-то удаление
    [JFDevConfigService jf_clearDevConfigCacheWithDevId:sId];

    if (callbacks) {
        if (reslut >= 0) {
            RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
            resolve(key);
        } else {
            RCTPromiseRejectBlock reject = callbacks[@"reject"];
            NSString *errorString = [NSString stringWithFormat:@"%d %d", EMSG_SYS_DELETE_DEV, reslut];
            reject(@"login_error", errorString, [NSError errorWithDomain:@"FunSDK" code:reslut userInfo:nil]);
        }
        
        [self.resolvers removeObjectForKey:key];
    }
}

@end
