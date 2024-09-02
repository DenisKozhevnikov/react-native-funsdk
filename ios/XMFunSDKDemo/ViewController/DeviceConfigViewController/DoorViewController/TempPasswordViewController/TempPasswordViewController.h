//
//  TempPasswordViewController.h
//  FunSDKDemo
//
//  Created by XM on 2019/4/10.
//  Copyright © 2019年 XM. All rights reserved.
//
/******
 
 门锁临时密码
 1、先获取门锁密码信息（没有设置过密码或者已失效的情况下是空值）
 2、点击列表输入或修改临时密码、有效次数、开始结束时间段(开始时间需要早于结束时间)
 3、点击存储保存门锁临时密码
 备注：
 //1、临时密码需要是6位数字
 //2、有效次数需要 >=1
 //3、起始时间短需要早于结束时间段
 //4、结束时间短段需要比当前时间晚
 //5、超出结束时间段后或者有效次数用尽后，临时密码失效，并且不再能查询到
 
 *******/
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TempPasswordViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
