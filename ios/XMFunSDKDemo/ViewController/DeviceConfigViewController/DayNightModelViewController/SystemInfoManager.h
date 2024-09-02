//
//  SystemInfoManager.h
//  XMEye Pro
//
//  Created by 杨翔 on 2022/4/21.
//  Copyright © 2022 Megatron. All rights reserved.
//

#import "FunSDKBaseObject.h"

typedef void(^GetSystemInfoBlock)(int result);

@interface SystemInfoManager : FunSDKBaseObject

@property (nonatomic, copy) GetSystemInfoBlock getSystemInfo;

-(void)getSystemInfo:(NSString *)devId Completion:(GetSystemInfoBlock)completion;
/** 获取设备system info */
+ (void)fetchDevSystemInfoWithDevId:(NSString *)devId completion:(void(^)(NSDictionary *responseDic, NSInteger errCode))completion;

//是否带有模拟通道的设备
-(BOOL)videoInChannel;

//是否是模拟通道
-(BOOL)channelIsContainVideo:(int)channel;
@end
