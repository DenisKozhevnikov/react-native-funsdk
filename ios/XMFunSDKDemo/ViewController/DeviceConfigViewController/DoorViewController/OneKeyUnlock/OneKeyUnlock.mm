//
//  OneKeyUnlock.m
//  FunSDKDemo
//
//  Created by plf on 2022/6/23.
//  Copyright © 2022 plf. All rights reserved.
//

#import "OneKeyUnlock.h"
#import <FunSDK/FunSDK.h>
#import <FunSDK/FunSDK2.h>

@interface OneKeyUnlock ()

@end

@implementation OneKeyUnlock


+(instancetype)shareInstance{
    static OneKeyUnlock *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[OneKeyUnlock alloc] init];
    });
    return manager;
}

-(void)oneKeyUnlock
{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    const char *str = "{\"SessionID\":\"0x00000001\",\"Name\":\"OPDoorLockProCmd\",\"OPDoorLockProCmd\":{\"Cmd\":\"RemoteOneKeyUnlock\",\"Arg1\":\"111\",\"Channel\":0,\"Arg2\":\"222\",\"DefenceType\":1}}";
    int code = FUN_DevCmdGeneral(FUN_RegWnd((__bridge LP_WND_OBJ)self), [channel.deviceMac UTF8String], 2046, "RemoteOneKeyUnlock", 0, 0, (char*)str, 0, -1, 0);
}

#pragma mark - FUNSDK 回调
-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:{
            if (msg->param1 >= 0) {
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@%@",TS("TR_One_Key_Unlock"),TS("Success")] ];
            }else{
                [MessageUI ShowErrorInt:(int)msg->param1];
            }
            break;
        }
    }
}

@end
