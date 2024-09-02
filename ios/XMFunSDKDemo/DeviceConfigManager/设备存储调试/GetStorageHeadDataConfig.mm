//
//  GetStorageHeadDataConfig.m
//  XMEye
//
//  Created by zhang on 2019/6/10.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "GetStorageHeadDataConfig.h"
#import <FunSDK/FunSDK.h>

@interface GetStorageHeadDataConfig()
{
}
@property UI_HANDLE hWnd;
@property void * pWnd;


@end

@implementation GetStorageHeadDataConfig


- (instancetype)init {
    self = [super init];
    if (self) {
        self.pWnd = (__bridge void *) self;
        self.hWnd = FUN_RegWnd(_pWnd);
    }
    return self;
}

- (void)getStorageHeadDataConfig:(NSString*)offset {
    
    char szParam[128] = {0};
    sprintf(szParam, "{\"Name\":\"GetStorageHeadData\",\"GetStorageHeadData\":{\"Offset\":%d}}",[offset intValue]);
    
    FUN_DevCmdGeneral(self.hWnd, [self.deviceMac UTF8String], 2350, "GetStorageHeadData", 0, 5000,szParam,0,-1,0);
}

#pragma mark - FUNSDK 回调
-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:{
            if (msg->param1 >= 0) {
                //成功时返回数据二进制
                NSData *datatest = [NSData dataWithBytes:msg->pObject length:msg->param2];
                [datatest writeToFile:[NSString tempZipPath:self.deviceMac] atomically:YES];
            }else{
                //失败时返回json数据，里面信息是失败原因
                NSString *errorString;
                if (msg->pObject == nil) {
                    errorString = @"";
                }else{
                    errorString = [NSString stringWithUTF8String:msg->pObject];
                    if (errorString == nil) {
                        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                        NSData *data = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                        errorString = [[NSString alloc] initWithData:data encoding:enc];
                    }
                    if (errorString == nil) {
                        errorString = @"";
                    }
                }
            }
            if (self.getHeaderDataBlock) {
                self.getHeaderDataBlock(msg->param1);
            }
        }
            break;
    }
}


@end
