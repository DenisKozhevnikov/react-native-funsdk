//
//  ShareModel.m
//  XWorld
//
//  Created by liuguifang on 16/6/29.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import "ShareModel.h"
#import <FunSDK/FunSDK2.h>
//#import "AppDelegate.h"
#import "DeviceManager.h"

@implementation ShareModel

static NSString *const kUrlHead = @"https://d.xmeye.net";

+(NSString*)encodeDevId:(NSString*)devId userName:(NSString*)username password:(NSString*)pwd type:(int)type{
    char szDevInfo[512] = {0};
    FUN_EncDevInfo(szDevInfo, [devId UTF8String],[username UTF8String] , [pwd UTF8String], type);
    return [NSString stringWithUTF8String:szDevInfo];
}

+(NSArray*)decodeDevInfo:(NSString*)info{
    char szDevId[256] = {0};
    char szUserName[64] = {0};
    char szPassword[80] = {0};
    int nType = 0;
    int time = 0;
    FUN_DecDevInfo([info UTF8String], szDevId, szUserName, szPassword, nType, time);
    NSArray* array = [[NSArray alloc] initWithObjects:[NSString stringWithUTF8String:szDevId], [NSString stringWithUTF8String:szUserName], [NSString stringWithUTF8String:szPassword], [NSString stringWithFormat:@"%d", nType], [NSString stringWithFormat:@"%d", time], nil];
    return array;
}


+(NSString *)convertToJsonData:(NSDictionary *)dict

{

    NSError *error;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

    NSString *jsonString;

    if (!jsonData) {

        NSLog(@"%@",error);

    }else{

        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格

    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符

    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;

}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}





@end
