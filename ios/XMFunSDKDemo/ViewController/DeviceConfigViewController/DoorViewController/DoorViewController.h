//
//  DoorViewController.h
//  FunSDKDemo
//
//  Created by XM on 2019/4/10.
//  Copyright © 2019年 XM. All rights reserved.
//

/*****
 
 门锁功能（门锁设备）
 1、远程开锁功能
 2、设置临时密码
 3、用户密码管理、指纹管理、门卡管理
 4、消息统计开关
 5、消息推送开关
 6、免打扰管理
 备注：门锁功能调用时请保证门锁不在休眠状态 （不过不能保证，可以调用接口前先调用唤醒接口，唤醒成功之后再继续）
 
 *********/
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoorViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
