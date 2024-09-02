//
//  DeviceObject.m
//  XMEye
//
//  Created by XM on 2018/4/13.
//  Copyright © 2018年 Megatron. All rights reserved.
//

#import "DeviceObject.h"

@implementation DeviceObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _deviceMac = @"";
        _deviceName = @"";
        _loginName = @"admin";
        _loginPsw = @"";
        _nPort = 34567;
        _nType = 0;
        _nID = 0;
        _state = -1;
        _eFunDevStateNotCode = -1;
        _channelArray = [[NSMutableArray alloc] initWithCapacity:0];
        _info = [[ObSysteminfo alloc] init];
        _sysFunction = [[ObSystemFunction alloc] init];
    }
    return self;
}

-(BOOL)getDeviceTypeLowPowerConsumption{
    if (self.nType == XM_DEV_DOORBELL || self.nType == XM_DEV_CAT || self.nType == CZ_DOORBELL || self.nType == XM_DEV_INTELLIGENT_LOCK || self.nType == XM_DEV_LOW_POWER || self.nType == XM_DEV_DOORLOCK_V2 || self.nType == XM_DEV_LOCK_CAT) {
        return YES;
    }else{
        return NO;
    }
}
@end
