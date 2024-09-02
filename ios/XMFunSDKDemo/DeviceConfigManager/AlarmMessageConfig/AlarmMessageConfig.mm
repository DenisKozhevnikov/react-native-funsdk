//
//  AlarmMessageConfig.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/12/1.
//  Copyright © 2018 wujiangbo. All rights reserved.
//

#import "AlarmMessageConfig.h"
#import "FunSDK/Fun_MC.h"
#import "AlarmMessageInfo.h"

@implementation AlarmMessageConfig

#pragma mark - 查找报警缩略图
- (void)searchAlarmThumbnail:(NSString *)uId fileName:(NSString *)fileName
{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    XPMS_SEARCH_ALARMPIC_REQ _req;
    memset(&_req, 0, sizeof(_req));
    STRNCPY(_req.Uuid, SZSTR(channel.deviceMac));
    _req.ID = [uId longLongValue];
    memcpy(_req.Res, "_176x144.jpeg", 32);
    MC_SearchAlarmPic(self.msgHandle, [fileName UTF8String], &_req, 0);
}

#pragma mark - 下载报警缩略图
- (void)downloadAlarmThumbnail:(NSString *)path info:(NSString *)picInfo{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    CGFloat width = SCREEN_WIDTH < SCREEN_HEIGHT ? SCREEN_WIDTH : SCREEN_HEIGHT;

    MC_DownloadAlarmImage(self.msgHandle, [channel.deviceMac UTF8String], [path UTF8String], [picInfo UTF8String], 0, width / 3.0,width / 3.0);
}

#pragma mark - 查找报警图
- (void)searchAlarmPic:(NSString *)uId fileName:(NSString *)fileName
{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    XPMS_SEARCH_ALARMPIC_REQ _req;
    memset(&_req, 0, sizeof(_req));
    STRNCPY(_req.Uuid, SZSTR(channel.deviceMac));
    _req.ID = [uId longLongValue];
    MC_SearchAlarmPic(self.msgHandle, [fileName UTF8String], &_req, 0);
}

#pragma mark - 查询报警消息
-(void)searchAlarmInfo{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    XPMS_SEARCH_ALARMINFO_REQ _req;
    memset(&_req, 0, sizeof(_req));
    STRNCPY(_req.Uuid, SZSTR(channel.deviceMac));
    
    _req.StarTime = [self startTime];
    _req.EndTime = [self endTime];
    _req.Channel = 0;
    _req.Number = 0;
    _req.Index = 0;
    MC_SearchAlarmInfo(self.msgHandle, &_req, 0);
}

//MARK: 下载图片
- (void)downloadImage:(NSString *)path info:(NSString *)picInfo{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    MC_DownloadAlarmImage(self.msgHandle, [channel.deviceMac UTF8String], [path UTF8String], [picInfo UTF8String], 0, 0, 0);
}

- (struct SystemTime)startTime{
    NSDateComponents *components = [self getCurrentComponents];
    
    struct SystemTime startTime;
    memset(&startTime, 0, sizeof(startTime));
    startTime.year = (int)[components year];
    startTime.month = (int)[components month];
    startTime.day = (int)[components day];
    return startTime;
}

- (struct SystemTime)endTime{
    NSDateComponents *components = [self getCurrentComponents];
    
    struct SystemTime endTime;
    memset(&endTime, 0, sizeof(endTime));
    endTime.year = (int)[components year];
    endTime.month = (int)[components month];
    endTime.day = (int)[components day];
    endTime.hour = 23;
    endTime.second = 59;
    endTime.minute = 59;
    return endTime;
}

- (NSDateComponents *)getCurrentComponents{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"YYYY/MM/dd";
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
}

#pragma mark - 删除报警消息
- (void)deleteAlarmMessage:(NSMutableArray *)array{
    [self.deleteAlarmID removeAllObjects];
    [self.fileList removeAllObjects];
    
    self.fileList = [array mutableCopy];
    // 取出需要删除的消息ID，这里长度不能太长 所以每次发送最多限制50个ID
    NSMutableString *items = [NSMutableString stringWithFormat:@""];
    int curNum = 0;
    for (int i = 0; i < self.fileList.count; i ++) {
        AlarmMessageInfo *resourceItem = [self.fileList objectAtIndex:i];
        if (resourceItem.bSelected) {
            
            if (items.length > 0) {
                [items appendFormat:@";%@", [resourceItem getuId]];
            } else {
                items = [[NSMutableString alloc] initWithString:[resourceItem getuId]];
            }
            
            curNum++;
            if (curNum >= 50) {
                curNum = 0;
                [self.deleteAlarmID addObject:items];
                items = [NSMutableString stringWithFormat:@""];
                continue;
            }
            
            if (curNum >= 0 && self.fileList.count == i + 1) {
                [self.deleteAlarmID addObject:items];
                items = [NSMutableString stringWithFormat:@""];
            }
        }
    }

    if (items.length > 0) {
        [self.deleteAlarmID addObject:items];
    }
    if (self.deleteAlarmID.count <= 0) {
        [SVProgressHUD showErrorWithStatus:TS("TR_No_Object_Can_Be_Deleted")];
        return;
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:TS("TR_Delete_Items_Tip") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [SVProgressHUD show];
            ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
            //调用FUNSDK删除报警消息,,alarmID为NULL或空字符串，表示清空;若有多个,以；分割
            MC_Delete(self.msgHandle, CSTR(channel.deviceMac),"MSG", CSTR([self.deleteAlarmID objectAtIndex:0]));
            
        }];
        
        [alert addAction:actionCancel];
        [alert addAction:actionOK];
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - SDK回调
-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_MC_SearchAlarmInfo:{
            if (msg->param1 < 0) {
            }
            else{
                char *pStr = (char *)msg->pObject;
                NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (int i = 0; i < msg->param3; ++i) {
                    NSData *data = [[[NSString alloc]initWithUTF8String:pStr] dataUsingEncoding:NSUTF8StringEncoding];
                    AlarmMessageInfo *json = [[AlarmMessageInfo alloc]init];
                    [json parseJsonData:data];
                    NSString *startTime = [json getStartTime]; //开始时间
                    if (startTime) {
                        [dataArray addObject:json];
                    }
                    
                    pStr += (strlen(pStr) + 1);
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(getAlarmMessageConfigResult:message:)]) {
                    [self.delegate getAlarmMessageConfigResult:msg->param1 message:dataArray];
                }
            }
        }
            break;
        case EMSG_MC_SearchAlarmPic:{
            [SVProgressHUD dismiss];
            if (msg->param1 < 0 &&  msg->param1 != -99988) {
                break;
            }
            //报警图
            NSString *imagePath = [NSString stringWithUTF8String:(char*)msg->szStr];
          
            if (self.delegate && [self.delegate respondsToSelector:@selector(searchAlarmPicConfigResult:imagePath:)]) {
                [self.delegate searchAlarmPicConfigResult:msg->param1 imagePath:imagePath];
            }
        }
            break;
        case EMSG_MC_DeleteAlarm:
        {
            int result = msg->param1;
            if (result < 0) {
                [MessageUI ShowErrorInt:(int)result];
            }
            else{
                [self.deleteAlarmID removeObjectAtIndex:0];
                if (self.deleteAlarmID.count > 0) {
                    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
                    MC_Delete(self.msgHandle, CSTR(channel.deviceMac),"MSG", CSTR([self.deleteAlarmID objectAtIndex:0]));
                }
                else{
                    [SVProgressHUD dismiss];
                    //修改缓存
                    NSMutableArray *fileListCopy = [NSMutableArray arrayWithArray:self.fileList];
                    for (AlarmMessageInfo *resourceItem in fileListCopy) {
                        if (resourceItem.bSelected) {
                            //删除缓存
                            [self.fileList removeObject:resourceItem];
                        }
                    }
                    
                    //修改界面
                    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteAlarmMessageConfigResult:message:)]) {
                        [self.delegate deleteAlarmMessageConfigResult:result message:self.fileList];
                    }
                }
                
                
            }

        }
            break;
        default:
            break;
    }
}

-(NSMutableArray *)deleteAlarmID{
    if (!_deleteAlarmID) {
        _deleteAlarmID = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _deleteAlarmID;
}

-(NSMutableArray *)fileList{
    if (!_fileList) {
        _fileList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _fileList;
}

@end
