//
//  NSDate+Ex.h
//  XWorld
//
//  Created by liuguifang on 16/6/25.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Ex)

- (NSString *)xm_string;

-(NSString*)dateString;

-(NSString*)timeString;

-(NSString*)dateTimeString;

-(NSDateComponents*)currentCompent;

+(NSDate*)dateWithDateString:(NSString*)dateStr;

+(NSDate*)dateWithTimeString:(NSString*)timeStr;

+(NSDate*)dateWithDateTimeString:(NSString*)dateTimeStr;

@end
