//
//  NSString+Utils.h
//  XWorld
//
//  Created by DingLin on 16/5/19.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
/** 检测字符串是否为nil 或者为@“” */
#define ISLEGALSTR(str) [NSString isLegalWithString:str]
/** 判断字符串是否相同 */
#define JF_IsEqualToStr(strX, strY) [strX jf_isEqualToStr:strY]
@interface NSString (Utils)
NSDate *YYNSDateFromString(__unsafe_unretained NSString *string);
//获取文本的长度
+(int)getStringLength:(NSString*)message;

//NSString-NSDateComponents
+(NSDateComponents*)toComponents:(NSString*)timeString;

//MARK:字典转字符串
+(NSString*)convertToJSONData:(id)infoDict;

//避免因为nullTerminatedCString 为空导致崩溃问题
+(NSString *)stringWithUTF8String_OutNil:(const char *)nullTerminatedCString;

//MARK:判断设备序列号是否合法
+(BOOL)legalSN:(NSString *)sn;

//MARK:序列号脱敏处理
+(NSString *)converSN:(NSString *)sn;

//字符串的字节长度
+ (int)getByteNum:(NSString *)str;

//通过字节长度截取字符串
+ (NSString *)subStringByByteWithIndex:(NSInteger)index str:(NSString *)str;
/** 判断字符串是否为nil */
+ (BOOL)isLegalWithString:(NSString *)string;

/// if content.lenght is zero, the method will return CGZero, and the title default font-value is 15,return CGSize.
/// @param content
+ (CGSize)getSizeWithContent:(NSString *)content;
/// if content.lenght is zero, the method will return CGZero, and the title default font-value is 15,return CGSize.
/// @param content content
/// @param limitSize the limit-size
+ (CGSize)getSizeWithContent:(NSString *)content limitSize:(CGSize)limitSize;
/// if content.lenght is zero, the method will return CGZero, and if you do not take font-value,the title default font-value is 15.
/// @param content content description
/// @param fontValue the font-value,default is 15
/// @param weight the weight-value
+ (CGSize)getSizeWithContent:(NSString *)content fontValue:(CGFloat)fontValue weight:(CGFloat)weight;
/** 生成随机码 */
+ (NSString *)randomStrWithLength:(NSInteger)length;
//MARK: 计算需要分配的数组大小
+(int)getCharArraySize:(NSString *)content;
// MARK: 判断字符串是否相同
- (BOOL)jf_isEqualToStr:(NSString *)str;
/** 将NSData转成十六进制字符串 */
+ (NSString *)xm_hexStringWithData:(NSData *)data;
/** MAC ADDRESS */
+ (NSString *)xm_deviceMacAddress;
@end
