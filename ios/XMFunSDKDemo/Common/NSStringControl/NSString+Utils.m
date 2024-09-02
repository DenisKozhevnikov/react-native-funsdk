//
//  NSString+Utils.m
//  XWorld
//
//  Created by DingLin on 16/5/19.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import "NSString+Utils.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation NSString (Utils)

/// Parse string to date.
NSDate *YYNSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate* (^YYNSDateParseBlock)(NSString *string);
#define kParserNum 32
    static YYNSDateParseBlock blocks[kParserNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /*
             2014-01-20  // Google
             */
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"yyyy-MM-dd";
            blocks[10] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
        }
        
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            blocks[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[24] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
    });
    if (!string) return nil;
    if (string.length > kParserNum) return nil;
    YYNSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
#undef kParserNum
}

+(int)getStringLength:(NSString*)message
{
    int chinese=0;
    for(int i=0; i< [message length];i++){
        int a = [message characterAtIndex:i];
        if( a >= 0x4e00 && a <= 0x9fff)
            chinese++;
    }
    int length=(int)[message length]+chinese;
    return length;
}

+(NSDateComponents*)toComponents:(NSString*)timeString{
    NSDate* date = YYNSDateFromString(timeString);
    if ( !date ) {
        return nil;
    }
    NSCalendar *calendar =[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    
    NSDateComponents *comptBegin = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:date];
    return comptBegin;
}

//MARK:字典转字符串
+(NSString*)convertToJSONData:(id)infoDict
{
    if (!infoDict) {
        return @"";
    }
    
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

+(NSString *)stringWithUTF8String_OutNil:(const char *)nullTerminatedCString
{
    return nullTerminatedCString?[self stringWithUTF8String:nullTerminatedCString]:nil;
}

//MARK:判断设备序列号是否合法
/*
 16位序列号字母a-f和数字0-9组成
 20位序列号字母a-z和数字0-9组成
 */
+(BOOL)legalSN:(NSString *)sn{
    if (sn.length == 16) {
        NSString *regular =  @"^[a-fA-F0-9]{16}$";
        // 创建谓词对象并设定条件的表达式
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
        // 对字符串判断，该方法会返回BOOL值
        if (![numberPre evaluateWithObject:sn]) {
            return NO;
        }else{
            return YES;
        }
    }else if (sn.length == 20){
        NSString *regular =  @"^[a-zA-Z0-9]{20}$";
        // 创建谓词对象并设定条件的表达式
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
        // 对字符串判断，该方法会返回BOOL值
        if (![numberPre evaluateWithObject:sn]) {
            return NO;
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}

//MARK:序列号脱敏处理
+(NSString *)converSN:(NSString *)sn{
    NSString *result = sn;
    if (sn.length == 16) {
        result = [NSString stringWithFormat:@"%@****%@",[result substringWithRange:NSMakeRange(0, 8)], [result substringWithRange:NSMakeRange(12, 4)]];
    }else if (sn.length == 20){
        result = [NSString stringWithFormat:@"%@****%@",[result substringWithRange:NSMakeRange(0, 12)], [result substringWithRange:NSMakeRange(16, 4)]];
    }
    
    return result;
}

//字符串的字节长度
+ (int)getByteNum:(NSString *)str{
    int strlength = 0;
    char* p = (char*)[str cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[str lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

//通过字节长度截取字符串
+ (NSString *)subStringByByteWithIndex:(NSInteger)index str:(NSString *)str{
    NSInteger sum = 0;
    
    NSString *subStr = [[NSString alloc] init];
    
    for(int i = 0; i<[str length]; i++){
        
        unichar strChar = [str characterAtIndex:i];
        
        if(strChar < 256){
            sum += 1;
        }
        else {
            sum += 2;
        }
        if (sum >= index) {
            
            subStr = [str substringToIndex:i+1];
            return subStr;
        }
 
    }
    
    return str;
}
//  判断字符串是否有效
+ (BOOL)isLegalWithString:(NSString *)string{
    if (string.length <= 0 || !string) return NO;
    if (string == NULL || [string isKindOfClass:[NSNull class]]) return NO;
    if (0 == [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) return NO;
    return YES;
}

+ (CGSize)getSizeWithContent:(NSString *)content{
    CGSize size = CGSizeZero;
    if (content.length <= 0) return size;
    CGRect rect = [content boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil];
    size = rect.size;
    return size;
}

+ (CGSize)getSizeWithContent:(NSString *)content limitSize:(CGSize)limitSize{
    CGSize size = CGSizeZero;
    if (content.length <= 0) return size;
    CGRect rect = [content boundingRectWithSize:limitSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil];
    size = rect.size;
    return size;
}

+ (CGSize)getSizeWithContent:(NSString *)content fontValue:(CGFloat)fontValue weight:(CGFloat)weight{
    CGSize size = CGSizeZero;
    if (content.length <= 0) return size;
    CGRect rect = [content boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:(fontValue == 0)?12.0:fontValue weight:weight]} context:nil];
    size = rect.size;
    return size;
}
// MARK: 生成随机码
+ (NSString *)randomStrWithLength:(NSInteger)length{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    length = (length > [letters length])?[letters length]-1:length;
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (NSInteger i = 0; i < length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((u_int32_t)[letters length])]];
    }
    return randomString;
}
//MARK: 计算需要分配的数组大小
+(int)getCharArraySize:(NSString *)content{
    int length = (int)content.length * 2;
    int num = length / 1024;
    if (length % 1024 > 0) {
        num++;
    }
    
    return num * 1024;
}
// MARK: 判断字符串是否相同
- (BOOL)jf_isEqualToStr:(NSString *)str{
    if(!ISLEGALSTR(str)) return NO;
    return [self isEqualToString:str];
}
//MARK: 将NSData转成十六进制字符串
+ (NSString *)xm_hexStringWithData:(NSData *)data{
    if (!data || [data length] == 0) return @"";
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}
// MARK: MAC ADDRESS
+ (NSString *)xm_deviceMacAddress{
    // copy from main project
    NSString *idStr = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            idStr = [dict valueForKey:@"BSSID"];
        }
    }
    return idStr;
}
@end
