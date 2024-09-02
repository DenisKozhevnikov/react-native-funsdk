//
//  UIColor+Util.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-18.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JFColor(str)            [UIColor colorWithHexStr:str]
/** `白色` */
#define JFCommonColor_FFF       JFColor(@"#FFFFFF")
/** `黑色` */
#define JFCommonColor_333       JFColor(@"#333333")
/** `浅灰色` */
#define JFCommonColor_EEE       JFColor(@"#EEEEEF")
/** `不可操作颜色` */
#define JFCommonColor_D5D5      JFColor(@"#D5D5D5")
/** `浅灰 888888` */
#define JFCommonColor_888       JFColor(@"#888888")

@interface UIColor (Util)

+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(int)hexValue;
+ (UIColor *)colorWithHexStr:(NSString*)hexStr;


@end
