//
//  ChannelTitleConfig.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2020/10/26.
//  Copyright © 2020 wujiangbo. All rights reserved.
//
/******
 *
 * 设备通道修改功能
 *1、根据通道号获取对应通道信息
 *2、根据修改的通道名称进行修改
 ******/
#import <Foundation/Foundation.h>
#import "CYFunSDKObject.h"
#import "ConfigControllerBase.h"
#import "AVEnc_VideoWidget.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChannelTitleConfigDelegate <NSObject>

@optional

//获取通道名称回调
-(void)getChannelTitleConfigResult:(NSInteger)result;

//设置通道名称回调
-(void)setChannelTitleConfigResult:(NSInteger)result;

@end

@interface ChannelTitleConfig : ConfigControllerBase

@property (nonatomic, assign) id <ChannelTitleConfigDelegate> delegate;

@property (nonatomic, strong) NSString *devID;         // 设备id
@property (nonatomic) int channelNum;                  // 选中通道号

#pragma mark - 获取通道信息
- (void)getLogoConfigWithChannel:(int)channel;
#pragma mark - 读取通道名称
- (NSString*)readLogoTitle;
#pragma mark - 设置通道名称
- (void)setLogoTitle:(NSString *)title;
#pragma mark - 保存设置
- (void)setLogoConfig;

@end

NS_ASSUME_NONNULL_END
