//
//  NSString+Extention.m
//  XMFamily
//
//  Created by Megatron on 4/24/15.
//  Copyright (c) 2015 Megatron. All rights reserved.
//

#import "NSString+Extention.h"
@implementation NSString (Extention)

+ (NSString *)getTimeStringWihtNumber:(NSInteger)time {
    NSMutableString *result;
    if (time < 10) {
        result = [NSMutableString stringWithFormat:@"00:0%ld",(long)time];
    }
    else if (time <= 60) {
        result = [NSMutableString stringWithFormat:@"00:%ld",(long)time];
    }
    else if (time <1000) {
        result = [NSMutableString stringWithFormat:@"%ld",(long)time];
        [result insertString:@":" atIndex:1];
    }
    else {
        result = [NSMutableString stringWithFormat:@"%ld",(long)time];
        [result insertString:@":" atIndex:2];
    }
    
    return result;
}
//将十进制转化为二进制,设置返回NSString 长度
+ (NSString *)decimalTOBinary:(uint16_t)tmpid backLength:(int)length {
    NSString *a = @"";
    while (tmpid) {
        a = [[NSString stringWithFormat:@"%d",tmpid%2] stringByAppendingString:a];
        if (tmpid/2 < 1) {
            break;
        }
        tmpid = tmpid/2 ;
    }
    
    if (a.length <= length) {
        NSMutableString *b = [[NSMutableString alloc]init];;
        for (int i = 0; i < length - a.length; i++) {
            [b appendString:@"0"];
        }
        a = [b stringByAppendingString:a];
    }
    return a;
}

+ (NSString *)getWeekTimeStringWithBinaryString:(int)num {
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:TS("Monday"),TS("Tuesday"),TS("Wednesday"),TS("Thursday"),TS("Friday"),TS("Saturday"),TS("Sunday"), nil];
    
    NSString *result = @"";
    for (int i = 0; i < 7; ++i) {
        if ((num & 1 << i) != 0) {
            result = [NSString stringWithFormat:@"%@ %@",result,[array objectAtIndex:i]];
        }
    }
    
    return result;
}

#pragma mark 传入一个整数 转化成天时分秒的形式
+ (NSString *)getDHMSStringWithIntNumber:(NSInteger)time {
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:0];
    long nDay,nHour,nMinute,nSecond;
    nDay = time / (24*60*60);
    nHour = (time % (24*60*60)) / (60*60);
    nMinute = ((time % (24*60*60)) % (60*60)) / 60;
    nSecond = ((time % (24*60*60)) % (60*60)) % 60;
    
    NSString *str;
    if (nDay > 0) {
        str = [NSString stringWithFormat:@"%ld%@%ld%@%ld%@%ld%@",nDay,TS("day2"),nHour,TS("hour"),nMinute,TS("minute"),nSecond,TS("s")];
    }
    else if (nHour > 0) {
        str = [NSString stringWithFormat:@"%ld%@%ld%@%ld%@",nHour,TS("hour"),nMinute,TS("minute"),nSecond,TS("s")];
    }
    else if (nMinute > 0) {
        str = [NSString stringWithFormat:@"%ld%@%ld%@",nMinute,TS("minute"),nSecond,TS("s")];
    }
    else if (nSecond > 0) {
        str = [NSString stringWithFormat:@"%ld%@",nSecond,TS("s")];
    }
    
    if (str == nil) {
        str = @"0";
    }
    return [result stringByAppendingString:str];
}

#pragma mark 字典装json
+ (NSString *)dictionaryToJson:(NSDictionary *)dic {
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
+ (NSString *)dictionaryToJsonWithoutWritingPrettyPrinted:(NSDictionary *)dic {
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted/*NSJSONWritingPrettyPrinted 这是带换行符\n的*/ error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

#pragma mark 检测密码格式 密码8-32位必须包含数字和字母
+(BOOL)isValidatePassword:(NSString *)password {
    //密码字符格式
    NSString * regex = @"(?![^a-zA-Z0-9]+$)(?![^a-zA-Z/D]+$)(?![^0-9/D]+$).{8,32}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:password]&&(password.length <= 32)&&(password.length >= 8);
}

#pragma mark 检测邮箱格式
+(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark 检测用户名是否合法 4-32位，由中文/字母/数字组成，但不能是纯数字
+(BOOL)isValidateUserName:(NSString *)userName {
    if (userName.length>0 && userName.length<26)
    {
        return YES;
    }
    return NO;
}

//MARK: 是否匹配设备用户名规则 1. (4-15位长度 包含数字和字母)；2特殊字符user admin
+ (DevicePasswordErrorType)matchDeviceUserNameRule:(NSString *)userName{
    NSString * regex = @"([\u4e00-\u9fa5]|[a-zA-Z0-9_]){4,15}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (![pred evaluateWithObject:userName]) {
        return DPErrorTypeNumberWordLimit;
    }
    
    NSString *containsString = [self containsSpecialCharacterWithUserName:userName];
    if (containsString.length > 0) {
        return DPErrorTypeSpecialCharacters;
    }
    
    return DPErrorTypeNone;
}

//MARK: 用户名特殊字符数组
+ (NSString *)containsSpecialCharacterWithUserName:(NSString *)userName{
    NSString *strLow = [userName lowercaseString];
    //密码特殊字符数组
    NSArray *specialCharactersArray = @[@"admin",@"root",@"system",@"user",@"guest",@"select",@"delete",@"insert"];
    for (int i = 0; i < specialCharactersArray.count; i++) {
        NSString *character = [specialCharactersArray objectAtIndex:i];
        if ([strLow containsString:character]){
            return character;
        }
    }
    
    return @"";
}

+ (NSString *)getDeviceUserNameErrorTips:(DevicePasswordErrorType)errorType contains:(NSString *)containsStr{

    NSString *error = @"";
    if (DPErrorTypeSpecialCharacters == errorType) {
        error = TS("TR_Error_User_Tip");
        error = [error stringByReplacingOccurrencesOfString:@"%s" withString:containsStr];
    }else if (DPErrorTypeNumberWordLimit == errorType) {
        error = TS("TR_Dev_User_Input_Tip");
    }

    return error;
}

//表情符号的判断
+(BOOL)isEmoji:(NSString *)string {
    if ([string length]<2){
        return NO;
    }

    static NSCharacterSet *_variationSelectors;
    _variationSelectors = [NSCharacterSet characterSetWithRange:NSMakeRange(0xFE00, 16)];

    if ([string rangeOfCharacterFromSet: _variationSelectors].location != NSNotFound){
        return YES;
    }
    const unichar high = [string characterAtIndex:0];
    // Surrogate pair (U+1D000-1F9FF)
    if (0xD800 <= high && high <= 0xDBFF){
        const unichar low = [string characterAtIndex: 1];
        const int codepoint = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
        return (0x1D000 <= codepoint && codepoint <= 0x1F9FF);
        // Not surrogate pair (U+2100-27BF)
    }else{
        return (0x2100 <= high && high <= 0x27BF);
    }
}

//检测密码格式
+(BOOL)deviceIsValidatePassword:(NSString *)password {
    //密码字符格式
    NSString * regex = @"((?![^a-zA-Z0-9]+$)(?![^a-zA-Z/D]+$)(?![^0-9/D]+$).{8,64}$)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:password]&&(password.length<=64)&&(password.length>=8);
}

@end
