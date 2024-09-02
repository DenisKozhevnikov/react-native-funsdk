//
//  DoubleEyesManager.m
//  FunSDKDemo
//
//  Created by feimy on 2024/2/22.
//  Copyright © 2024 feimy. All rights reserved.
//

#import "DoubleEyesManager.h"
#import "FunSDK/FunSDK.h"

@implementation DoubleEyesManager


//MARK: 云台快速定位 （点击画面中的某个位置后，镜头转到对应的位置）
- (void)requestSetPTZDeviceID:(NSString *)devID channel:(int)channel xOffset:(int)xOffset yOffset:(int)yOffset zoomScale:(float)scale completed:(DoubleEyesSetPTZOffsetCallBack)completion{
    self.devID = devID;
    self.channel = channel;
    self.doubleEyesSetPTZOffsetCallBack = completion;

    NSString *cmdName = @"OPPtzLocate";
    if (channel >= 0) {
        cmdName = [NSString stringWithFormat:@"%@.[%i]",cmdName,channel];
    }
    NSDictionary *dic = @{@"Name":cmdName,cmdName:@[@{@"xoffset":[NSNumber numberWithInt:xOffset],@"yoffset":[NSNumber numberWithInt:yOffset],@"zoomScale":[NSNumber numberWithFloat:scale]}]};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    FUN_DevCmdGeneral(self.MsgHandle, CSTR(self.devID), 3032, cmdName.UTF8String, -1, 5000, cfg, (int)strlen(cfg) + 1);
}

- (void)OnFunSDKResult:(NSNumber *)pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:{
            if (strcmp(msg->szStr, "OPPtzLocate") == 0){
                if (self.doubleEyesSetPTZOffsetCallBack) {
                    self.doubleEyesSetPTZOffsetCallBack(msg->param1);
                    self.doubleEyesSetPTZOffsetCallBack = nil;
                }
            }
        }
            break;
        default:
            break;
    }
}

@end
