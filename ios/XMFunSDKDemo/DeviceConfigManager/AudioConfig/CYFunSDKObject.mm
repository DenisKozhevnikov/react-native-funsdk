//
//  CYFunSDKObject.m
//  XWorld_General
//
//  Created by SaturdayNight on 2018/9/11.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import "CYFunSDKObject.h"
#import "ConfigModel.h"
#import "DeviceConfig.h"

@implementation CYFunSDKObject

-(instancetype)init{
    id obj = [super init];
    
    self.arrayCfgReqs = [[NSMutableArray alloc] initWithCapacity:8];
    
    return obj;
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
}

@end
