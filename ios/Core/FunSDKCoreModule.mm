#import "FunSDKCoreModule.h"
#import <React/RCTLog.h>
#import <FunSDK/FunSDK.h>
#import <FunSDK/netsdk.h>
#import "NSString+Path.h"
#import "DataEncrypt.h"
#import <XMNetInterface/Reachability.h>

@implementation FunSDKCoreModule

RCT_EXPORT_MODULE()

//RCT_EXPORT_METHOD(init: (RCTResponseSenderBlock)callback)
RCT_EXPORT_METHOD(init:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSInteger eventId = 123;
    
//    int PWD_TYPE = 0; // Используем тип данных int для PWD_TYPE
//    const char *PWD = ""; // Строки C используются для передачи в функции C
//    const char *SERVER_ADDR = "p2p-s1.red-dst.ru";
//    int PORT = 8000;
    int PWD_TYPE = [params[@"customPwdType"] intValue];
    const char *PWD = [params[@"customPwd"] UTF8String];
    const char *SERVER_ADDR = [params[@"customServerAddr"] UTF8String];
    int PORT = [params[@"customPort"] intValue];
    
//    RCTLogInfo(@"Pretending to create an event");
    
    SInitParam pa;
    
    pa.nAppType = H264_DVR_LOGIN_TYPE_MOBILE;
    
    // Эти строки нужны, но исправлены на C-строки:
    strcpy(pa.sLanguage, "en");
    strcpy(pa.nSource, "xmshop");
    
    // подключение к обычному серверу
//     FUN_Init(0, &pa);
    
    // использование кастомного сервера
    FUN_InitExV2(0, &pa, PWD_TYPE, PWD, SERVER_ADDR, PORT);
    
//    const char *APPUUID = "e0534f3240274897821a126be19b6d46";
//    const char *APPKEY = "caae4d4cebd842d99b86263533b8c50b";
//    const char *APPSECRET = "3cb982572d4b4ff998a27e442fc60a16";
//    int MOVECARD = 4;
    
    // Инициализация платформы
    FUN_XMCloundPlatformInit(APPUUID, APPKEY, APPSECRET, MOVECARD);
    
    FUN_SetFunStrAttr(EFUN_ATTR_SAVE_LOGIN_USER_INFO, [[NSString GetDocumentPathWith:@"UserInfo.db"] UTF8String]);

    FUN_SetFunStrAttr(EFUN_ATTR_UPDATE_FILE_PATH,[[NSString GetDocumentDirectryPathWith:@"/upgradeFile"] UTF8String]);
    
    FUN_SetFunIntAttr(EFUN_ATTR_AUTO_DL_UPGRADE, 0);
    
    FUN_SetFunStrAttr(EFUN_ATTR_CONFIG_PATH,[[NSString GetDocumentPathWith:@"APPConfigs"] UTF8String]);

    [[[DataEncrypt alloc] init] initP2PDataEncrypt];

    FUN_SetFunIntAttr(EFUN_ATTR_SUP_RPS_VIDEO_DEFAULT, 1);

    FUN_SetFunIntAttr(EFUN_ATTR_SET_NET_TYPE, [FunSDKCoreModule getNetworkType]);

    FUN_SetFunStrAttr(EFUN_ATTR_USER_PWD_DB, [[NSString GetDocumentPathWith:@"password.txt"] UTF8String]);


    FUN_InitNetSDK();
    
    FUN_SysInit(SERVER_ADDR, PORT);
    
    resolve(@(eventId));
}

+(int)getNetworkType {
    Reachability*reach=[Reachability reachabilityWithHostName:@"www.apple.com"];
    
    //判断当前的网络状态
    switch([reach currentReachabilityStatus]){
            
        case ReachableViaWiFi:
            return 1;
            
        case ReachableViaWWAN:
            return 2;
            
        default:
            return 0;
            break;
    }
}

@end