//
//  ElectricityConfig.m
//  FunSDKDemo
//
//  Created by zhang on 2019/5/10.
//  Copyright © 2019 zhang. All rights reserved.
//

#import "ElectricityConfig.h"

@implementation ElectricityConfig

#pragma mark 开始上报设备状态
- (void)startUploadElectricity {
    
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    //直接用GetConfig方法获取的可能会不准确，使用下面设备主动上报的方式获取的电量实时性最高
    //FUN_DevGetConfig_Json(self.msgHandle, [channel.deviceMac UTF8String], "Dev.ElectCapacity", 1024,-1,5000,0);
    //设置主动上报设备状态
    FUN_DevStartUploadData(self.msgHandle, [channel.deviceMac UTF8String], 5, 0);
    
}

#pragma mark 停止设备上报状态
- (void)stopUploadElectricity {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    FUN_DevStopUploadData(self.msgHandle, [channel.deviceMac UTF8String], 5, 0);
}

-(void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON: {
            if (strcmp("Dev.ElectCapacity", msg->szStr) == 0){
                //通过json配置获取电量，实时性没有设备上报高
            }
        }
            break;
        case EMSG_DEV_START_UPLOAD_DATA:{
            //开始上报
            if ([self.delegate respondsToSelector:@selector(startUploadElectricityResult:)]) {
                [self.delegate startUploadElectricityResult:msg->param1];
            }
        }
            break;
        case EMSG_DEV_STOP_UPLOAD_DATA: {
            //停止上报
            if ([self.delegate respondsToSelector:@selector(stopUploadElectricityResult:)]) {
                [self.delegate stopUploadElectricityResult:msg->param1];
            }
            
        }
            break;
        case EMSG_DEV_ON_UPLOAD_DATA: {
            //设备状态上报回调 （开启之后，每一段时间设备会自动上报给APP）
            if (msg->param1 > 0) {
                NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                
                NSError *error;
                NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                if (!retDic) {
                    return;
                }
                NSDictionary *dicState = [retDic objectForKey:@"Dev.ElectCapacity"];
                ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
                if ([NSSTR(msg->szStr) isEqualToString:channel.deviceMac]) {
                    if([[dicState objectForKey:@"electable"] isKindOfClass:[NSNull class]]){
                        return;
                    }
                    //electable表示充电状态：0：未充电 1：正在充电 2：电充满 3：未知（表示各数据不准确）
                    if ([[dicState objectForKey:@"electable"] intValue] != 3) {
                        //获取设备电量成功，如果只需要获取一次，可以在这里调用停止设备电量上报
                        self.percent = [[dicState objectForKey:@"percent"] intValue];
                        self.electable = [[dicState objectForKey:@"electable"] intValue];
                        
                        if (self.percent <= 5 && self.electable != 1) {
                            //电量少于5%，并且未充电，可以提示电量极低，请充电
                        }
                    }
                    //存储状态： -2：设备存储未知 -1：存储设备被拔出 0：没有存储设备 1：有存储设备 2：存储设备插入
                    self.storageStatus = [[dicState objectForKey:@"DevStorageStatus"] intValue];
                    
                }else{
                    //未知
                }
            }else{
                //获取失败
            }
            if ([self.delegate respondsToSelector:@selector(deviceUploadElectricityResult:)]) {
                [self.delegate deviceUploadElectricityResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}
@end
