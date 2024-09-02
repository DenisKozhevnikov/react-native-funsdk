//
//  SystemInfoManager.m
//  XMEye Pro
//
//  Created by 杨翔 on 2022/4/21.
//  Copyright © 2022 Megatron. All rights reserved.
//

#import "SystemInfoManager.h"
#import <FunSDK/FunSDK.h>
// systeminfo block
typedef void(^SystemInfoCompletion)(NSDictionary *responseDic, NSInteger errCode);

@interface SystemInfoManager ()

@property (nonatomic, strong) NSMutableDictionary *systemInfoDic;
/** 数据回传block */
@property (nonatomic, copy) SystemInfoCompletion sysInfoCompletion;

@end

@implementation SystemInfoManager

+ (instancetype)shareInstance{
    static SystemInfoManager *_infoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _infoManager = [[SystemInfoManager alloc] init];
    });
    return _infoManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.systemInfoDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

//是否带有模拟通道的设备
-(BOOL)videoInChannel{
    if ([self.systemInfoDic isKindOfClass:[NSNull class]] || self.systemInfoDic == nil) {
        return NO;
    }
    return [[self.systemInfoDic objectForKey:@"VideoInChannel"] intValue] > 0 ? YES : NO;
}

//是否是模拟通道
-(BOOL)channelIsContainVideo:(int)channel{
    if ([self videoInChannel] == NO) {
        return NO;
    }
    
    int videoinChannelValue = [[self.systemInfoDic objectForKey:@"VideoInChannel"] intValue];
    if (channel < videoinChannelValue) {
        return YES;
    }
    return NO;
}

-(void)getSystemInfo:(NSString *)devId Completion:(GetSystemInfoBlock)completion{
    self.getSystemInfo = completion;
    
    FUN_DevGetConfig_Json(self.msgHandle, CSTR(devId), "SystemInfo",0);
}
// 获取设备systeInfo
+ (void)fetchDevSystemInfoWithDevId:(NSString *)devId completion:(void(^)(NSDictionary *responseDic, NSInteger errCode))completion{
    [[SystemInfoManager shareInstance] fetchDevSystemInfoWithDevId:devId completion:completion];
}

- (void)fetchDevSystemInfoWithDevId:(NSString *)devId completion:(void(^)(NSDictionary *responseDic, NSInteger errCode))completion{
    if (!devId||devId.length == 0) return;
    self.sysInfoCompletion = completion;
    FUN_DevGetConfig_Json(self.msgHandle, CSTR(devId), "SystemInfo", 0);
}

- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:{
            if (strcmp(msg->szStr, "SystemInfo") == 0){
                if (msg->param1 < 0) {
                    if (self.getSystemInfo) {
                        self.getSystemInfo(msg->param1);
                    }
                    if (self.sysInfoCompletion) {
                        self.sysInfoCompletion(nil, msg->param1);
                        self.sysInfoCompletion = nil;
                    }
                }else{
                    if (msg->pObject == NULL) {
                        if (self.getSystemInfo) {
                            self.getSystemInfo(-1);
                        }
                        if (self.sysInfoCompletion) {
                            self.sysInfoCompletion(nil, msg->param1);
                            self.sysInfoCompletion = nil;
                        }
                        return;
                    }
                    
                    NSDictionary *appData = nil;
                    NSString *originalString = NSSTR(msg->pObject);
                    NSMutableString *mstring = [NSMutableString stringWithString:originalString];
                    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
                    NSRange range = [originalString rangeOfCharacterFromSet:controlChars];
                    while (range.location != NSNotFound){ // 包含
                        [mstring deleteCharactersInRange:range]; // 删除
                        range = [mstring rangeOfCharacterFromSet:controlChars]; // 遍历
                    }
                    NSData *data = [[[NSString alloc] initWithUTF8String:mstring.UTF8String] dataUsingEncoding:NSUTF8StringEncoding];
                    
                    if (data == nil || [data isKindOfClass:[NSNull class]]) {
                        if (self.getSystemInfo) {
                            self.getSystemInfo(-1);
                        }
                        if (self.sysInfoCompletion) {
                            self.sysInfoCompletion(nil, msg->param1);
                            self.sysInfoCompletion = nil;
                        }
                        return;
                    }
                    
                    appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    if (appData == nil || [appData isKindOfClass:[NSNull class]]) {
                        if (self.getSystemInfo) {
                            self.getSystemInfo(-1);
                        }
                        if (self.sysInfoCompletion) {
                            self.sysInfoCompletion(nil, msg->param1);
                            self.sysInfoCompletion = nil;
                        }
                        return;
                    }
                    
                    NSError *error;
                    NSMutableDictionary *infoDic = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                    if (infoDic == nil || [infoDic isKindOfClass:[NSNull class]]) {
                        if (self.getSystemInfo) {
                            self.getSystemInfo(-1);
                        }
                        if (self.sysInfoCompletion) {
                            self.sysInfoCompletion(nil, msg->param1);
                            self.sysInfoCompletion = nil;
                        }
                        return;
                    }
                    NSDictionary *systemInfo = [infoDic objectForKey:@"SystemInfo"];
                    if (self.sysInfoCompletion) {
                        self.sysInfoCompletion(systemInfo, msg->param1);
                        self.sysInfoCompletion = nil;
                    }
                    if (systemInfo == nil) {
                        if (self.getSystemInfo) {
                            self.getSystemInfo(-1);
                        }
                    }else{
                        self.systemInfoDic = [systemInfo mutableCopy];
                        if (self.getSystemInfo) {
                            self.getSystemInfo(msg->param1);
                        }
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}

@end
