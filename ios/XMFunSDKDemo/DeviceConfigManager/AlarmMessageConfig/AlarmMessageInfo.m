//
//  AlarmMessageInfo.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/12/1.
//  Copyright © 2018 wujiangbo. All rights reserved.
//

#import "AlarmMessageInfo.h"

@implementation AlarmMessageInfo
{
    NSDictionary *_json;
}
static AlarmMessageInfo* sharedJson = nil;

+ (AlarmMessageInfo *)shareInstance
{
    @synchronized(self)
    {
        if (sharedJson == nil) {
            sharedJson = [[AlarmMessageInfo alloc]init];
        }
        return sharedJson;
    }
}

- (NSString *)jsonStr{
    if (_json) {
        return [self convertToJSONData:_json];
    }
    
    return @"";
}

-(NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

- (void)parseJsonData:(NSData*)data
{
    NSError *error;
    if (data == nil) {
        return ;
    }
    _json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
}

- (NSString*)getChannel
{
    if (_json == nil) {
        return nil;
    }
    
    NSDictionary *dictonary = [_json objectForKey:@"AlarmInfo"];
    return [dictonary objectForKey:@"Channel"];
}

- (NSString*)getEvent
{
    if (_json == nil) {
        return nil;
    }
    
    NSDictionary *dictonary = [_json objectForKey:@"AlarmInfo"];
    const char * a =[[dictonary objectForKey:@"Event"] UTF8String];
    return [NSString stringWithUTF8String:a];
}

- (NSString*)getExtInfo
{
    if (_json == nil) return nil;
    
    NSDictionary *dictonary = [_json objectForKey:@"AlarmInfo"];
    NSString *extInfo = [dictonary objectForKey:@"ExtInfo"];
    
    if (extInfo.length > 0) {
        NSArray *infos = [extInfo componentsSeparatedByString:@","];
        if (infos.count >=3) {
            return infos[2];
        }
    }
    return extInfo;
}

- (NSString *)getPushMSG{
    if (_json == nil) return nil;
    
    NSDictionary *dictonary = [_json objectForKey:@"AlarmInfo"];
    NSDictionary *extInfo = [dictonary objectForKey:@"ExtInfo"];
    
    if ([extInfo isKindOfClass:[NSDictionary class]]) {
        return [extInfo objectForKey:@"Msg"];
    }
    else{
        return extInfo;
    }
    
    return @"Unknow message";
}

- (NSString *)getPushMSGType {
    if (_json == nil) return nil;
    
    NSDictionary *dictonary = [_json objectForKey:@"AlarmInfo"];
    NSDictionary *extInfo = [dictonary objectForKey:@"ExtInfo"];
    
    if ([extInfo isKindOfClass:[NSDictionary class]]) {
        return [extInfo objectForKey:@"MsgType"];
    }
    else{
        return extInfo;
    }
    
    return @"Unknow message";
}

- (NSString*)getStartTime
{
    if (_json == nil) {
        return nil;
    }
    
    NSDictionary *dictonary = [_json objectForKey:@"AlarmInfo"];
    return [dictonary objectForKey:@"StartTime"];
}

- (NSString*)getStatus
{
    if (_json == nil) {
        return nil;
    }
    
    NSDictionary *dictonary = [_json objectForKey:@"AlarmInfo"];
    const char * a =[[dictonary objectForKey:@"Status"] UTF8String];
    return TS(a);
}

- (NSString*)getPicSize{
    if (_json == nil) {
        return 0;
    }
    return [_json objectForKey:@"picSize"];
}

- (NSString*)getuId
{
    if (_json == nil) {
        return nil;
    }
    return [_json objectForKey:@"ID"];
}

- (NSString*)getSessionID
{
    if (_json == nil) {
        return nil;
    }
    return [_json objectForKey:@"SessionID"];
}

- (NSString*)getName
{
    if (_json == nil) {
        return nil;
    }
    return [_json objectForKey:@"Name"];
}

- (NSDictionary *)getDicinfoSelf{
    if (_json) {
        return _json;
    }
    
    return nil;
}

@end
