//
//  DoorUserNameConfig.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/11.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "DoorUserNameConfig.h"
#import "FunSDK/FunSDK.h"

@interface DoorUserNameConfig ()
{
    NSMutableDictionary *dataDic;
}
@end

@implementation DoorUserNameConfig

#pragma mark - 获取门锁用户信息
- (void)getDoorUserNameConfig {
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    //获取门锁用户信息 （包括用户名、用户密码、用户指纹、用户门卡等等信息）
    char cfg[1024];
    sprintf(cfg, "{ \"Name\" : \"OPDoorLockProCmd\", \"SessionID\" : \"0x00000002\", \"OPDoorLockProCmd\" : {\"Cmd\" : \"GetUsrInfo\", \"Arg1\" : \"\", \"Arg2\" : \"\"} }");
    FUN_DevCmdGeneral(self.MsgHandle, SZSTR(channel.deviceMac), 2046, "GetUsrInfo", 4096, 60000, (char *)cfg, (int)strlen(cfg) + 1, -1, 10);
}
#pragma mark  设置门锁用户信息
- (void)setDoorUserName:(NSMutableDictionary*)dic {
    dataDic = [dic mutableCopy];
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    NSString *dataStr = [self convertToJsonData:dataDic];
    
    NSString *setString = [NSString stringWithFormat:@"{\"OPDoorLockProCmd\":{\"Cmd\":\"ChangeUsrName\",\"DoorLockAuthManage\":[%@]},\"SessionID\":\"0x08\",\"Name\":\"OPDoorLockProCmd\"}",dataStr];
    
    const char* cfg = SZSTR(setString);
    FUN_DevCmdGeneral(self.MsgHandle, SZSTR(channel.deviceMac), 2046, "ChangeUsrName", 4096, 5000, (char *)cfg, (int)strlen(cfg) + 1, -1, 0);
}

#pragma mark - 读取获取到的门锁用户信息
- (NSMutableDictionary*)getDoorUserInfo {
    if (dataDic) {
        return [dataDic mutableCopy];
    }
    return [NSMutableDictionary dictionary];
}

#pragma mark - 获取和设置的回调信息
-(void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:{
            if (msg->param1 < 0) {
                if ([self.delegate respondsToSelector:@selector(DoorUserNameConfigGetResult:)]) {
                    [self.delegate DoorUserNameConfigGetResult:msg->param1];
                }
            }else{
                if (msg->param3 == 2046) {
                    NSString *cmdName = [NSString stringWithUTF8String:msg->szStr];
                    NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    NSError *error;
                    NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                    if (!retDic) {
                        if ([self.delegate respondsToSelector:@selector(DoorUserNameConfigGetResult:)]) {
                            [self.delegate DoorUserNameConfigGetResult:msg->param1];
                        }
                        return;
                    }
                    int ret = [retDic[@"Ret"] intValue];
                    if (ret != 100) {
                        if ([self.delegate respondsToSelector:@selector(DoorUserNameConfigGetResult:)]) {
                            [self.delegate DoorUserNameConfigGetResult:msg->param1];
                        }
                    } else {
                        if ([cmdName isEqualToString:@"GetUsrInfo"]) {
                            NSMutableArray *userInfo = [retDic objectForKey:@"GetUsrInfo"];
                            if (userInfo && ![userInfo isEqual:[NSNull null]]) {
                                dataDic = [[retDic objectForKey:@"GetUsrInfo"] objectAtIndex:0];
                            }
                            if ([self.delegate respondsToSelector:@selector(DoorUserNameConfigGetResult:)]) {
                                [self.delegate DoorUserNameConfigGetResult:msg->param1];
                            }
                        }
                        if ([cmdName isEqualToString:@"ChangeUsrName"]) {
                            if ([self.delegate respondsToSelector:@selector(DoorUserNameConfigSetResult:)]) {
                                [self.delegate DoorUserNameConfigSetResult:msg->param1];
                            }
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

-(NSString *)convertToJsonData:(NSDictionary *)dict {
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONReadingMutableLeaves error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}
@end
