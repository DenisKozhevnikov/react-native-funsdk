//
//  NSString+Extention.h
//  XMFamily
//
//  Created by Megatron on 4/24/15.
//  Copyright (c) 2015 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,DevicePasswordErrorType) {
    DPErrorTypeNone,                        //没有错误
    DPErrorTypeNumberWordLimit,             //(X-XX位长度 包含数字和字母)
    DPErrorTypeASCII4Continuous,            //是否4位连续
    DPErrorTypeASCII3Overlapping,           //是否3位重叠
    DPErrorTypeSpecialCharacters,           //特殊字符user admin
};

@interface NSString (Extention)

#pragma mark 传入一个表示时间的整数 转化为 一个时间的字符串 格式:00:00
+ (NSString *)getTimeStringWihtNumber:(NSInteger)time;
#pragma mark 将十进制转化为二进制,设置返回NSString 长度
+ (NSString *)decimalTOBinary:(uint16_t)tmpid backLength:(int)length;
#pragma mark 通过二进制的八位长度的字符串 判断 需要的时间
+ (NSString *)getWeekTimeStringWithBinaryString:(int)num;
#pragma mark 传入一个整数 转化成天时分秒的形式
+ (NSString *)getDHMSStringWithIntNumber:(NSInteger)time;
#pragma mark 字典装json
+ (NSString *)dictionaryToJson:(NSDictionary *)dic;
+ (NSString *)dictionaryToJsonWithoutWritingPrettyPrinted:(NSDictionary *)dic;//不带换行符号的转
#pragma mark 检测密码格式 密码8-32位必须包含数字和字母
+(BOOL)isValidatePassword:(NSString *)password;
#pragma mark 检测邮箱格式
+(BOOL)isValidateEmail:(NSString *)email;
#pragma mark 检测用户名是否合法 4-32位，由中文/字母/数字组成，但不能是纯数字
+(BOOL)isValidateUserName:(NSString *)userName;

//MARK: 是否匹配设备用户名规则 1. (4-15位长度 包含数字和字母)；2特殊字符user admin
+ (DevicePasswordErrorType)matchDeviceUserNameRule:(NSString *)userName;
//MARK: 用户名特殊字符数组
+ (NSString *)containsSpecialCharacterWithUserName:(NSString *)userName;
+ (NSString *)getDeviceUserNameErrorTips:(DevicePasswordErrorType)errorType contains:(NSString *)containsStr;
//表情符号的判断
+(BOOL)isEmoji:(NSString *)string;
//检测密码格式
+(BOOL)deviceIsValidatePassword:(NSString *)password;
@end
