//
//  ExtralStateCtrlConfig.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/5/6.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "ExtralStateCtrlConfig.h"
#import "FbExtraStateCtrl.h"

@interface ExtralStateCtrlConfig ()
{
    FbExtraStateCtrl extralStateCtrl;
}

@end

@implementation ExtralStateCtrlConfig

- (void)myGetConfig{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    
    CfgParam* paramsetEnableVideo = [[CfgParam alloc] initWithName:[NSString stringWithUTF8String:extralStateCtrl.Name()] andDevId:channel.deviceMac andChannel:-1 andConfig:&extralStateCtrl andOnce:YES andSaveLocal:NO];
    [self AddConfig:paramsetEnableVideo];
    [self GetConfig];
}

- (void)mySetConfig{
    [self SetConfig];
}


//MARK: 状态灯是否开启
- (int)getIsOn{
    return extralStateCtrl.ison.Value();
}

//MARK: 提示音是否开启
- (int)getVoiceTipEnable{
    return extralStateCtrl.PlayVoiceTip.Value();
}

//MARK: 设置状态灯开关
- (void)setIsOn:(int)isOn{
    extralStateCtrl.ison = isOn;
}
//MARK: 设置提示音开关
- (void)setVoiceTipEnable:(int)enalbe{
    extralStateCtrl.PlayVoiceTip = enalbe;
}

//MARK: - 请求回调
-(void)OnGetConfig:(CfgParam *)param{
     if ([param.name isEqualToString:[NSString stringWithUTF8String:extralStateCtrl.Name()]]) {
         if (self.delegate && [self.delegate respondsToSelector:@selector(getExtralStateCtrlConfigResult:)]) {
             [self.delegate getExtralStateCtrlConfigResult:param.errorCode];
         }
     }
}

-(void)OnSetConfig:(CfgParam *)param {
    if ( [param.name isEqualToString:[NSString stringWithUTF8String:extralStateCtrl.Name()]] ) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(getExtralStateCtrlConfigResult:)]) {
            [self.delegate setExtralStateCtrlConfigResult:param.errorCode];
        }
    }
}

@end
