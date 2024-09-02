//
//  TransferModel.h
//  XMEye
//
//  Created by 杨翔 on 2017/4/6.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransferModel : NSObject
//从16进制IP转成十进制IP
-(NSString*)transferString:(NSString*)str;
//字符串转mac
- (NSString *)dealWithMacString:(NSString *)str;
//16进制字符串转mac
- (NSString *)dealWithHexadecimalMacString:(NSString *)str;
//从十进制转换成十六进制数组
-(NSMutableArray*)reTransfer:(NSString*)hexString;

//从16进制数组转成十进制数字
+ (NSNumber *)numberHexString:(NSString *)aHexString;

//从2进制转为10进制
+ (NSString *)getBinaryByDecimal:(NSInteger)decimal;



@property (nonatomic, copy) NSString *currentString;

@end
