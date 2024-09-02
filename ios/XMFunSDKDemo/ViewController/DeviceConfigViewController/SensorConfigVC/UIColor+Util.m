//
//  UIColor+Util.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-18.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "UIColor+Util.h"
//#import "AppDelegate.h"

@implementation UIColor (Util)

#pragma mark - Hex

+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:alpha];
}

+ (UIColor *)colorWithHex:(int)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}

+ (UIColor *)colorWithHexStr:(NSString*)hexStr{
    
    if ( !hexStr || (![hexStr hasPrefix:@"#"] && ![hexStr hasPrefix:@"0x"])) {
        return [UIColor blackColor];
    }
    int nScanBeginIndex = 0;
    if ( [hexStr hasPrefix:@"#"] ) {
        nScanBeginIndex = 1;
    }
    else{
        nScanBeginIndex = 2;
    }
    unsigned int rgb=0,a=255;
    int nHexLen = [hexStr length]-nScanBeginIndex;
    //RGB   0xFFFFFF 或 ＃FFFFFF 格式
    NSRange range = NSMakeRange(nScanBeginIndex, nHexLen>=6? 6: nHexLen);
    NSString *stringtemp = [hexStr substringWithRange:range];
    if ( stringtemp ) {
        [[NSScanner scannerWithString:stringtemp] scanHexInt:&rgb];
    }
    
    //RGBA 0xFFFFFFFF 或 ＃FFFFFFFF 格式
    if ( nHexLen == 8 ) {
        range = NSMakeRange(6+nScanBeginIndex, 2);
        stringtemp = [hexStr substringWithRange:range];
        if ( stringtemp ) {
            [[NSScanner scannerWithString:stringtemp] scanHexInt:&a];
        }
    }
    //位数不对的 使用默认的0x000000FF
    return [self colorWithHex:rgb alpha:a/255.0];
}

@end
