//
//  FunSDKBaseObject.h
//   
//
//  Created by Tony Stark on 2021/6/16.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DeviceConfig;

NS_ASSUME_NONNULL_BEGIN

@interface FunSDKBaseObject : NSObject

@property (nonatomic, copy) NSString* devID;
@property (nonatomic, assign) int  channelNumber;
@property (nonatomic, copy) NSString *cfgName;
@property (nonatomic, strong) NSMutableArray* arrayCfgReqs;
@property (nonatomic, assign) int msgHandle;
//MARK: 是否需要透传
@property (nonatomic, assign) BOOL needPenetrate;

- (id)initWithDevice:(NSString*)deviceID channel:(int)channelNumber;
#pragma mark - 请求获取配置
-(void)requestGetConfig:(DeviceConfig*)config;

#pragma mark - 请求设置配置
-(void)requestSetConfig:(DeviceConfig*)config;

#pragma mark - 对象注销前调用
-(void)cleanContent;

@end

NS_ASSUME_NONNULL_END
