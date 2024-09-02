//
//  StorageSnapshotCfgManager.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/21.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "StorageSnapshotCfgManager.h"
#import "Storage_Snapshot.h"
#import "DeviceConfig.h"

@interface StorageSnapshotCfgManager () <DeviceConfigDelegate>
{
    JObjArray <Storage_Snapshot> jStorage_Snapshot; // 拍照本地存储
}
@end

@implementation StorageSnapshotCfgManager

//MARK:请求拍照本地存储配置
- (void)requestStorageSnapshotCfg:(NSString *)devID completion:(GetStorageSnapshotCallBack)callBack{
    self.getStorageSnapshotCallBack = callBack;
    self.devID = devID;
    
    jStorage_Snapshot.SetName(JK_Storage_Snapshot);
    DeviceConfig *devCfg = [[DeviceConfig alloc] initWithJObject:&jStorage_Snapshot];
    devCfg.devId = self.devID;
    devCfg.channel = -1;
    devCfg.isGet = YES;
    devCfg.delegate = self;
    [self requestGetConfig:devCfg];
}

//MAKR:保存拍照本地存储配置
- (void)saveStorageSnapshotCfgCompletion:(SetStorageSnapshotCallBack)callBack{
    self.setStorageSnapshotCallBack = callBack;
    
    DeviceConfig *devCfg = [[DeviceConfig alloc] initWithJObject:&jStorage_Snapshot];
    devCfg.devId = self.devID;
    devCfg.channel = -1;
    devCfg.isSet = YES;
    devCfg.delegate = self;
    [self requestSetConfig:devCfg];
}

//MARK:获取设置拍照本地存储状态
- (NSString *)getStorageSnapshotMode{
    if (!self.requested) {
        return @"";
    }
    return [NSString stringWithUTF8String:jStorage_Snapshot[0].SnapMode.Value()];
}

- (void)setStorageSnapshotMode:(NSString *)mode{
    if (!self.requested) {
        return;
    }
    jStorage_Snapshot[0].SnapMode.SetValue(mode.UTF8String);
}

//MARK: - Delegate
- (void)getConfig:(DeviceConfig *)config result:(int)result{
    if ([config.name isEqualToString:OCSTR(JK_Storage_Snapshot)])
    {
        if (result >= 0) {
            self.requested = YES;
        }
        
        if (self.getStorageSnapshotCallBack) {
            self.getStorageSnapshotCallBack(result);
        }
    }
}

- (void)setConfig:(DeviceConfig *)config result:(int)result{
    if ([config.name isEqualToString:OCSTR(JK_Storage_Snapshot)])
    {
        if (self.setStorageSnapshotCallBack) {
            self.setStorageSnapshotCallBack(result);
        }
    }
}

@end
