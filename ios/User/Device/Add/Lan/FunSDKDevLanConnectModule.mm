//
//  FunSDKDevLanConnectModule.mm
//  Funsdk
//
//  Created by Денис Кожевников on 05.06.2025.
//  Copyright © 2025 Facebook. All rights reserved.
//


#import "FunSDK/FunSDK.h"
#import <FunSDK/FunSDK2.h>
#import <FunSDK/Fun_MC.h>
#import "FunSDKDevLanConnectModule.h"
#import "DeviceControl.h"

@interface FunSDKDevLanConnectModule()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;
@property (nonatomic, assign) NSInteger requestCounter;
@property (nonatomic, strong) NSMutableArray<DeviceObject *> *searchArray;


@end

@implementation FunSDKDevLanConnectModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (id)init {
  self = [super init];
  
  self.requestCounter = 1;
  self.searchArray = [NSMutableArray array];
  
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

#pragma - mark Получении информации о channels
RCT_EXPORT_METHOD(searchDevice:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSNumber *timeout = params[@"timeout"];
  
  NSNumber *key = [self generateRequestKeyWithResolver:resolve rejecter:reject];
  
  FUN_DevSearchDevice(self.msgHandle, [timeout intValue], [key intValue]);
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
    case EMSG_DEV_SEARCH_DEVICES:{
      
      NSNumber *key = @(msg->seq);
      NSDictionary *callbacks = self.resolvers[key];
      
      RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
      RCTPromiseRejectBlock reject = callbacks[@"reject"];
      
      if (msg->param1 <= 0) {
        if (reject) {
          NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
          reject(@"EMSG_DEV_SEARCH_DEVICES_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
        }
      } else {
        if (resolve) {
          [self.searchArray removeAllObjects];
          
          struct SDK_CONFIG_NET_COMMON_V2* netCommonBuf = (struct SDK_CONFIG_NET_COMMON_V2*)msg->pObject;
          
          for (int i = 0; i < msg->param2; i++) {
            SDK_CONFIG_NET_COMMON_V2 dev = netCommonBuf[i];
            
            NSLog(@"\n==== Device %d ====", i);
            NSLog(@"HostName: %s", dev.HostName);
            NSLog(@"HostIP: %d.%d.%d.%d", dev.HostIP.c[0], dev.HostIP.c[1], dev.HostIP.c[2], dev.HostIP.c[3]);
            NSLog(@"Submask: %d.%d.%d.%d", dev.Submask.c[0], dev.Submask.c[1], dev.Submask.c[2], dev.Submask.c[3]);
            NSLog(@"Gateway: %d.%d.%d.%d", dev.Gateway.c[0], dev.Gateway.c[1], dev.Gateway.c[2], dev.Gateway.c[3]);
            NSLog(@"HttpPort: %d", dev.HttpPort);
            NSLog(@"TCPPort: %d", dev.TCPPort);
            NSLog(@"SSLPort: %d", dev.SSLPort);
            NSLog(@"UDPPort: %d", dev.UDPPort);
            NSLog(@"MaxConn: %d", dev.MaxConn);
            NSLog(@"MonMode: %d", dev.MonMode);
            NSLog(@"MaxBps: %d", dev.MaxBps);
            NSLog(@"TransferPlan: %d", dev.TransferPlan);
            NSLog(@"bUseHSDownLoad: %@", dev.bUseHSDownLoad ? @"YES" : @"NO");
            NSLog(@"sMac: %s", dev.sMac);
            NSLog(@"sSn: %s", dev.sSn);
            NSLog(@"DeviceType: %d", dev.DeviceType);
            NSLog(@"ChannelNum: %d", dev.ChannelNum);
            NSLog(@"Device_Type: %d", dev.Device_Type);
            NSLog(@"sRandomUser: %s", dev.sRandomUser);
            NSLog(@"sRandomPwd: %s", dev.sRandomPwd);
            NSLog(@"sPid: %s", dev.sPid);
            NSLog(@"Resume: %s", dev.Resume);
          }
          
          for (int i = 0; i < msg->param2; i++) {
            // Отсеивание устройств с незаконными адресами
            if (netCommonBuf[i].HostIP.l == 0 || netCommonBuf[i].TCPPort == 0) {
              continue;
            }
            
            DeviceObject *object = [[DeviceObject alloc] init];
            object.deviceMac  = [NSString stringWithUTF8String:netCommonBuf[i].sSn];
            object.nType = netCommonBuf[i].DeviceType;
            
            if (object.deviceMac == nil || (object.deviceMac.length != 16 && object.deviceMac.length != 20)) {
              // Если серийный номер недействителен, укажите вместо него IP
              object.deviceMac  = [NSString stringWithFormat:@"%d.%d.%d.%d",netCommonBuf[i].HostIP.c[0],netCommonBuf[i].HostIP.c[1],netCommonBuf[i].HostIP.c[2],netCommonBuf[i].HostIP.c[3]];
            }
            object.deviceName = [NSString stringWithUTF8String:netCommonBuf[i].HostName];
            object.deviceIp  = [NSString stringWithFormat:@"%d.%d.%d.%d",netCommonBuf[i].HostIP.c[0],netCommonBuf[i].HostIP.c[1],netCommonBuf[i].HostIP.c[2],netCommonBuf[i].HostIP.c[3]];
            
            object.loginName = @"admin";
            object.loginPsw = @"";
            object.nPort = netCommonBuf[i].TCPPort;
            if (self.searchArray.count == 0) {
              [self.searchArray addObject:object];
              continue;
            }
            BOOL find = NO;
            for (DeviceObject *device in self.searchArray) {
              if ([device.deviceMac isEqualToString:object.deviceMac]) {
                find = YES;
              }
            }
            if (find == NO) {
              [self.searchArray addObject:object];
            }
          }
          NSMutableArray *resultArray = [NSMutableArray array];
          for (DeviceObject *device in self.searchArray) {
            [resultArray addObject:@{
              @"devId": device.deviceMac ?: @"",
              @"deviceName": device.deviceName ?: @"",
              @"deviceIp": device.deviceIp ?: @"",
              //              @"loginName": device.loginName ?: @"",
              //              @"loginPsw": device.loginPsw ?: @"",
              @"port": @(device.nPort),
              @"deviceType": @(device.nType)
            }];
          }
          resolve(resultArray);
        }
      }
      
      [self.resolvers removeObjectForKey:key];
    }
      break;
  }
}


@end
