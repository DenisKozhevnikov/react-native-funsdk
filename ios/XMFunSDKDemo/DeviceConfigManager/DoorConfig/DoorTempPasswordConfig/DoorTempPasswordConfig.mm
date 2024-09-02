//
//  DoorTempPasswordConfig.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/10.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "DoorTempPasswordConfig.h"
#import "FunSDK/FunSDK.h"

@interface DoorTempPasswordConfig ()
{
    NSString *DoorLockID; //门锁ID
    int number; //密码有效次数
    NSString *passwd; //临时密码
    NSString *startTime; //密码开始生效时间
    NSString *endTime; //密码开始失效时间
}
@end

@implementation DoorTempPasswordConfig

#pragma mark - 获取门锁临时密码信息
- (void)getDoorDevListConfig {
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    //获取门锁列表
    char cfg4[1024];
    sprintf(cfg4, "{ \"Name\" : \"OPDoorLockProCmd\", \"SessionID\" : \"0x00000002\", \"OPDoorLockProCmd\" : {\"Cmd\" : \"GetAllDevList\", \"Arg1\" : \"\", \"Arg2\" : \"\"} }");
    FUN_DevCmdGeneral(self.MsgHandle, SZSTR(channel.deviceMac), 2046, "GetAllDevList", 0,20000, (char *)cfg4, (int)strlen(cfg4) + 1, -1, 10);
}
#pragma mark 设置门锁临时密码
- (void)setDoorTempPassword {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    if (number <= 0) {
        number = 1;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TimeFormatter];
    NSDate *endTimeDate = [dateFormatter dateFromString:endTime];
    NSDate *startTimeDate = [dateFormatter dateFromString:startTime];
    NSComparisonResult result = [startTimeDate compare:endTimeDate];
    if (result == NSOrderedDescending || result == NSOrderedSame) {
        //开始时间不能晚于结束时间
        return;
    }
    if (passwd.length != 6) {
        //需要6位数字密码
        return;
    }
    endTime = [NSString stringWithFormat:@"%@:00",endTime];
    startTime = [NSString stringWithFormat:@"%@:00",startTime];
    
    char cfg[1024];
    sprintf(cfg, "{ \"Name\" : \"OPDoorLockProCmd\", \"SessionID\" : \"0x00000002\", \"OPDoorLockProCmd\" : {\"Cmd\" : \"SetTmpPasswd\", \"Arg1\" : \"%s\", \"TempPasswd\" : [{\"EndTime\" : \"%s\", \"Passwd\" : \"%s\", \"StartTime\" : \"%s\", \"VaildNum\" : %d}]} }",SZSTR(DoorLockID),SZSTR(endTime),SZSTR(passwd),SZSTR(startTime),number);
    FUN_DevCmdGeneral(self.MsgHandle, SZSTR(channel.deviceMac), 2046, "SetTmpPasswd", 0, 20000, (char *)cfg, (int)strlen(cfg) + 1, -1, 10);
}
#pragma mark - funsdk
-(void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:{
            if (msg->param1 < 0) {
                //获取失败
                if ([self.delegate respondsToSelector:@selector(tempPasswordConfigGetResult:)]) {
                    [self.delegate tempPasswordConfigGetResult:msg->param1];
                }
            } else {
                if (msg->param3 == 2046) {
                    NSString *cmdName = [NSString stringWithUTF8String:msg->szStr];
                    NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    NSLog(@"msg->pObject = %s",msg->pObject);
                    NSError *error;
                    NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                    if (!retDic) {
                        if ([self.delegate respondsToSelector:@selector(tempPasswordConfigGetResult:)]) {
                            [self.delegate tempPasswordConfigGetResult:msg->param1];
                        }
                        return;
                    }
                    int ret = [retDic[@"Ret"] intValue];
                    if (ret != 100) {
                        //失败
                        if ([self.delegate respondsToSelector:@selector(tempPasswordConfigGetResult:)]) {
                            [self.delegate tempPasswordConfigGetResult:msg->param1];
                        }
                    } else {
                        if ([cmdName isEqualToString:@"GetAllDevList"]) {
                            NSArray *devArr = retDic[@"GetAllDevList"];
                            DoorLockID = [[devArr objectAtIndex:0] objectForKey:@"DoorLockID"];
                            NSMutableArray *tempPasswdArray = [[devArr objectAtIndex:0] objectForKey:@"TempPasswd"];
                            if (![tempPasswdArray isEqual:[NSNull null]] ) {
                                NSMutableDictionary *tempPasswdDic = [tempPasswdArray objectAtIndex:0];
                                if (tempPasswdDic) {
                                    number = [[tempPasswdDic objectForKey:@"VaildNum"] intValue];
                                    passwd = [tempPasswdDic objectForKey:@"Passwd"];
                                    endTime = [tempPasswdDic objectForKey:@"EndTime"];
                                    if (endTime.length > 19) {
                                        endTime = [endTime substringToIndex:19];
                                    }
                                    startTime = [tempPasswdDic objectForKey:@"StartTime"];
                                    if (startTime.length > 19) {
                                        startTime = [startTime substringToIndex:19];
                                    }
                                }
                            }
                            if ([self.delegate respondsToSelector:@selector(tempPasswordConfigGetResult:)]) {
                                [self.delegate tempPasswordConfigGetResult:msg->param1];
                            }
                        }
                        else if ([cmdName isEqualToString:@"SetTmpPasswd"]) {
                            if ([self.delegate respondsToSelector:@selector(tempPasswordConfigSetResult:)]) {
                                [self.delegate tempPasswordConfigSetResult:msg->param1];
                            }
                        }
                    }
                }
            }
        }
    }
}

 #pragma mark - 读取获取到的密码信息
- (int)getPasswordNumber { //密码有效次数
    return number;
}
- (NSString*)getPassword { //密码
    return passwd;
}
- (NSString*)getStartTime { //生效时间
    return startTime;
}
- (NSString*)getEndTime { //失效时间
    return endTime;
}

#pragma mark - 设置临时密码
- (void)setPasswordNumber:(int)num { //密码有效次数
    number = num;
}
- (void)setPassword:(NSString*)password { //密码
    passwd = password;
}
- (void)setStartTime:(NSString*)start { //生效时间
    startTime = start;
}
- (void)setEndTime:(NSString*)end { //失效时间
    endTime = end;
}
@end
