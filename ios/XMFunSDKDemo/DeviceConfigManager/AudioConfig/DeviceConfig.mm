//
//  DeviceConfig.m
//  XWorld
//
//  Created by liuguifang on 16/5/23.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import "DeviceConfig.h"


@implementation DeviceConfig

-(instancetype)init{
    
    self.channel = -1;
    self.devId = @"Unknow";
    self.isGet = YES;
    self.isSet = YES;
    self.name = nil;
    self.jLastStrCfg = nil;
    self.jObject = NULL;
    self.delegate = nil;
    self.nCfgCommand = 0;
    self.nBinary = 1024;
    return self;
}

-(instancetype)initWithJObject:(JObject*)jobject{
    id obj = [self init];
    if ( jobject ) {
        self.jObject = jobject;
        self.name = OCSTR(jobject->Name());
    }
    return obj;
}

+(DeviceConfig *)initWith:(NSString*)devId Channel:(int)Channel GetSet:(int)nGetSet Resutl:(JObject *)pResult Delegate:(id)Delegate{
    DeviceConfig* devCfg = [[DeviceConfig alloc] initWithJObject:pResult];
    devCfg.devId = devId;
    devCfg.channel = Channel;
    devCfg.isGet = (nGetSet & 0x1) != 0;
    devCfg.isSet = (nGetSet & 0x2) != 0;
    devCfg.delegate = Delegate;
    return devCfg;
}

@end
