//
//  SensorDeviceModel.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/3/29.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "SensorDeviceModel.h"

@implementation SensorDeviceModel

- (instancetype)init{
    self = [super init];
    if (self) {
        self.ifOnline = NO;
    }
    
    return self;
}

- (NSMutableDictionary *)dicListInfo{
    if (!_dicListInfo) {
        _dicListInfo = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return _dicListInfo;
}

- (NSMutableDictionary *)dicStatusInfo{
    if (!_dicStatusInfo) {
        _dicStatusInfo = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return _dicStatusInfo;
}

@end
