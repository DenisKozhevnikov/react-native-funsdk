//
//  XYShowAlertView.h
//
//
//  Created by 杨 on 16/1/12.
//  Copyright © 2016年 杨. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYShowAlertView : UIWindow

@property (nonatomic,copy) void(^showAlertViewClicked)(int data);

+(instancetype)shareInstance;

-(void)showAlertViewWithTitle:(NSString *)title andDetailText:(NSString *)detailText;

@end
