//
//  Core.m
//  Funsdk
//
//  Created by Денис Кожевников on 16.03.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "FunSDKCoreModule.h"
#import <React/RCTLog.h>
#import <FunSDK/FunSDK.h>
#import <FunSDK/netsdk.h>


@implementation FunSDKCoreModule

RCT_EXPORT_MODULE()
// Тестирование и понимание работы использования нативного кода
// код взят из: https://reactnative.dev/docs/native-modules-ios#test-what-you-have-built
RCT_EXPORT_METHOD(createCalendarEvent:(NSString *)title location:(NSString *)location callback: (RCTResponseSenderBlock)callback)
{
    NSInteger eventId = 123;
    callback(@[@(eventId)]);

    RCTLogInfo(@"Pretending to create an event %@ at %@", title, location);
}

RCT_EXPORT_METHOD(init:(NSString *)title location:(NSString *)location callback: (RCTResponseSenderBlock)callback)
{
    NSInteger eventId = 123;
    

    RCTLogInfo(@"Pretending to create an event %@ at %@", title, location);
  
    SInitParam pa;
  
    pa.nAppType = H264_DVR_LOGIN_TYPE_MOBILE;
    strcpy(pa.sLanguage,"en");
    strcpy(pa.nSource, "xmshop");
  
//    FUN_Init(0, &pa);


  
//    FUN_XMCloundPlatformInit(APPUUID, APPKEY, APPSECRET, MOVECARD);
  
    callback(@[@(eventId)]);
}

@end
