//
//  FunSDKBaseViewController.h
//   
//
//  Created by Tony Stark on 2021/6/17.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceConfig;

NS_ASSUME_NONNULL_BEGIN

@interface FunSDKBaseViewController : UIViewController

@property (nonatomic, copy) NSString* devID;
@property (nonatomic, assign) int channelNum;
@property (nonatomic) NSMutableArray* arrayCfgReqs;

#pragma mark - 请求获取配置
-(void)requestGetConfig:(DeviceConfig*)config;

#pragma mark - 请求设置配置
-(void)requestSetConfig:(DeviceConfig*)config;

#pragma mark - 对象注销前调用
-(void)cleanContent;

@end

NS_ASSUME_NONNULL_END
