//
//  SDKInitializeModel.m
//  MobileVideo
//
//  Created by XM on 2018/4/23.
//  Copyright © 2018年 XM. All rights reserved.
//
// SDKInitializeModel  初始化FunSDK的类文件，SDK必须初始化才能使用其他功能
#import "SDKInitializeModel.h"
#import "FunSDK/FunSDK.h"
#import "DataEncrypt.h"

#import <XMNetInterface/Reachability.h>

@implementation SDKInitializeModel

+ (void)SDKInit {
    //1、初始化底层库和底层库的语言以及国际化语言文件
    [self initLanguage];
    //2、初始化app证书,和云服务有关
    [self initPlatform];
    //3、初始化一些必须的底层配置
    [self configParam];
}


//1、初始化底层库语言和国际化语言文件。
//说明：初始化底层库如果出现崩溃，部分情况下是xcode环境没有配置好，请对比一下demo的xcode环境。另外有可能出现的是其他第三方的库和FunSDK底层库文件冲突。这种情况下崩溃信息会指向SDK内部，根据指向来判断问题（例如openssl和FFmpeg开源库，项目中的版本和SDK中的版本不一致就会导致编译不通过或初始化崩溃等。SDK中的开源库版本：openssl：1.1.0e，FFmpeg：4.2）
+ (void)initLanguage {
    //获取当前系统的语言
    NSString *language = [LanguageManager currentLanguage];
    //初始化底层库语言，底层库只支持汉语和英语
    SInitParam pa;
    pa.nAppType = H264_DVR_LOGIN_TYPE_MOBILE;
    if ([language isContainsString:@"zh"]) {
        strcpy(pa.sLanguage,"zh");
    } else {
        strcpy(pa.sLanguage,"en");
    }
    strcpy(pa.nSource, "xmshop");
    
    //使用默认服务器
    FUN_Init(0, &pa);
    
    //使用定制服务器，需要通过下面的方法初始化   "test.com"：定制的域名或者IP， port：定制的端口号
    //FUN_InitExV2(0, &pa, 0, "", "test.com",port);
    
    //初始化国际化语言文件，app界面显示语言
    Fun_InitLanguage([[[NSBundle mainBundle] pathForResource:language ofType:@"txt"] UTF8String]);
    
    //设置打印和运行日志保存，如不需要，则可以注释掉
    Fun_LogInit(FUN_RegWnd((__bridge LP_WND_OBJ)self), "", 0, "", 2);
}

//2、初始化app证书和APPKEY
    //⚠️警告！！！
//说明：初始化开放平台App信息，需要在雄迈开放平台上面创建APP来生成APPUUID和APPKEY等参数，每一个APP对应一组唯一的平台信息，如果直接使用下面参数，则可能会出现各种问题
+ (void)initPlatform {
    /*
     <!--应用证书,以下4个字段必须要在开放平台注册应用之后替换掉，测试Key会不定期更换，如果未替换则可能会出现各种问题>
     */
    FUN_XMCloundPlatformInit(APPUUID, APPKEY, APPSECRET, MOVECARD);
}
//3、初始化一些必须的底层配置
//说明；这些配置是设置APP的SDK各种缓存或者保存文件的位置，在沙盒中创建对应的文件夹
+ (void)configParam {
    // 初始化相关的参数 必须设置,账号登录成功后设备信息的保存路径+文件
    FUN_SetFunStrAttr(EFUN_ATTR_SAVE_LOGIN_USER_INFO,SZSTR([NSString GetDocumentPathWith:@"UserInfo.db"]));
    
    //升级⽂文件存放路径(只是文件夹路径，不包含文件名。请单独创建一个文件夹来存放升级文件，APP缓存的升级文件在特定情况下会被清除，防止影响到其他文件)
    FUN_SetFunStrAttr(EFUN_ATTR_UPDATE_FILE_PATH,SZSTR([NSString GetDocumentDirectryPathWith:@"/upgradeFile"]));
    
    //设置是否可以自动下载设备升级文件, 0不自动下载， 1wifi下自动下载， 2 有网络即自动下载
    FUN_SetFunIntAttr(EFUN_ATTR_AUTO_DL_UPGRADE, 0);//自行选择哪一种，可以动态更改
    
    // 配置文件存放路径(只是路径，不包含文件名)
    FUN_SetFunStrAttr(EFUN_ATTR_CONFIG_PATH,SZSTR([NSString GetDocumentPathWith:@"APPConfigs"]));
    
    //初始化加密传输方式,默认打开
    [[[DataEncrypt alloc] init] initP2PDataEncrypt];
    
    FUN_SetFunIntAttr(EFUN_ATTR_SUP_RPS_VIDEO_DEFAULT, 1);
    
    //⚠️告知FunSDK当前网络状态(1:WIFI 2:移动网络)（APP网络状态发生变化时，最好重新设置一下网络状态，这样在手机网络变化时可以更快的重新请求到设备在线状态）
    FUN_SetFunIntAttr(EFUN_ATTR_SET_NET_TYPE, [SDKInitializeModel getNetworkType]);
    
    // 本地设备密码存储文件，必须设置
    FUN_SetFunStrAttr(EFUN_ATTR_USER_PWD_DB, SZSTR([NSString GetDocumentPathWith:@"password.txt"]));
    
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
