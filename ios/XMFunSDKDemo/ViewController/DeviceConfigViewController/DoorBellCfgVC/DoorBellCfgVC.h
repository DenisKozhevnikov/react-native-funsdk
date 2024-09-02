//
//  DoorBellCfgVC.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/8/20.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*
 门铃(低功耗设备)配置界面
 
 1.录像本地存储
 2.拍照优先
 3.拍照本地存储
 4.强制关机
 5.设备呼吸灯
 */
@interface DoorBellCfgVC : UIViewController

@property (nonatomic,copy) NSString *devID;

@end

NS_ASSUME_NONNULL_END
