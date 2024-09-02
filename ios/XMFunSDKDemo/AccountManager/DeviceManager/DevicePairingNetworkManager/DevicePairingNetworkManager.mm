//
//  DevicePairingNetworkManager.m
//   iCSee
//
//  Created by Tony Stark on 2023/2/9.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "DevicePairingNetworkManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"

@interface DevicePairingNetworkManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,copy) NSString *devID;

@end
@implementation DevicePairingNetworkManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge LP_WND_OBJ)self);
    }
    
    return self;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

//MARK: 查询设备特征校验码(CloudCryNum)
- (void)requestCloudCryNum:(NSString *)devID completed:(GetCloudCryNumCallBack)completion{
    self.devID = devID;
    self.getCloudCryNumCallBack = completion;
    
    NSString *cfgName = @"GetCloudCryNum";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1020, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1020);
}

- (void)sendGetCloudCryNumResult:(int)result value:(NSString *)value{
    if (self.getCloudCryNumCallBack) {
        self.getCloudCryNumCallBack(result, value);
    }
}

-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            if (msg->seq == 1020) {
                if (msg->param1 >= 0) {
                    NSDictionary *jsonDic = [NSDictionary dictionaryFromData:msg->pObject];
                    if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dicInfo = [jsonDic objectForKey:@"GetCloudCryNum"];
                        if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
                            NSString *crynum = [dicInfo objectForKey:@"CloudCryNum"];
                            [self sendGetCloudCryNumResult:1 value:crynum];
                            return;
                        }
                    }
                }
                
                [self sendGetCloudCryNumResult:-1 value:@""];
            }
        }
            break;
        default:
            break;
    }
}
@end
