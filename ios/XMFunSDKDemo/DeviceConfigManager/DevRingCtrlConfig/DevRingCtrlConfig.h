//
//  DevRingCtrlConfig.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/5/7.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DevRingCtrlConfigDelegate <NSObject>

@optional

- (void)getDevRingCtrlConfigResult:(NSInteger)result;
- (void)setDevRingCtrlConfigResult:(NSInteger)result;

@end

/*
 设备警铃设置
 */

@interface DevRingCtrlConfig : NSObject

@property (nonatomic,weak) id<DevRingCtrlConfigDelegate>delegate;

- (void)myGetConfig;
- (void)mySetConfig;

//MARK: 获取开关状态
- (BOOL)getEnable;
//AMRK: 设置开关状态
- (void)setEnable:(BOOL)enable;;

@end

NS_ASSUME_NONNULL_END
