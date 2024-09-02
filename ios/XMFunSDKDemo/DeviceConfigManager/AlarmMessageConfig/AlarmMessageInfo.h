//
//  AlarmMessageInfo.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/12/1.
//  Copyright © 2018 wujiangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Path.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlarmMessageInfo : NSObject

@property (nonatomic,copy) NSString *alarmContent;
@property (nonatomic,assign) BOOL bSelected;

+ (AlarmMessageInfo *)shareInstance;

- (NSString *)jsonStr;
- (void)parseJsonData:(NSData*)data;
- (NSString*)getChannel;
- (NSString*)getEvent;
- (NSString*)getStartTime;
- (NSString*)getStatus;
- (NSString*)getPicSize;
- (NSString*)getuId;
- (NSString*)getExtInfo;
- (NSString*)getSessionID;
- (NSString *)getPushMSG;
- (NSString *)getPushMSGType;

@end

NS_ASSUME_NONNULL_END
