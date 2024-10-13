//
//  FunSDKInfoModule.m
//  Funsdk
//
//  Created by Денис Кожевников on 10.10.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import "FunSDKInfoModule.h"
#import "FunSDK/FunSDK.h"
#import "DeviceManager.h"
#import "LoginShowControl.h"

@interface FunSDKInfoModule()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;
@property (nonatomic, assign) NSInteger requestCounter;

@end

@implementation FunSDKInfoModule

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

#pragma - mark Удаление данных аккаунта
RCT_EXPORT_METHOD(logout:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
     
//  if (!self.resolvers) {
//    self.resolvers = [NSMutableDictionary dictionary];
//  }
//
//  self.requestCounter++;
//  NSNumber *key = @(_requestCounter);
//  
//  // Сохраняем блоки resolve и reject в маппинг
//  self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
  
  FUN_UnInitNetSDK();
//  FUN_SysLogout(self.msgHandle, [key intValue]);
  
  if ([[LoginShowControl getInstance] getLoginType] != loginTypeNone) {
      [[LoginShowControl getInstance] setLoginType:loginTypeNone];
  }

  [[DeviceManager getInstance] clearDeviceList];
//  [[DeviceManager getInstance] addDeviceToList:[NSMessage SendMessag:nil obj:msg->pObject p1:msg->param1 p2:0]];
  
  resolve(nil);
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
    case EMSG_SYS_LOGOUT:{
      NSNumber *key = @(msg->seq);
      NSDictionary *callbacks = self.resolvers[key];
      
      RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
      RCTPromiseRejectBlock reject = callbacks[@"reject"];
      
      if (msg->param1 < 0) {
        // error
        if (reject) {
          NSString *errorString = [NSString stringWithFormat:@"%d %d", (int)msg->id, (int)msg->param1];
          reject(@"EMSG_SYS_LOGOUT_error", errorString, [NSError errorWithDomain:@"FunSDK" code:msg->param1 userInfo:nil]);
        }
      } else {
        // success
        if (resolve) {
          resolve(@(msg->param1));
        }
      }
      
      [self.resolvers removeObjectForKey:key];
      
      break;
    }
  }
}

@end
