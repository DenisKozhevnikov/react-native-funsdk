//
//  StorageSnapshotCfgManager.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/21.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFunSDKObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GetStorageSnapshotCallBack)(int result);
typedef void(^SetStorageSnapshotCallBack)(int result);

/*
 拍照本地存储配置
 
 mode:ClosedSnap ManualSnap
 */
@interface StorageSnapshotCfgManager : CYFunSDKObject

@property (nonatomic,copy) GetStorageSnapshotCallBack getStorageSnapshotCallBack;
@property (nonatomic,copy) SetStorageSnapshotCallBack setStorageSnapshotCallBack;

@property (nonatomic,assign) BOOL requested;

//MARK:请求拍照本地存储配置
- (void)requestStorageSnapshotCfg:(NSString *)devID completion:(GetStorageSnapshotCallBack)callBack;
//MAKR:保存拍拍照本地存储配置
- (void)saveStorageSnapshotCfgCompletion:(SetStorageSnapshotCallBack)callBack;

//MARK:获取设置拍照本地存储配置状态
- (NSString *)getStorageSnapshotMode;
- (void)setStorageSnapshotMode:(NSString *)mode;

@end

NS_ASSUME_NONNULL_END
