//
//  VoiceBroadcastingManager.m
//  FunSDKDemo
//
//  Created by plf on 2023/6/3.
//  Copyright © 2023 plf. All rights reserved.
//

#import "VoiceBroadcastingManager.h"
#import "NSDictionary+Extension.h"

@interface VoiceBroadcastingManager()

@property(nonatomic,strong)NSMutableDictionary *audioClockInfoDic; // 获取到的报警音数据

@end

@implementation VoiceBroadcastingManager

-(void)getAllAudioClockList:(GetAllAudioClockListCallBack)callBack
{
    self.getAllAudioClockListCallBack = callBack;
    
//    FUN_DevGetConfig_Json(self.msgHandle, [self.devID UTF8String], "ListAllAudioClock", 1024);
    
    NSString *cfgName = @"ListAllAudioClock";
    NSDictionary *dic = @{@"Name":cfgName};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 3630, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 3630);
}


- (void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            NSString *paramName = OCSTR(msg -> szStr);
            if ([paramName isEqualToString:@"ListAllAudioClock"]  ) {
                Fun_Log((char *)"展示所有时间点信息 \n");
                if (msg->param1 >= 0) {
                    NSDictionary *jsonDic = [NSDictionary dictionaryFromData:msg->pObject];
                    self.audioClockInfoDic = [[NSMutableDictionary alloc]initWithDictionary:[jsonDic mutableCopy]];
                    
                    if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dicInfo = [jsonDic objectForKey:@"ListAllAudioClock"];
                        if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
                            if (self.getAllAudioClockListCallBack) {
                                self.getAllAudioClockListCallBack(self.audioClockInfoDic);
                            }
                        }
                    }
                }
                else
                {
                    [MessageUI ShowErrorInt:msg->param1];
                }
            }
        }
            break;
        default:
            break;
    }
}

@end
