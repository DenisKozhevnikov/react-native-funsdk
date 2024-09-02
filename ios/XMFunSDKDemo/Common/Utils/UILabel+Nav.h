//
//  NavLabel.h
//  FunSDKDemo
//
//  Created by zhang on 2020/11/17.
//  Copyright © 2020 zhang. All rights reserved.
//
/*
 Demo功能展示扩展类，目的是在导航栏标题下显示出类文件名称，方便查找
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Nav)

// titleStr：导航栏标题
// fileName：类文件名称，当前显示的功能界面的类文件名称
- (id)initWithTitle:(NSString*)titleStr name:(NSString*)fileName;
@end

NS_ASSUME_NONNULL_END
