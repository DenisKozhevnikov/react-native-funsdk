//
//  TransferModel.m
//  XMEye
//
//  Created by 杨翔 on 2017/4/6.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "TransferModel.h"
#import "string"
@implementation TransferModel

//object-C 16进制IP字符串和十进制IP互相转换

//获取一组转换过后的IP数据，
-(NSString*)transferString:(NSString*)str
{
    if (str == nil || str.length < 2) {
        return nil;
    }
    NSMutableArray *hexArray = [[NSMutableArray alloc] initWithCapacity:0];
    str = [str substringFromIndex:2];
    [self transferStringTostr:str];
    //取出16进制的单个字符转换为数字，然后添加进数组
    for (int i =0; i< self.currentString.length; i++) {
        NSString *stri = [[self.currentString substringFromIndex:i] substringToIndex:1];
        NSString *instance = [self transfer:stri];
        [hexArray addObject:instance];
    }
    NSString * hexStr = [self transferStringWithHexArray:hexArray];
    return hexStr;
}

-(void)transferStringTostr:(NSString*)str{
    if (str == nil) {
        return;
    }
    NSString *stri = [[str substringFromIndex:6] substringToIndex:1];
    stri = [stri stringByAppendingString:[[str substringFromIndex:7] substringToIndex:1]];
    stri = [stri stringByAppendingString:[[str substringFromIndex:4] substringToIndex:1]];
    stri = [stri stringByAppendingString:[[str substringFromIndex:5] substringToIndex:1]];
    stri = [stri stringByAppendingString:[[str substringFromIndex:2] substringToIndex:1]];
    stri = [stri stringByAppendingString:[[str substringFromIndex:3] substringToIndex:1]];
    stri = [stri stringByAppendingString:[[str substringFromIndex:0] substringToIndex:1]];
    stri = [stri stringByAppendingString:[[str substringFromIndex:1] substringToIndex:1]];
    self.currentString = stri;
}

//
-(NSString *)transferStringWithHexArray:(NSMutableArray *)hexArray{
    NSString *infoStr = @"";
    for (int i = 0; i<hexArray.count; i++) {
        if (i%2 == 0) {
            NSString *partStr = [NSString stringWithFormat:@"%d.",[hexArray[i] intValue]*16 +[hexArray[i+1] intValue]];
            infoStr = [infoStr stringByAppendingString:partStr];
        }
    }
    infoStr = [infoStr substringToIndex:infoStr.length - 1];
    return infoStr;
}

//字符串转mac
- (NSString *)dealWithMacString:(NSString *)str
{
    NSString *doneTitle = @"";
    int count = 0;
    for (int i = 0; i < str.length; i++) {
        count++;
        doneTitle = [doneTitle stringByAppendingString:[str substringWithRange:NSMakeRange(i, 1)]];
        if (count == 2) {
            if (i == str.length - 1) {
                doneTitle = [NSString stringWithFormat:@"%@", doneTitle];
            }else{
                doneTitle = [NSString stringWithFormat:@"%@:", doneTitle];
            }
            count = 0;
        }
    }
    NSLog(@"%@", doneTitle);
    return doneTitle;
}

//16进制转10进制字符串转mac
- (NSString *)dealWithHexadecimalMacString:(NSString *)str
{
    NSString *doneTitle = @"";
    int count = 0;
    for (int i = 0; i < str.length; i++) {
        count++;
        doneTitle = [doneTitle stringByAppendingString:[str substringWithRange:NSMakeRange(i, 1)]];
        if (count == 2) {
            if (i == str.length - 1) {
                doneTitle = [NSString stringWithFormat:@"%@", doneTitle];
            }else{
                doneTitle = [NSString stringWithFormat:@"%@:", doneTitle];
            }
            count = 0;
        }
    }
    NSLog(@"%@", doneTitle);
    NSArray *array = [doneTitle componentsSeparatedByString:@":"];
    NSString *macStr = @"";
    for (int k = 0; k < array.count; k++) {
        NSString *curStr = [array objectAtIndex:k];
        curStr = [NSString stringWithFormat:@"%lu",strtoul([curStr UTF8String],0,16)];
        if (curStr.length == 1) {
            curStr = [NSString stringWithFormat:@"0%@",curStr];
        }
        if (k > 0) {
            macStr = [NSString stringWithFormat:@"%@:%@",macStr, curStr];
        }else{
            macStr = curStr;
        }
    }
    return macStr;
}

//16进制转换为数字
-(NSString*)transfer:(NSString*)instance
{
    if (instance.length <=0) {
        return 0;
    }
    int ins = [self numberWithHexString:instance];
    return [NSString stringWithFormat:@"%d",ins];
}
//字符串转16进制不包含字母的数字
- (NSInteger)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    int hexNumber;
    sscanf(hexChar, "%x", &hexNumber);
    return (NSInteger)hexNumber;
}




//获取一组转换过后的16进制字符串
-(NSMutableArray*)reTransfer:(NSString*)hexString
{
    NSMutableArray *hexArray = [[NSMutableArray alloc] initWithCapacity:0];
    //通过"."来分割IP，然后单独转换
    NSArray *array = [hexString componentsSeparatedByString:@"."];
    if (array == nil) {
        return nil;
    }
    for (int i =0; i< array.count; i++) {
        NSString *result = [self numberToString:[[array objectAtIndex:i] integerValue]];
        if (result == nil) {
            return nil;
        }
        [hexArray addObject:result.uppercaseString];
    }
    
    hexArray = (NSMutableArray *)[[hexArray reverseObjectEnumerator] allObjects];
    return hexArray;
}

//把单个的数字转换成16进制字符串
-(NSString*)numberToString:(int)number
{
    char hexChar[6];
    //把数字填充进一个char类型的数组
    sprintf(hexChar, "%x", (int)number);
    //把数字转换成16进制字符串
    NSString *hexString = [NSString stringWithCString:hexChar encoding:NSUTF8StringEncoding];
    if (hexString == nil) {
        return nil;
    }
    //判断字符串长度，16进制IP字符串长度单位为两位，不足的前面补0
    if (hexString.length == 1) {
        hexString = [@"0" stringByAppendingString:hexString];
    }
    return hexString;
}

+ (NSNumber *) numberHexString:(NSString *)aHexString{
    // 为空,直接返回.
    if (nil == aHexString)
        
    {
        return nil;
    }
    
    NSScanner * scanner = [NSScanner scannerWithString:aHexString];
    
    unsigned long long longlongValue;
    
    [scanner scanHexLongLong:&longlongValue];
    
    //将整数转换为NSNumber,存储到数组中,并返回.
    
    NSNumber * hexNumber = [NSNumber numberWithLongLong:longlongValue];
    
    return hexNumber;
    
}

+ (NSString *)getBinaryByDecimal:(NSInteger)decimal {
    
    NSString *binary = @"";
    while (decimal) {
        
        binary = [[NSString stringWithFormat:@"%ld", decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1) {
            
            break;
        }
        decimal = decimal / 2 ;
    }
    if (binary.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    return binary;
}

@end
