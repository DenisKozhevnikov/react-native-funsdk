//
//  NavLabel.m
//  FunSDKDemo
//
//  Created by zhang on 2020/11/17.
//  Copyright © 2020 zhang. All rights reserved.
//

#import "UILabel+Nav.h"

@implementation UILabel (Nav)

- (id)initWithTitle:(NSString*)titleStr name:(NSString*)fileName{
    self = [super init];
    self.frame = CGRectMake(44, 0, ScreenWidth-88, 44);
    //设置文字居中显示
    self.textAlignment=NSTextAlignmentCenter;
    //设置titleLabel自动换行
    self.numberOfLines=0;
    //设置发微博的prefix
    NSString *title = titleStr;
    NSString *name = fileName;
    //获取标题的字符串
    NSString * str=[NSString stringWithFormat:@"%@\n%@",title,name];
    //创建一个带有属性的字符串
    NSMutableAttributedString * attrStr=[[NSMutableAttributedString alloc]initWithString:str];
    //设置title的字体大小
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:[str rangeOfString:title]];
    //设置name的字体大小
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:[str rangeOfString:name]];
    //设置name的颜色
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:[str rangeOfString:name]];
    //设置有属性的text
    self.attributedText=attrStr;
    return self;
}
@end
