//
//  FunSDKBaseObject.m
//   
//
//  Created by Tony Stark on 2021/6/16.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "FunSDKBaseObject.h"
#import <FunSDK/XTypes.h>
#import "ConfigModel.h"
#import "DeviceConfig.h"

@implementation FunSDKBaseObject

- (id)initWithDevice:(NSString*)deviceID channel:(int)channelNumber {
    self = [super init];
    if (self) {
        self.arrayCfgReqs = [[NSMutableArray alloc] initWithCapacity:8];
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
        self.devID = deviceID;
        self.channelNumber = channelNumber;
    }
    return self;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        self.arrayCfgReqs = [[NSMutableArray alloc] initWithCapacity:8];
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
        self.channelNumber = -1;
    }
    
    return self;
}

#pragma mark - 请求获取配置
-(void)requestGetConfig:(DeviceConfig*)config{
    int nSeq = [[ConfigModel sharedConfigModel] requestGetConfig:config];
    [self.arrayCfgReqs addObject:[[NSNumber alloc] initWithInt:nSeq]];
}

#pragma mark - 请求设置配置
-(void)requestSetConfig:(DeviceConfig*)config{
    int nSeq = [[ConfigModel sharedConfigModel] requestSetConfig:config];
    [self.arrayCfgReqs addObject:[[NSNumber alloc] initWithInt:nSeq]];
}


#pragma mark - 对象注销前调用
-(void)cleanContent{
    for ( NSNumber* num in self.arrayCfgReqs) {
        [[ConfigModel sharedConfigModel] cancelConfig:[num intValue]];
    }
}

- (void)dealloc{
    [self cleanContent];
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    //需要处理特殊错误值 -70150 返回该错误时需要提示用户设置成功 需要重启生效
    if (msg->param1 == -70150 ||msg->param1 == -11401) {
        msg->param1 = abs(msg->param1);
        
//        [TipsManager markNeedRobootTipAfterSetConfig:YES];
    }
    
    //特殊处理 部分特殊设备登录和请求保存配置时，密码错误会回调-11318，而DSS预览时密码错误又会回调-11301，目前需要增加对-11318密码错误的适配.
    if (msg->param1 == -11318) {
        msg->param1 = -11301;
    }
    
    try {
        // TODO: 应该是数据格式错误导致
        [self baseOnFunSDKResult:msg];
    } catch (NSException *exception) {
//        XMLog(@"发生了异常：\n name:%@ \n reason:%@ \n userInfo:%@", exception.name, exception.reason, exception.userInfo);
    }
}

- (void)baseOnFunSDKResult:(MsgContent *)msg{
    
}

@end
