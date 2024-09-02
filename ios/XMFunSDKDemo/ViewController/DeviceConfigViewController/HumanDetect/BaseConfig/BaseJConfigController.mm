//
//  BaseJConfigController.m
//  XWorld
//
//  Created by liuguifang on 16/6/3.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import "BaseJConfigController.h"
#import "ConfigModel.h"

@implementation BaseJConfigController

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


#pragma mark - 界面消失后要取消接收该消息
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    for ( NSNumber* num in self.arrayCfgReqs) {
        [[ConfigModel sharedConfigModel] cancelConfig:[num intValue]];
    }
}

@end
